import 'package:flutter/material.dart';

/// The app's motion vocabulary.
///
/// v1 animated nothing except the page transitions Flutter gives away for
/// free, so every state change in the app landed as a hard cut: a filter chip
/// went from grey to copper between two frames, a list of cafés replaced
/// another list with no sense that anything had been fetched. Motion here is
/// there to explain a change, never to decorate one — which is why the
/// durations are short and there is only one spring.
///
/// Durations come in three sizes and that is deliberate: a fourth would be
/// indistinguishable from its neighbours and would only give the next person
/// an excuse to pick a number.
abstract final class AppMotion {
  /// Colour and opacity changes inside a control the finger is already on —
  /// a chip filling in, a tick appearing.
  static const fast = Duration(milliseconds: 180);

  /// The default: content arriving, a card expanding, a sheet's contents
  /// settling.
  static const medium = Duration(milliseconds: 280);

  /// Hero flights and full-screen transitions, which cover more distance and
  /// look snatched away if they match [medium].
  static const slow = Duration(milliseconds: 420);

  /// Everything that simply moves from A to B.
  ///
  /// `easeOutCubic` rather than Material's `fastOutSlowIn`: content that
  /// arrives fast and settles slowly reads as responsive, and the difference
  /// is obvious on the 60 Hz Androids that are most of Erbil's phones.
  static const standard = Curves.easeOutCubic;

  /// Something entering the screen for the first time.
  static const entrance = Curves.easeOutQuart;

  /// Something the user is dragging or flinging — overshoots slightly, which
  /// makes a sheet or a scaling image feel like it has weight.
  static const spring = Curves.easeOutBack;

  /// Stagger between consecutive items in a list that animates in.
  ///
  /// 45 ms is the point where a list of eight reads as one wave rather than
  /// eight separate animations; past ~60 ms the last card is visibly late.
  static const stagger = Duration(milliseconds: 45);

  /// The longest an item is allowed to wait before it starts.
  ///
  /// Without a ceiling, item 30 in a long list would start a second and a half
  /// after item 1 — which on a fast scroll means blank cards.
  static const maxStagger = Duration(milliseconds: 270);
}

/// Fades and lifts [child] into place, optionally after a stagger.
///
/// Used for the first paint of a list or a screen's sections. It animates
/// exactly once: rebuilding the widget (a favourite toggled, a filter applied)
/// leaves it where it is rather than replaying, because a list that re-enters
/// on every keystroke is worse than one that never animates at all.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.index = 0,
    this.offset = 16,
    this.duration = AppMotion.medium,
    super.key,
  });

  final Widget child;

  /// Position in the list, used to stagger the start.
  final int index;

  /// How far below its final position the child starts, in logical pixels.
  final double offset;

  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();

    final delay = AppMotion.stagger * widget.index;
    final capped = delay > AppMotion.maxStagger ? AppMotion.maxStagger : delay;

    if (capped == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(capped, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.entrance,
    );

    return AnimatedBuilder(
      animation: curved,
      // The child is built once and reused for every frame — the animation
      // only moves and fades it.
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Shrinks [child] slightly while it is pressed.
///
/// Cards in this app are large and dark, and a Material ink ripple on them is
/// nearly invisible; a scale is legible on any surface and at any size.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final HitTestBehavior behavior;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
