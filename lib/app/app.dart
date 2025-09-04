import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_errors_crashes/phoneix.dart';
import 'app_errors_crashes/unfucs.dart';
import '../core/shared/theme/cubit/theme_cubit.dart';
import '../core/shared/theme/cubit/theme_state.dart';
import '../core/shared/utils/depugging/debug_utils.dart';
import '../core/shared/utils/observers/route_observer.dart';
import 'app_errors_crashes/error_widgets.dart';
import 'routing/app_routes.dart';
import 'routing/app_routes_fun.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit()..loadTheme(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Preload critical resources
    _preloadResources();
  }

  void _preloadResources() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Preload theme data
      final themeCubit = context.read<ThemeCubit>();
      themeCubit.loadTheme();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Debounce theme changes to avoid excessive rebuilds
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        final themeCubit = context.read<ThemeCubit>();
        if (themeCubit.state.themeMode == AppThemeMode.system) {
          themeCubit.onSystemThemeChanged();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) {
        // Prevent unnecessary rebuilds - only rebuild when theme mode changes
        return previous.themeMode != current.themeMode;
      },
      builder: (context, themeState) {
        print('🎨 BlocBuilder rebuilding with theme: ${themeState.themeMode}');
        return ScreenUtilInit(
          designSize: const Size(390, 844), // Standard mobile design size
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) => _MaterialApp(
            key: ValueKey(
                themeState.themeMode), // Force rebuild when theme changes
            themeState: themeState,
          ),
        );
      },
    );
  }
}

class _MaterialApp extends StatelessWidget {
  final ThemeState themeState;

  const _MaterialApp({super.key, required this.themeState});

  @override
  Widget build(BuildContext context) {
    print('🏗️ _MaterialApp building with theme: ${themeState.themeMode}');

    // Determine the correct themes and mode based on the theme mode
    ThemeData lightTheme;
    ThemeData? darkTheme;
    ThemeMode themeMode;

    switch (themeState.themeMode) {
      case AppThemeMode.colorBlind:
        lightTheme = themeState.colorblindTheme;
        darkTheme = themeState
            .colorblindTheme; // Use colorblind theme for both light and dark
        themeMode = ThemeMode.light; // Force light mode for colorblind
        print('🎨 Using colorblind theme');
        break;
      case AppThemeMode.light:
        lightTheme = themeState.lightTheme;
        darkTheme = themeState.darkTheme;
        themeMode = ThemeMode.light;
        print('🎨 Using light theme');
        break;
      case AppThemeMode.dark:
        lightTheme = themeState.lightTheme;
        darkTheme = themeState.darkTheme;
        themeMode = ThemeMode.dark;
        print('🎨 Using dark theme');
        break;
      case AppThemeMode.system:
        lightTheme = themeState.lightTheme;
        darkTheme = themeState.darkTheme;
        themeMode = ThemeMode.system;
        print('🎨 Using system theme');
        break;
    }

    return MaterialApp(
      title: 'Aman',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorObservers: [
        AppRouteObserver(),
        routeObserver,
      ],
      initialRoute: AppRoutes.init.initial,
      routes: AppRoutes.init.appRoutes,
      navigatorKey: navigatorKey,
      scrollBehavior: _AppScrollBehavior(),
      builder: (context, child) => _AppWrapper(child: child),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}

class _AppWrapper extends StatefulWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> {
  @override
  void initState() {
    super.initState();
    _setupErrorWidget();
  }

  void _setupErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (kDebugMode) {
        Console.printError('Error caught by ErrorWidget.builder:');
        Console.printError(details.exception);
        Console.printError('stack trace : ${details.stack}');
      }
      return ErrorScreen(details: details);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MediaQuery(
        data: _getMediaQueryData(context),
        child: Unfocus(
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  MediaQueryData _getMediaQueryData(BuildContext context) {
    return MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(1.sp > 1.2 ? 1.2 : 1.sp),
    );
  }
}

///// Theme switcher button
// IconButton(
//   icon: Icon(_getThemeIcon(context)),
//   onPressed: () {
//     context.read<ThemeCubit>().toggleTheme();
//   },
// )
//
// // Helper method for the icon
// IconData _getThemeIcon(BuildContext context) {
//   final themeMode = context.watch<ThemeCubit>().state.themeMode;
//   return themeMode.icon; // Using the extension we created
// }
//
// // Or a more detailed theme selector
// PopupMenuButton<AppThemeMode>(
//   icon: Icon(context.watch<ThemeCubit>().state.themeMode.icon),
//   onSelected: (mode) {
//     context.read<ThemeCubit>().setTheme(mode);
//   },
//   itemBuilder: (context) => AppThemeMode.values.map((mode) {
//     return PopupMenuItem(
//       value: mode,
//       child: Row(
//         children: [
//           Icon(mode.icon),
//           const SizedBox(width: 12),
//           Text(mode.displayName),
//         ],
//       ),
//     );
//   }).toList(),
// )
