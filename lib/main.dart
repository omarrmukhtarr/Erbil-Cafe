import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/di/injector.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupInjector();

  // Restore the session before the first frame so the router's redirect sees a
  // settled state and cannot bounce a signed-in user to sign-in.
  await sl<AuthCubit>().restore();

  runApp(const ErbilCafeApp());
}
