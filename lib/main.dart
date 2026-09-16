import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/di/injector.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/notifications/data/push_service.dart';

Future<void> main() async {
  // Without a DSN the app starts exactly as it always did — no SDK, no
  // network, no account needed to run a local checkout or a test.
  if (!AppConfig.errorReportingEnabled) {
    await _start();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.release = AppConfig.releaseName;
      options.environment = AppConfig.isProduction ? 'production' : 'debug';

      // A trace on every session is a bill, not a signal. Crashes are always
      // captured; performance is sampled.
      options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;

      // Do not attach the user's IP, and do not photograph the screen a crash
      // happened on: a café page is harmless, the sign-in form is not.
      options.sendDefaultPii = false;

      // A breadcrumb trail of taps and screens is what makes a stack trace
      // reproducible; the text inside the widgets is not needed for that.
      options.beforeBreadcrumb = (breadcrumb, hint) {
        if (breadcrumb?.category == 'http') {
          // Query strings carry search terms and coordinates.
          breadcrumb?.data?.remove('http.query');
        }
        return breadcrumb;
      };
    },
    appRunner: _start,
  );
}

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupInjector();

  // Restore the session before the first frame so the router's redirect sees a
  // settled state and cannot bounce a signed-in user to sign-in.
  await sl<AuthCubit>().restore();

  // Start Firebase, but never let it stop the app: a missing
  // google-services.json means "no notifications", not "no café app".
  // Permission is asked for later, after a booking.
  //
  // Not awaited. The comment here always said the first frame must not wait
  // on Firebase, and the code waited on it anyway; `listen` in the app's
  // first frame awaits the same start-up instead.
  unawaited(
    sl<PushService>().init().then((_) {
      if (sl<AuthCubit>().state.isAuthenticated) {
        return sl<PushService>().registerDevice();
      }
    }),
  );

  runApp(const ErbilCafeApp());
}
