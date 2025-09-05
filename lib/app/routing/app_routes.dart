import 'package:Aman/features/driver/profile_management/presentation/bloc/driver_profile_bloc.dart';
import 'package:Aman/features/driver/profile_management/presentation/view/screens/complete_profile_screen.dart';
import 'package:Aman/features/driver/profile_management/presentation/view/screens/driver_profile_screen_new.dart';
import 'package:Aman/features/driver/profile_management/presentation/view/screens/waiting_approval_screen.dart';
import 'package:Aman/features/passenger/home/presentation/view/screens/passenger_home_screen_new.dart';
import 'package:Aman/features/passenger/profile/presentation/viewModel/profile_cubit/passenger_profile_cubit.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/bloc/auth_cubit.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/view/screens/login_screen.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/view/screens/registration_screen.dart';
import 'package:Aman/features/shared_fetaures/splash/enhanced_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/shared_fetaures/onBoarding/presentation/view/screens/intro_screen.dart';
import '../../features/shared_fetaures/layout/presentation/view/screen/layout_view.dart';
import '../../../features/passenger/profile/presentation/view/screens/passenger_profile_screen.dart';
import '../../../features/passenger/profile/presentation/view/screens/settings_screen.dart';
import '../../../features/passenger/profile/presentation/view/screens/help_support_screen.dart';
import '../../features/shared_fetaures/select_role/presentation/view/screen/select_role_screen.dart';
import 'routes.dart';
import '../di.dart';
import '../../core/shared/theme/cubit/theme_cubit.dart';
import '../../features/passenger/profile/presentation/viewModel/settings/settings_cubit.dart';
import '../../features/passenger/profile/presentation/viewModel/language/language_cubit.dart';

// Driver BLoCs

class AppRoutes {
  static AppRoutes get init => AppRoutes._internal();
  String initial = NamedRoutes.i.splash;
  AppRoutes._internal();

  Map<String, Widget Function(BuildContext c)> appRoutes = {
    NamedRoutes.i.splash: (c) => const EnhancedSplashScreen(),
    NamedRoutes.i.driverApprovalScreen: (c) {
      final args = ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>;
      return BlocProvider<DriverProfileBloc>(
        create: (context) => sl<DriverProfileBloc>(),
        child: WaitingForApprovalScreen(
          driverProfile: args['driverProfile'],
          phoneNumber: args['phoneNumber'],
          shouldLoadProfile: args['shouldLoadProfile'] ?? false,
        ),
      );
    },
    NamedRoutes.i.intro: (c) => const IntroScreen(),
    NamedRoutes.i.layout: (c) {
      final args =
          ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>?;
      return LayoutView(userType: args?['userType']);
    },
    NamedRoutes.i.selectRole: (c) => const SelectRoleScreen(),
    // NamedRoutes.i.login: (c) {
    //   final args =
    //       ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>?;
    //   return LoginWithPhoneScreen(userRole: args?['userRole']);
    // },
    // NamedRoutes.i.otp: (c) {
    //   final args = ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>;
    //   return OtpScreen(
    //     phoneNumber: args['phoneNumber'],
    //     userRole: args['userRole'],
    //     isAdmin: args['isAdmin'] ?? false,
    //   );
    // },
    // NamedRoutes.i.passengerCompleteProfile: (c) =>
    //     const PassengerCompleteProfileScreen(),
    NamedRoutes.i.driverCompleteProfile: (c) {
      final args = ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>;
      return BlocProvider<DriverProfileBloc>(
        create: (context) => sl<DriverProfileBloc>(),
        child: CompleteDriverProfileScreen(
          phoneNumber: args['phoneNumber'],
        ),
      );
    },
    NamedRoutes.i.login: (c) {
      final args =
          ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>?;
      return BlocProvider<AuthCubit>(
        create: (context) => sl<AuthCubit>(),
        child: LoginScreen(
          userRole: args?['userRole'],
          preFilledPhone: args?['preFilledPhone'],
          preFilledPassword: args?['preFilledPassword'],
        ),
      );
    },

    NamedRoutes.i.register: (c) {
      final args =
          ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>?;
      return BlocProvider<AuthCubit>(
        create: (context) => sl<AuthCubit>(),
        child: RegistrationScreen(
          userRole: args?['userRole'],
          phoneNumber: args?['phoneNumber'],
        ),
      );
    },
    NamedRoutes.i.passengerHome: (c) => const PassengerHomeScreen(),
    NamedRoutes.i.passengerProfile: (c) => MultiBlocProvider(
          providers: [
            BlocProvider<PassengerProfileCubit>(
              create: (context) => sl<PassengerProfileCubit>(),
            ),
            BlocProvider<AuthCubit>(
              create: (context) => sl<AuthCubit>(),
            ),
          ],
          child: PassengerProfileScreen(),
        ),
    NamedRoutes.i.driverProfile: (c) => MultiBlocProvider(
          providers: [
            BlocProvider<DriverProfileBloc>(
              create: (context) => sl<DriverProfileBloc>(),
            ),
            BlocProvider<AuthCubit>(
              create: (context) => sl<AuthCubit>(),
            ),
          ],
          child: const DriverProfileScreen(),
        ),
    NamedRoutes.i.profile: (c) => const PassengerProfileScreen(),
    NamedRoutes.i.settings: (c) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: BlocProvider.of<ThemeCubit>(c),
            ),
            BlocProvider<SettingsCubit>(
              create: (context) => sl<SettingsCubit>()..loadSettings(),
            ),
            BlocProvider<LanguageCubit>(
              create: (context) => sl<LanguageCubit>()..loadLanguage(),
            ),
          ],
          child: const SettingsScreen(),
        ),
    NamedRoutes.i.helpSupport: (c) => const HelpSupportScreen(),
    NamedRoutes.i.adminDashboard: (c) => const AdminDashboardScreen(),
  };
}
