import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../data/datasources/trips_local_data_source.dart';
import '../../../data/repositories/trips_repository_impl.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/usecases/get_available_trips.dart';
import '../../../domain/usecases/get_popular_trips.dart';
import '../../../domain/usecases/search_trips.dart';
import '../../bloc/trips_bloc.dart';
import '../../bloc/trips_event.dart';
import '../../bloc/trips_state.dart';
import '../widgets/trips_filter_widget.dart';
import '../../../../../passenger/booking/presentation/view/screens/trip_booking_screen.dart';

class AvailableTripsScreen extends StatefulWidget {
  const AvailableTripsScreen({super.key});

  @override
  State<AvailableTripsScreen> createState() => _AvailableTripsScreenState();
}

class _AvailableTripsScreenState extends State<AvailableTripsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  late TripsBloc _tripsBloc;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupBloc();
    _loadTrips();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
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
  }

  void _setupBloc() {
    final dataSource = TripsLocalDataSourceImpl();
    final repository = TripsRepositoryImpl(localDataSource: dataSource);

    _tripsBloc = TripsBloc(
      getAvailableTripsUseCase: GetAvailableTripsUseCase(repository),
      getPopularTripsUseCase: GetPopularTripsUseCase(repository),
      searchTripsUseCase: SearchTripsUseCase(repository),
    );
  }

  void _loadTrips() {
    _tripsBloc.add(const LoadAvailableTrips());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _tripsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocProvider.value(
      value: _tripsBloc,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDarkMode, responsive),
              _buildSearchSection(context, isDarkMode, responsive),
              _buildFilterChips(context, isDarkMode, responsive),
              Expanded(
                child: _buildTripsContent(
                    context, isDarkMode, isArabic, responsive),
              ),
            ],
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
                Icons.directions_bus,
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
                    LocaleKeys.trips_availableTrips.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(22),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    LocaleKeys.trips_findYourPerfectTrip.tr(),
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
      ),
    );
  }

  Widget _buildSearchSection(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: responsive.spacing(20),
          vertical: responsive.spacing(16),
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: LocaleKeys.trips_searchPlaceholder.tr(),
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: AppColors.primary,
                  size: responsive.fontSize(20),
                ),
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                placeholderStyle: TextStyle(
                  fontSize: responsive.fontSize(16),
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                ),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.spacing(14),
                  horizontal: responsive.spacing(16),
                ),
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    _tripsBloc.add(const LoadAvailableTrips());
                  } else {
                    _tripsBloc.add(SearchTrips(value));
                  }
                },
              ),
            ),
            SizedBox(width: responsive.spacing(12)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFilterBottomSheet(context),
                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  child: Padding(
                    padding: responsive.padding(12, 12),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: responsive.fontSize(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return BlocBuilder<TripsBloc, TripsState>(
      builder: (context, state) {
        if (state is TripsLoaded && state.currentFilter?.hasFilters == true) {
          return SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: responsive.spacing(8),
                      runSpacing: responsive.spacing(8),
                      children: [
                        _buildFilterChip(
                          LocaleKeys.trips_filtersApplied.tr(),
                          isDarkMode,
                          responsive,
                          onRemove: () => _tripsBloc.add(const ClearFilter()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(
      String label, bool isDarkMode, ResponsiveUtils responsive,
      {VoidCallback? onRemove}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(20)),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: responsive.spacing(4)),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: responsive.fontSize(16),
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripsContent(BuildContext context, bool isDarkMode,
      bool isArabic, ResponsiveUtils responsive) {
    return BlocBuilder<TripsBloc, TripsState>(
      builder: (context, state) {
        if (state is TripsLoading) {
          return _buildLoadingState(responsive);
        } else if (state is TripsError) {
          return _buildErrorState(state.message, responsive);
        } else if (state is TripsEmpty) {
          return _buildEmptyState(state.message, responsive);
        } else if (state is TripsLoaded) {
          return _buildTripsList(state.trips, isDarkMode, isArabic, responsive);
        }
        return _buildLoadingState(responsive);
      },
    );
  }

  Widget _buildLoadingState(ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.fontSize(50),
            height: responsive.fontSize(50),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            LocaleKeys.common_loading.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: responsive.fontSize(80),
            color: Colors.red[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(16)),
          ElevatedButton(
            onPressed: () => _tripsBloc.add(const RefreshTrips()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: responsive.fontSize(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, bool isDarkMode, bool isArabic,
      ResponsiveUtils responsive) {
    return RefreshIndicator(
      onRefresh: () async => _tripsBloc.add(const RefreshTrips()),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(20),
          vertical: responsive.spacing(16),
        ),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return SlideTransition(
            position: _slideAnimation,
            child: _buildTripCard(trip, isDarkMode, isArabic, responsive),
          );
        },
      ),
    );
  }

  Widget _buildTripCard(
      Trip trip, bool isDarkMode, bool isArabic, ResponsiveUtils responsive) {
    final isLowAvailability = trip.isLowAvailability;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: responsive.padding(16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with route info
            Row(
              children: [
                Container(
                  padding: responsive.padding(10, 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(10)),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
                    size: responsive.fontSize(22),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? '${trip.fromLocationAr} → ${trip.toLocationAr}'
                            : '${('locations.${trip.fromLocation}').tr()} → ${('locations.${trip.toLocation}').tr()}',
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        trip.operatorName,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trip.isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(8),
                      vertical: responsive.spacing(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(12)),
                    ),
                    child: Text(
                      LocaleKeys.trips_popular.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(10),
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Trip details
            Row(
              children: [
                Expanded(
                  child: _buildTripDetail(
                    Icons.schedule,
                    LocaleKeys.trips_departure.tr(),
                    DateFormat.Hm().format(trip.departureTime),
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.access_time,
                    LocaleKeys.trips_duration.tr(),
                    trip.duration,
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.event_seat,
                    LocaleKeys.trips_available.tr(),
                    '${trip.availableSeats} ${'common.seats'.tr()}',
                    isDarkMode,
                    responsive,
                    valueColor:
                        isLowAvailability ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Bus type and amenities
            Wrap(
              spacing: responsive.spacing(8),
              runSpacing: responsive.spacing(8),
              children: [
                _buildAmenityChip(
                  'routes.busTypes.${trip.busType}'.tr(),
                  Icons.directions_bus,
                  AppColors.primary,
                  isDarkMode,
                  responsive,
                ),
                ...trip.amenities.take(3).map(
                      (amenity) => _buildAmenityChip(
                        'trips.amenities.$amenity'.tr(),
                        _getAmenityIcon(amenity),
                        Colors.green,
                        isDarkMode,
                        responsive,
                      ),
                    ),
                if (trip.amenities.length > 3)
                  _buildAmenityChip(
                    '+${trip.amenities.length - 3}',
                    Icons.more_horiz,
                    Colors.grey[600]!,
                    isDarkMode,
                    responsive,
                  ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Price and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trip.discount > 0) ...[
                        Text(
                          '${trip.price} ${'common.currency'.tr()}',
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(2)),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${trip.finalPrice.toStringAsFixed(1)} ${'common.currency'.tr()}',
                              style: TextStyle(
                                fontSize: responsive.fontSize(24),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (trip.discount > 0) ...[
                            SizedBox(width: responsive.spacing(8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.spacing(6),
                                vertical: responsive.spacing(2),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    responsive.spacing(4)),
                              ),
                              child: Text(
                                '${trip.discount.toInt()}% ${LocaleKeys.trips_off.tr()}',
                                style: TextStyle(
                                  fontSize: responsive.fontSize(10),
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.spacing(8)),
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: responsive.fontSize(16),
                          ),
                          SizedBox(width: responsive.spacing(2)),
                          Text(
                            trip.rating.toString(),
                            style: TextStyle(
                              fontSize: responsive.fontSize(14),
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacing(8)),
                      ElevatedButton(
                        onPressed: () => _bookTrip(trip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(12),
                            vertical: responsive.spacing(8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(responsive.spacing(8)),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.trips_bookNow.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(
    IconData icon,
    String label,
    String value,
    bool isDarkMode,
    ResponsiveUtils responsive, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            SizedBox(width: responsive.spacing(4)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(
    String label,
    IconData icon,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsive.fontSize(12),
            color: color,
          ),
          SizedBox(width: responsive.spacing(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(10),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'ac':
        return Icons.ac_unit;
      case 'charging':
        return Icons.battery_charging_full;
      case 'entertainment':
        return Icons.tv;
      case 'meals':
        return Icons.restaurant;
      case 'blanket':
        return Icons.bed;
      case 'pillow':
        return Icons.bedroom_parent;
      default:
        return Icons.check_circle;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: BlocProvider.value(
          value: _tripsBloc,
          child: TripsFilterWidget(
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _bookTrip(Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripBookingScreen(
          selectedLocation:
              null, // User will select locations in booking screen
        ),
      ),
    );
  }
}
