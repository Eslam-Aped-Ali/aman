import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../data/datasources/live_tracking_local_data_source.dart';
import '../../../data/repositories/live_tracking_repository_impl.dart';
import '../../../domain/usecases/get_current_trip.dart';
import '../../../domain/usecases/get_my_bookings.dart';
import '../../../domain/usecases/cancel_trip.dart';
import '../../../domain/usecases/get_trip_updates.dart';
import '../../bloc/live_tracking_bloc.dart';
import '../../bloc/live_tracking_event.dart';
import '../../bloc/live_tracking_state.dart';
import '../../../domain/entities/live_trip.dart';

class LiveTrackingScreen extends StatefulWidget {
  final LiveTrip? initialTrip;

  const LiveTrackingScreen({
    super.key,
    this.initialTrip,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
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

  void _makePhoneCall(String phoneNumber) {
    HapticFeedback.selectionClick();
    _showSnackBar('Calling $phoneNumber...');
    // In real app: launch('tel:$phoneNumber');
  }

  void _sendMessage(String phoneNumber) {
    HapticFeedback.selectionClick();
    _showSnackBar('Opening messaging app...');
    // In real app: launch('sms:$phoneNumber');
  }

  void _cancelTrip(BuildContext context, String tripId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.liveTracking_cancelTrip.tr()),
        content: Text(LocaleKeys.liveTracking_cancelTripConfirmation.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.common_no.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(LocaleKeys.common_yes.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<LiveTrackingBloc>().add(CancelTrip(tripId));
    }
  }

  void _showDriverRatingDialog(BuildContext context, LiveTrip trip) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.liveTracking_rateDriver.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(LocaleKeys.liveTracking_rateDriverDesc.tr()),
            SizedBox(height: 16.h),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                        HapticFeedback.selectionClick();
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32.w,
                      ),
                    );
                  }),
                );
              },
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: LocaleKeys.liveTracking_addComment.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LiveTrackingBloc>().add(
                    RateDriver(trip.id, rating, commentController.text.trim()),
                  );
              Navigator.of(context).pop();
            },
            child: Text(LocaleKeys.common_submit.tr()),
          ),
        ],
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

        // Load initial data
        if (widget.initialTrip != null) {
          bloc.add(SelectBookingForTracking(widget.initialTrip!));
        } else {
          final userId = StorageService.getString('user_id') ?? 'user_123';
          bloc.add(LoadCurrentTrip(userId));
        }

        return bloc;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        body: SafeArea(
          child: BlocConsumer<LiveTrackingBloc, LiveTrackingState>(
            listener: (context, state) {
              if (state is LiveTrackingError) {
                _showSnackBar(state.message, isError: true);
              } else if (state is TripCancelled) {
                _showSnackBar(
                    LocaleKeys.liveTracking_tripCancelledSuccess.tr());
              } else if (state is DriverContacted) {
                _showSnackBar(
                    LocaleKeys.liveTracking_driverContactedSuccess.tr());
              } else if (state is DriverRated) {
                _showSnackBar(LocaleKeys.liveTracking_driverRatedSuccess.tr());
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
                      child: Column(
                        children: [
                          _buildHeader(context, isDarkMode, responsive),
                          Expanded(
                            child: _buildBody(
                                context, state, theme, isDarkMode, responsive),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: responsive.padding(20, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.black]
                : [AppColors.primary.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: responsive.padding(12, 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: responsive.fontSize(24),
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.liveTracking_title.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(22),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    LocaleKeys.liveTracking_trackYourTrip.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                final userId =
                    StorageService.getString('user_id') ?? 'user_123';
                context
                    .read<LiveTrackingBloc>()
                    .add(RefreshCurrentTrip(userId));
              },
              icon: Icon(
                Icons.refresh,
                color: AppColors.primary,
                size: responsive.fontSize(24),
              ),
            ),
          ],
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
              LocaleKeys.liveTracking_loading.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CurrentTripLoaded) {
      if (state.currentTrip == null) {
        return _buildNoActiveTrip(theme, isDarkMode, responsive);
      }
      return _buildTripDetails(
          context, state.currentTrip!, theme, isDarkMode, responsive);
    }

    if (state is TripTrackingActive) {
      return _buildActiveTracking(
          context, state.currentTrip, theme, isDarkMode, responsive);
    }

    return _buildNoActiveTrip(theme, isDarkMode, responsive);
  }

  Widget _buildNoActiveTrip(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Center(
      child: Padding(
        padding: responsive.padding(24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: responsive.fontSize(64),
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              LocaleKeys.liveTracking_noActiveTrip.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.liveTracking_noActiveTripDesc.tr(),
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
              label: Text(LocaleKeys.liveTracking_bookNewTrip.tr()),
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

  Widget _buildTripDetails(
    BuildContext context,
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: responsive.padding(16, 16),
        child: Column(
          children: [
            _buildTripStatusCard(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            _buildTripRouteCard(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            if (trip.driver != null)
              _buildDriverCard(context, trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            _buildTripInfoCard(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            _buildActionButtons(context, trip, theme, isDarkMode, responsive),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTracking(
    BuildContext context,
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: responsive.padding(16, 16),
        child: Column(
          children: [
            _buildLiveStatusCard(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            _buildMapPlaceholder(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            _buildTripRouteCard(trip, theme, isDarkMode, responsive),
            SizedBox(height: 16.h),
            if (trip.driver != null)
              _buildDriverCard(context, trip, theme, isDarkMode, responsive),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStatusCard(
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    final statusColor = _getStatusColor(trip.status);

    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(12)),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                ),
                child: Icon(
                  _getStatusIcon(trip.status),
                  color: statusColor,
                  size: responsive.fontSize(24),
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.statusText,
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      'Trip ID: ${trip.id}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          LinearProgressIndicator(
            value: trip.progress,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusCard(
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.spacing(8)),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Icon(
                  Icons.live_tv,
                  color: Colors.red,
                  size: responsive.fontSize(16),
                ),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                LocaleKeys.liveTracking_liveTracking.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.statusText,
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (trip.estimatedArrival != null) ...[
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        'ETA: ${DateFormat('HH:mm').format(trip.estimatedArrival!)}',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      width: double.infinity,
      height: 200.h,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: responsive.fontSize(48),
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            LocaleKeys.liveTracking_mapPlaceholder.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            LocaleKeys.liveTracking_realTimeLocation.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripRouteCard(
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.liveTracking_route.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildLocationItem(
            icon: Icons.radio_button_checked,
            iconColor: Colors.green,
            title: trip.pickupLocation.name,
            subtitle: trip.pickupLocation.address,
            responsive: responsive,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildRouteConnector(responsive),
          SizedBox(height: responsive.spacing(12)),
          _buildLocationItem(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: trip.dropoffLocation.name,
            subtitle: trip.dropoffLocation.address,
            responsive: responsive,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.straighten,
                label: '${trip.distance.toStringAsFixed(1)} km',
                responsive: responsive,
                theme: theme,
              ),
              SizedBox(width: responsive.spacing(12)),
              _buildInfoChip(
                icon: Icons.schedule,
                label: '${trip.estimatedDuration} min',
                responsive: responsive,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    final driver = trip.driver!;

    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.liveTracking_driverInfo.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person,
                  size: 30.w,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.displayName,
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: responsive.fontSize(16),
                          color: Colors.amber,
                        ),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          '${driver.ratingText} (${driver.totalTrips} trips)',
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      '${driver.vehicleInfo} • ${driver.licensePlate}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trip.canContactDriver) ...[
            SizedBox(height: responsive.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(driver.phone),
                    icon: const Icon(Icons.phone),
                    label: Text(LocaleKeys.liveTracking_call.tr()),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendMessage(driver.phone),
                    icon: const Icon(Icons.message),
                    label: Text(LocaleKeys.liveTracking_message.tr()),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.liveTracking_tripDetails.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoRow(
            LocaleKeys.liveTracking_bookingTime.tr(),
            DateFormat('MMM dd, HH:mm').format(trip.bookingTime),
            responsive,
            isDarkMode,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInfoRow(
            LocaleKeys.liveTracking_paymentMethod.tr(),
            trip.paymentMethod.toUpperCase(),
            responsive,
            isDarkMode,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInfoRow(
            LocaleKeys.liveTracking_totalAmount.tr(),
            '${trip.totalAmount.toStringAsFixed(2)} OMR',
            responsive,
            isDarkMode,
          ),
          if (trip.specialInstructions != null) ...[
            SizedBox(height: responsive.spacing(12)),
            _buildInfoRow(
              LocaleKeys.liveTracking_specialInstructions.tr(),
              trip.specialInstructions!,
              responsive,
              isDarkMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    LiveTrip trip,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      children: [
        if (trip.canCancel) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelTrip(context, trip.id),
              icon: const Icon(Icons.cancel),
              label: Text(LocaleKeys.liveTracking_cancelTrip.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (trip.status == TripStatus.completed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDriverRatingDialog(context, trip),
              icon: const Icon(Icons.star),
              label: Text(LocaleKeys.liveTracking_rateDriver.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required ResponsiveUtils responsive,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: responsive.fontSize(20),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: responsive.spacing(2)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteConnector(ResponsiveUtils responsive) {
    return Padding(
      padding: EdgeInsets.only(left: responsive.spacing(10)),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            width: 2.w,
            height: 8.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(1.r),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ResponsiveUtils responsive,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsive.fontSize(14),
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: responsive.spacing(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ResponsiveUtils responsive,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
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
