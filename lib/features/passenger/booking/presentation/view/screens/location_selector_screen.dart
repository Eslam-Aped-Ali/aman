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

class LocationSelectorScreen extends StatefulWidget {
  final String title;
  final bool isPickup;

  const LocationSelectorScreen({
    super.key,
    required this.title,
    this.isPickup = true,
  });

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late BookingBloc _bookingBloc;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
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
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchSection(context, isDarkMode, responsive),
              if (widget.isPickup)
                _buildCurrentLocationCard(context, isDarkMode, responsive),
              Expanded(
                child: _buildLocationsContent(
                    context, isDarkMode, isArabic, responsive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(responsive.spacing(20)),
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
        child: CupertinoSearchTextField(
          controller: _searchController,
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
      ),
    );
  }

  Widget _buildCurrentLocationCard(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
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
            onTap: () => _getCurrentLocation(),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
            child: Padding(
              padding: responsive.padding(16, 12),
              child: Row(
                children: [
                  Container(
                    padding: responsive.padding(10, 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(10)),
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: responsive.fontSize(20),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'booking.useCurrentLocation'.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          'booking.currentLocationDescription'.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(12),
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.gps_fixed,
                    size: responsive.fontSize(16),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsContent(BuildContext context, bool isDarkMode,
      bool isArabic, ResponsiveUtils responsive) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return _buildLoadingState(responsive);
        } else if (state is BookingError) {
          return _buildErrorState(state.message, responsive);
        } else if (state is LocationsLoaded) {
          return _buildLocationsList(
              state.locations, isDarkMode, isArabic, responsive);
        } else if (state is CurrentLocationLoaded) {
          Navigator.of(context).pop(state.currentLocation);
          return const SizedBox.shrink();
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

  Widget _buildLocationsList(
    List locations,
    bool isDarkMode,
    bool isArabic,
    ResponsiveUtils responsive,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(20),
              vertical: responsive.spacing(8),
            ),
            child: Text(
              _searchController.text.isEmpty
                  ? 'booking.popularLocations'.tr()
                  : 'booking.searchResults'.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),

          // Locations list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
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
            ),
          ),
        ],
      ),
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
          onTap: () => Navigator.of(context).pop(location),
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
                    _getLocationIcon(location.type),
                    color: AppColors.primary,
                    size: responsive.fontSize(20),
                  ),
                ),
                SizedBox(width: responsive.spacing(16)),
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
                if (location.type == 'popular')
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(6),
                      vertical: responsive.spacing(2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(10)),
                    ),
                    child: Text(
                      'booking.popular'.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(10),
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
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

  IconData _getLocationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'popular':
        return Icons.star;
      case 'airport':
        return Icons.flight;
      case 'mall':
        return Icons.shopping_cart;
      case 'area':
        return Icons.location_city;
      case 'current':
        return Icons.my_location;
      default:
        return Icons.location_on;
    }
  }

  void _getCurrentLocation() {
    _bookingBloc.add(const GetCurrentLocation());
  }
}
