import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../live_tracking/data/datasources/live_tracking_local_data_source.dart';
import '../../../../live_tracking/data/repositories/live_tracking_repository_impl.dart';
import '../../../../live_tracking/domain/usecases/get_current_trip.dart';
import '../../../../live_tracking/domain/usecases/get_my_bookings.dart';
import '../../../../live_tracking/domain/usecases/cancel_trip.dart';
import '../../../../live_tracking/domain/usecases/get_trip_updates.dart';
import '../../../../live_tracking/presentation/bloc/live_tracking_bloc.dart';
import '../../../../live_tracking/presentation/bloc/live_tracking_event.dart';
import '../../../../live_tracking/presentation/bloc/live_tracking_state.dart';
import '../../../../live_tracking/domain/entities/live_trip.dart';
import '../../../../live_tracking/presentation/view/screens/live_tracking_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _navigateToTripTracking(LiveTrip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveTrackingScreen(initialTrip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return BlocProvider(
      create: (context) {
        final repository = LiveTrackingRepositoryImpl(
          LiveTrackingLocalDataSourceImpl(),
        );
        final bloc = LiveTrackingBloc(
          getCurrentTripUseCase: GetCurrentTripUseCase(repository),
          getMyBookingsUseCase: GetMyBookingsUseCase(repository),
          cancelTripUseCase: CancelTripUseCase(repository),
          getTripUpdatesUseCase: GetTripUpdatesUseCase(repository),
        );

        final userId = StorageService.getString('user_id') ?? 'user_123';
        bloc.add(LoadMyBookings(userId));

        return bloc;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(LocaleKeys.myBookings_title.tr()),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                final userId =
                    StorageService.getString('user_id') ?? 'user_123';
                context.read<LiveTrackingBloc>().add(LoadMyBookings(userId));
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocConsumer<LiveTrackingBloc, LiveTrackingState>(
          listener: (context, state) {
            // Debug print to help diagnose the issue
            print('MyBookingsScreen state: ${state.runtimeType}');

            if (state is LiveTrackingError) {
              _showSnackBar(state.message, isError: true);
            } else if (state is TripCancelled) {
              _showSnackBar(LocaleKeys.myBookings_tripCancelledSuccess.tr());
              // Refresh the list
              final userId = StorageService.getString('user_id') ?? 'user_123';
              context.read<LiveTrackingBloc>().add(LoadMyBookings(userId));
            }
          },
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildBody(
                        context, state, theme, isDarkMode, responsive),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LiveTrackingState state,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    // Debug print to help diagnose the issue
    print('_buildBody called with state: ${state.runtimeType}');

    if (state is LiveTrackingLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.myBookings_loading.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (state is LiveTrackingError) {
      return Center(
        child: Padding(
          padding: responsive.padding(24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: responsive.fontSize(64),
                color: Colors.red[400],
              ),
              SizedBox(height: 24.h),
              Text(
                'Error loading bookings',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                state.message,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  final userId =
                      StorageService.getString('user_id') ?? 'user_123';
                  context.read<LiveTrackingBloc>().add(LoadMyBookings(userId));
                },
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is MyBookingsLoaded) {
      print(
          'MyBookingsLoaded state - bookings count: ${state.bookings.length}');
      if (state.bookings.isEmpty) {
        return _buildEmptyBookings(theme, isDarkMode, responsive);
      }
      return _buildBookingsList(
        context,
        state.bookings,
        state.currentTrip,
        theme,
        isDarkMode,
        responsive,
      );
    }

    // Handle initial state or any other unknown states
    print('Showing empty bookings for state: ${state.runtimeType}');
    return _buildEmptyBookings(theme, isDarkMode, responsive);
  }

  Widget _buildEmptyBookings(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Center(
      child: Padding(
        padding: responsive.padding(24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: responsive.fontSize(64),
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              LocaleKeys.myBookings_noBookings.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.myBookings_noBookingsDesc.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: Text(LocaleKeys.myBookings_bookFirstTrip.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    List<LiveTrip> bookings,
    LiveTrip? currentTrip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    // Separate active and completed bookings
    final activeBookings = bookings.where((trip) => trip.isActive).toList();
    final completedBookings = bookings.where((trip) => !trip.isActive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        final userId = StorageService.getString('user_id') ?? 'user_123';
        context.read<LiveTrackingBloc>().add(LoadMyBookings(userId));
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: responsive.padding(16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentTrip != null) ...[
                _buildCurrentTripCard(
                  context,
                  currentTrip,
                  theme,
                  isDarkMode,
                  responsive,
                ),
                SizedBox(height: 24.h),
              ],
              if (activeBookings.isNotEmpty) ...[
                _buildSectionHeader(
                  LocaleKeys.myBookings_activeBookings.tr(),
                  theme,
                  isDarkMode,
                  responsive,
                ),
                SizedBox(height: 16.h),
                ...activeBookings.map((trip) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildBookingCard(
                        context,
                        trip,
                        theme,
                        isDarkMode,
                        responsive,
                      ),
                    )),
                SizedBox(height: 24.h),
              ],
              if (completedBookings.isNotEmpty) ...[
                _buildSectionHeader(
                  LocaleKeys.myBookings_pastBookings.tr(),
                  theme,
                  isDarkMode,
                  responsive,
                ),
                SizedBox(height: 16.h),
                ...completedBookings.map((trip) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildBookingCard(
                        context,
                        trip,
                        theme,
                        isDarkMode,
                        responsive,
                      ),
                    )),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTripCard(
    BuildContext context,
    LiveTrip currentTrip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: responsive.fontSize(20),
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.myBookings_currentTrip.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currentTrip.statusText,
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: Colors.white,
                size: responsive.fontSize(16),
              ),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: Text(
                  currentTrip.pickupLocation.name,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: responsive.fontSize(16),
              ),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: Text(
                  currentTrip.dropoffLocation.name,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToTripTracking(currentTrip),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(LocaleKeys.myBookings_trackLive.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.fontSize(18),
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    final statusColor = _getStatusColor(trip.status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          onTap: () => _navigateToTripTracking(trip),
          child: Padding(
            padding: responsive.padding(16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(12),
                        vertical: responsive.spacing(6),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(trip.status),
                            color: statusColor,
                            size: responsive.fontSize(14),
                          ),
                          SizedBox(width: responsive.spacing(4)),
                          Text(
                            trip.statusText,
                            style: TextStyle(
                              fontSize: responsive.fontSize(12),
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd').format(trip.bookingTime),
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(12)),
                _buildRouteInfo(trip, responsive, isDarkMode),
                SizedBox(height: responsive.spacing(12)),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: theme.colorScheme.primary,
                      size: responsive.fontSize(16),
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      '${trip.totalAmount.toStringAsFixed(2)} OMR',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (trip.isActive)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        size: responsive.fontSize(16),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(
      LiveTrip trip, ResponsiveUtils responsive, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radio_button_checked,
                    color: Colors.green,
                    size: responsive.fontSize(14),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Text(
                      trip.pickupLocation.name,
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(8)),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: responsive.fontSize(14),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Text(
                      trip.dropoffLocation.name,
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (trip.estimatedArrival != null)
              Text(
                DateFormat('HH:mm').format(trip.estimatedArrival!),
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            SizedBox(height: responsive.spacing(2)),
            Text(
              '${trip.distance.toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return Colors.orange;
      case TripStatus.accepted:
        return Colors.blue;
      case TripStatus.driverEnRoute:
        return Colors.purple;
      case TripStatus.driverArrived:
        return Colors.indigo;
      case TripStatus.inProgress:
        return Colors.green;
      case TripStatus.completed:
        return Colors.teal;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return Icons.hourglass_empty;
      case TripStatus.accepted:
        return Icons.check_circle;
      case TripStatus.driverEnRoute:
        return Icons.directions_car;
      case TripStatus.driverArrived:
        return Icons.location_on;
      case TripStatus.inProgress:
        return Icons.play_circle;
      case TripStatus.completed:
        return Icons.check_circle_outline;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }
}
