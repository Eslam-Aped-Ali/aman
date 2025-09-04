import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../data/datasources/booking_local_data_source.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/usecases/create_booking.dart';
import '../../../domain/usecases/get_current_location.dart';
import '../../../domain/usecases/get_popular_locations.dart';
import '../../../domain/usecases/search_locations.dart';
import '../../bloc/booking_bloc.dart';
import '../../bloc/booking_event.dart';
import '../../bloc/booking_state.dart';
import 'trip_booking_screen.dart';

class BookNowScreen extends StatefulWidget {
  const BookNowScreen({super.key});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late BookingBloc _bookingBloc;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupBloc();
    _loadPopularLocations();
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
    final dataSource = BookingLocalDataSourceImpl();
    final repository = BookingRepositoryImpl(localDataSource: dataSource);

    _bookingBloc = BookingBloc(
      getPopularLocationsUseCase: GetPopularLocationsUseCase(repository),
      searchLocationsUseCase: SearchLocationsUseCase(repository),
      createBookingUseCase: CreateBookingUseCase(repository),
      getCurrentLocationUseCase: GetCurrentLocationUseCase(repository),
    );
  }

  void _loadPopularLocations() {
    _bookingBloc.add(const LoadPopularLocations());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bookingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocProvider.value(
      value: _bookingBloc,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDarkMode, responsive),
              Expanded(
                child: _buildBookingContent(
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
                Icons.book_online,
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
                    'booking.bookYourTrip'.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(22),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    'booking.selectLocationAndTrip'.tr(),
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

  Widget _buildBookingContent(BuildContext context, bool isDarkMode,
      bool isArabic, ResponsiveUtils responsive) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return _buildLoadingState(responsive);
        } else if (state is BookingError) {
          return _buildErrorState(state.message, responsive);
        } else if (state is LocationsLoaded) {
          return _buildLocationsContent(
              state, isDarkMode, isArabic, responsive);
        } else if (state is BookingCreated) {
          return _buildBookingSuccessState(state, responsive);
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
            'common.loading'.tr(),
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
            onPressed: () => _bookingBloc.add(const LoadPopularLocations()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSuccessState(
      BookingCreated state, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: responsive.padding(24, 24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: responsive.fontSize(80),
              color: Colors.green,
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          Text(
            'booking.bookingCreated'.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          Text(
            '${'booking.bookingId'.tr()}: ${state.booking.id}',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: responsive.spacing(32)),
          ElevatedButton(
            onPressed: () => _bookingBloc.add(const LoadPopularLocations()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('booking.bookAnother'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsContent(LocationsLoaded state, bool isDarkMode,
      bool isArabic, ResponsiveUtils responsive) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
        child: Column(
          children: [
            // Quick action cards
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'booking.fromCurrentLocation'.tr(),
                    Icons.my_location,
                    () => _bookingBloc.add(const GetCurrentLocation()),
                    isDarkMode,
                    responsive,
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: _buildQuickActionCard(
                    'trips.availableTrips'.tr(),
                    Icons.directions_bus,
                    () => Navigator.of(context).pushNamed('/trips'),
                    isDarkMode,
                    responsive,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(20)),

            // Popular locations section
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                'booking.popularLocations'.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: responsive.spacing(16)),

            // Search bar
            CupertinoSearchTextField(
              placeholder: 'booking.searchLocationPlaceholder'.tr(),
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
                  _bookingBloc.add(const LoadPopularLocations());
                } else {
                  _bookingBloc.add(SearchLocations(value));
                }
              },
            ),
            SizedBox(height: responsive.spacing(16)),

            // Locations list
            Expanded(
              child: state.isSearching
                  ? _buildLoadingState(responsive)
                  : _buildLocationsList(
                      state.locations, isDarkMode, isArabic, responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          child: Padding(
            padding: responsive.padding(16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: responsive.padding(12, 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: responsive.fontSize(24),
                  ),
                ),
                SizedBox(height: responsive.spacing(12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsList(
    List locations,
    bool isDarkMode,
    bool isArabic,
    ResponsiveUtils responsive,
  ) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return _buildLocationCard(
          location,
          isDarkMode,
          isArabic,
          responsive,
        );
      },
    );
  }

  Widget _buildLocationCard(
    location,
    bool isDarkMode,
    bool isArabic,
    ResponsiveUtils responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTripBooking(location),
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          child: Padding(
            padding: responsive.padding(16, 12),
            child: Row(
              children: [
                Container(
                  padding: responsive.padding(10, 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(10)),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: responsive.fontSize(20),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? location.nameAr : location.name,
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        isArabic ? location.addressAr : location.address,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: responsive.fontSize(16),
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTripBooking(location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripBookingScreen(
          selectedLocation: location,
        ),
      ),
    );
  }
}
