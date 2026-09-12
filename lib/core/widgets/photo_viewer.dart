import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';

/// Full-screen photo viewer: swipe between photos, pinch to zoom, drag down to
/// dismiss.
///
/// A café's photos are the reason most people open its page at all, and until
/// now they were 150×128 thumbnails with nothing behind the tap. This is the
/// screen that tap leads to.
///
/// Opened with [PhotoViewer.open], which pushes a transparent route so the
/// photo appears to grow out of the thumbnail rather than sliding in from the
/// side of a new page.
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({
    required this.photos,
    this.initialIndex = 0,
    this.heroPrefix,
    super.key,
  });

  final List<PhotoSource> photos;
  final int initialIndex;

  /// When set, each photo flies from the widget whose `Hero` tag is
  /// `'$heroPrefix-$index'`. Null skips the flight.
  final String? heroPrefix;

  static Future<void> open(
    BuildContext context, {
    required List<PhotoSource> photos,
    int initialIndex = 0,
    String? heroPrefix,
  }) {
    if (photos.isEmpty) return Future<void>.value();

    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: AppMotion.slow,
        reverseTransitionDuration: AppMotion.medium,
        pageBuilder: (_, __, ___) => PhotoViewer(
          photos: photos,
          initialIndex: initialIndex,
          heroPrefix: heroPrefix,
        ),
        // Only the backdrop fades; the photo itself is carried by the hero,
        // and fading both makes the image look like it is dissolving.
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _pages =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  /// How far the sheet has been dragged down, in logical pixels.
  double _drag = 0;

  /// Zoomed-in pages own the gesture, so the pager and the dismiss drag both
  /// stand down until the photo is back at 1×.
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_zoomed) return;
    setState(() => _drag = (_drag + details.delta.dy).clamp(0.0, 1000.0));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_zoomed) return;

    // Either a long drag or a quick flick closes it; everything else springs
    // back, so a mis-swipe never loses the photo.
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_drag > 120 || velocity > 700) {
      Navigator.of(context).pop();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The backdrop thins out as the photo is dragged away, which is what makes
    // the drag feel like it is dismissing something rather than moving it.
    final progress = (_drag / 320).clamp(0.0, 1.0);
    final total = widget.photos.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.inkDeep.withValues(alpha: 1 - progress * 0.85),
              ),
            ),

            GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: Transform.translate(
                offset: Offset(0, _drag),
                child: Transform.scale(
                  scale: 1 - progress * 0.12,
                  child: PageView.builder(
                    controller: _pages,
                    physics: _zoomed
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: total,
                    itemBuilder: (context, index) => _Page(
                      photo: widget.photos[index],
                      heroTag: widget.heroPrefix == null
                          ? null
                          : '${widget.heroPrefix}-$index',
                      onZoomChanged: (zoomed) {
                        if (_zoomed != zoomed) setState(() => _zoomed = zoomed);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Controls fade out with the backdrop so a drag does not leave a
            // close button floating over the page underneath.
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Opacity(
                opacity: 1 - progress,
                child: Row(
                  children: [
                    _GlassButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (total > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_index + 1} / $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (widget.photos[_index].caption?.isNotEmpty ?? false)
              Positioned(
                left: AppSpacing.page,
                right: AppSpacing.page,
                bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
                child: Opacity(
                  opacity: 1 - progress,
                  child: Text(
                    widget.photos[_index].caption!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One photo, zoomable.
class _Page extends StatefulWidget {
  const _Page({
    required this.photo,
    required this.onZoomChanged,
    this.heroTag,
  });

  final PhotoSource photo;
  final String? heroTag;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _reset = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  );
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
    _reset.addListener(() {
      final value = _resetAnimation?.value;
      if (value != null) _transform.value = value;
    });
  }

  void _onTransform() {
    widget.onZoomChanged(_transform.value.getMaxScaleOnAxis() > 1.02);
  }

  /// Double tap zooms to 2.5× on the point that was tapped, and a second
  /// double tap goes back — the gesture every photo app has.
  void _onDoubleTapDown(TapDownDetails details) {
    final zoomedIn = _transform.value.getMaxScaleOnAxis() > 1.02;
    final target = zoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translateByDouble(
            -details.localPosition.dx * 1.5,
            -details.localPosition.dy * 1.5,
            0,
            1,
          )
          ..scaleByDouble(2.5, 2.5, 1, 1));

    _resetAnimation = Matrix4Tween(begin: _transform.value, end: target)
        .animate(CurvedAnimation(parent: _reset, curve: AppMotion.standard));
    _reset.forward(from: 0);
  }

  @override
  void dispose() {
    _transform
      ..removeListener(_onTransform)
      ..dispose();
    _reset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: widget.photo.url,
      fit: BoxFit.contain,
      fadeInDuration: AppMotion.fast,
      placeholder: (context, _) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      errorWidget: (context, _, __) => const Center(
        child: Icon(Icons.broken_image_outlined,
            color: AppColors.onCardDisabled, size: 48),
      ),
    );

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      // Flutter needs an onDoubleTap for onDoubleTapDown to fire at all.
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 5,
        child: Center(child: image),
      ),
    );
  }
}

/// One photo's address, with the smaller version to show until it loads.
class PhotoSource {
  const PhotoSource({required this.url, this.thumbUrl, this.caption});

  final String url;
  final String? thumbUrl;
  final String? caption;
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
