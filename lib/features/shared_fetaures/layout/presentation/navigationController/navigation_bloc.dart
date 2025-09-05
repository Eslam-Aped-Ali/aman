import 'package:Aman/features/driver/profile_management/presentation/view/screens/driver_profile_screen_new.dart';
import 'package:Aman/features/driver/trips_management/presentation/view/screens/route_navigation_screen.dart';
import 'package:Aman/features/driver/trips_management/presentation/view/screens/trip_passengers_screen.dart';
import 'package:Aman/features/passenger/home/presentation/view/screens/passenger_home_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the BLoCs and GetIt
import '../../../../../app/di.dart';
import '../../../../driver/profile_management/presentation/bloc/driver_profile_bloc.dart';
import '../../../../driver/trips_management/presentation/bloc/driver_trips_bloc.dart';
import '../../../../passenger/profile/presentation/viewModel/profile_cubit/passenger_profile_cubit.dart';
import '../../../../shared_fetaures/auth/presentation/bloc/auth_cubit.dart';

// Admin screens
import '../../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../../admin/presentation/screens/admin_trip_management_screen.dart';
import '../../../../admin/presentation/screens/admin_bus_driver_management_screen.dart';
import '../../../../admin/presentation/screens/admin_analytics_screen.dart';
import '../../../../admin/presentation/screens/admin_profile_screen.dart';

// Driver screens
import '../../../../driver/trips_management/presentation/view/screens/current_trips_screen.dart';
import '../../../../driver/trips_management/presentation/view/screens/trip_history_screen.dart';

// Passenger screens
import '../../../../passenger/booking/presentation/view/screens/book_now_screen.dart';
import '../../../../passenger/profile/presentation/view/screens/passenger_profile_screen.dart';
import '../../../../passenger/trips/presentation/view/screens/available_trips.dart';
import '../../../../passenger/live_tracking/presentation/view/screens/live_tracking_screen.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final String? userType;

  NavigationBloc({this.userType}) : super(NavigationState.initial()) {
    on<NavigateToPage>(_onNavigateToPage);
  }

  void _onNavigateToPage(NavigateToPage event, Emitter<NavigationState> emit) {
    emit(NavigationState(event.index));
  }

  Widget get currentPage => getSelectedPage(state.currentIndex);

  Widget getSelectedPage(int index) {
    // Return different pages based on user type
    switch (userType?.toLowerCase()) {
      case 'admin':
        return _getAdminPage(index);
      case 'driver':
        return _getDriverPage(index);
      case 'passenger':
      default:
        return _getPassengerPage(index);
    }
  }

  Widget _getAdminPage(int index) {
    switch (index) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const AdminTripManagementScreen();
      case 2:
        return const AdminBusDriverManagementScreen();
      case 3:
        return const AdminAnalyticsScreen();
      case 4:
        return BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
          child: const AdminProfileScreen(),
        );
      default:
        return const AdminDashboardScreen();
    }
  }

  Widget _getDriverPage(int index) {
    switch (index) {
      case 0:
        return BlocProvider<DriverTripsBloc>(
          create: (context) => sl<DriverTripsBloc>(),
          child: const CurrentTripsScreen(),
        );

      case 1:
        return BlocProvider<DriverTripsBloc>(
          create: (context) => sl<DriverTripsBloc>(),
          child: const RouteNavigationScreen(),
        );
      case 2:
        return BlocProvider<DriverTripsBloc>(
          create: (context) => sl<DriverTripsBloc>(),
          child: const TripPassengersScreen(),
        );
      case 3:
        return BlocProvider<DriverTripsBloc>(
          create: (context) => sl<DriverTripsBloc>(),
          child: const TripHistoryScreen(),
        );
      case 4:
        return BlocProvider<DriverProfileBloc>(
          create: (context) => sl<DriverProfileBloc>(),
          child: const DriverProfileScreen(),
        );
      default:
        return BlocProvider<DriverTripsBloc>(
          create: (context) => sl<DriverTripsBloc>(),
          child: const CurrentTripsScreen(),
        );
    }
  }

  Widget _getPassengerPage(int index) {
    switch (index) {
      case 0:
        return const PassengerHomeScreen();
      case 1:
        return const AvailableTripsScreen();
      case 2:
        return const LiveTrackingScreen();
      case 3:
        return const BookNowScreen();
      case 4:
        return MultiBlocProvider(
          providers: [
            BlocProvider<PassengerProfileCubit>(
              create: (context) => sl<PassengerProfileCubit>(),
            ),
            BlocProvider<AuthCubit>(
              create: (context) => sl<AuthCubit>(),
            ),
          ],
          child: const PassengerProfileScreen(),
        );
      default:
        return const PassengerHomeScreen();
    }
  }
}
