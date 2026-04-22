import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection.dart' as di;
import 'app/router/app_router.dart';
import 'firebase_options.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/activity/presentation/bloc/activity_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('en_US', null);
  await di.initDependencies();

  runApp(const StravskiApp());
}

class StravskiApp extends StatelessWidget {
  const StravskiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<ActivityBloc>(
          create: (_) => di.sl<ActivityBloc>(),
          lazy: true,
        ),
        BlocProvider<AnalyticsBloc>(
          create: (_) => di.sl<AnalyticsBloc>(),
          lazy: true,
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>(),
          lazy: true,
        ),
      ],
      child: MaterialApp.router(
        title: 'Stravski',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
