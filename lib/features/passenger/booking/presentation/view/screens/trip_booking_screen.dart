import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../trips/data/datasources/trips_local_data_source.dart';
import '../../../../trips/data/repositories/trips_repository_impl.dart';
import '../../../../trips/domain/entities/trip.dart';
import '../../../../trips/domain/usecases/get_available_trips.dart';
import '../../../../trips/domain/usecases/get_popular_trips.dart';
import '../../../../trips/domain/usecases/search_trips.dart';
import '../../../../trips/presentation/bloc/trips_bloc.dart';
import '../../../../trips/presentation/bloc/trips_event.dart';
import '../../../../trips/presentation/bloc/trips_state.dart';
import '../../../data/datasources/booking_local_data_source.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/usecases/create_booking.dart';
import '../../../domain/usecases/get_current_location.dart';
import '../../../domain/usecases/get_popular_locations.dart';
import '../../../domain/usecases/search_locations.dart';
import '../../bloc/booking_bloc.dart';
import '../../bloc/booking_event.dart';
import '../../bloc/booking_state.dart';
import 'location_selector_screen.dart';

class TripBookingScreen extends StatefulWidget {
  final LocationPoint? selectedLocation;

  const TripBookingScreen({
    super.key,
    this.selectedLocation,
  });

  @override
  State<TripBookingScreen> createState() => _TripBookingScreenState();
}

class _TripBookingScreenState extends State<TripBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TripsBloc _tripsBloc;
  late BookingBloc _bookingBloc;

  LocationPoint? selectedPickupLocation;
  LocationPoint? selectedDropoffLocation;

  @override
  void initState() {
    super.initState();
    selectedPickupLocation = widget.selectedLocation;
    _setupAnimations();
    _setupBlocs();
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

  void _setupBlocs() {
    // Trips bloc
    final tripsDataSource = TripsLocalDataSourceImpl();
    final tripsRepository =
        TripsRepositoryImpl(localDataSource: tripsDataSource);
    _tripsBloc = TripsBloc(
      getAvailableTripsUseCase: GetAvailableTripsUseCase(tripsRepository),
      getPopularTripsUseCase: GetPopularTripsUseCase(tripsRepository),
      searchTripsUseCase: SearchTripsUseCase(tripsRepository),
    );

    // Booking bloc
    final bookingDataSource = BookingLocalDataSourceImpl();
    final bookingRepository =
        BookingRepositoryImpl(localDataSource: bookingDataSource);
    _bookingBloc = BookingBloc(
      getPopularLocationsUseCase: GetPopularLocationsUseCase(bookingRepository),
      searchLocationsUseCase: SearchLocationsUseCase(bookingRepository),
      createBookingUseCase: CreateBookingUseCase(bookingRepository),
      getCurrentLocationUseCase: GetCurrentLocationUseCase(bookingRepository),
    );
  }

  void _loadTrips() {
    _tripsBloc.add(const LoadAvailableTrips());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tripsBloc.close();
    _bookingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isArabic = context.locale.languageCode == 'ar';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tripsBloc),
        BlocProvider.value(value: _bookingBloc),
      ],
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
            'booking.bookTrip'.tr(),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildLocationSelector(context, isDarkMode, responsive),
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

  Widget _buildLocationSelector(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(responsive.spacing(20)),
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
        child: Column(
          children: [
            // Pickup Location
            _buildLocationItem(
              'booking.pickupLocation'.tr(),
              selectedPickupLocation?.name ??
                  'booking.selectPickupLocation'.tr(),
              Icons.my_location,
              true,
              isDarkMode,
              responsive,
            ),

            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),

            // Drop-off Location
            _buildLocationItem(
              'booking.dropoffLocation'.tr(),
              selectedDropoffLocation?.name ??
                  'booking.selectDropoffLocation'.tr(),
              Icons.location_on,
              false,
              isDarkMode,
              responsive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(
    String title,
    String subtitle,
    IconData icon,
    bool isPickup,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToLocationSelector(isPickup),
        child: Padding(
          padding: responsive.padding(16, 16),
          child: Row(
            children: [
              Container(
                padding: responsive.padding(10, 10),
                decoration: BoxDecoration(
                  color: (isPickup ? Colors.green : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(10)),
                ),
                child: Icon(
                  icon,
                  color: isPickup ? Colors.green : AppColors.primary,
                  size: responsive.fontSize(20),
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
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
          return _buildEmptyState(responsive);
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
            onPressed: () => _tripsBloc.add(const RefreshTrips()),
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

  Widget _buildEmptyState(ResponsiveUtils responsive) {
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
            'trips.noTripsAvailable'.tr(),
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
    return SlideTransition(
      position: _slideAnimation,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(20),
          vertical: responsive.spacing(16),
        ),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, isDarkMode, isArabic, responsive);
        },
      ),
    );
  }

  Widget _buildTripCard(
      Trip trip, bool isDarkMode, bool isArabic, ResponsiveUtils responsive) {
    final canBook =
        selectedPickupLocation != null && selectedDropoffLocation != null;

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
            // Trip header
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
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Trip details
            Row(
              children: [
                Expanded(
                  child: _buildTripDetail(
                    Icons.schedule,
                    'trips.departure'.tr(),
                    DateFormat.Hm().format(trip.departureTime),
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.access_time,
                    'trips.duration'.tr(),
                    trip.duration,
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.attach_money,
                    'trips.price'.tr(),
                    '${trip.finalPrice.toStringAsFixed(1)} ${'common.currency'.tr()}',
                    isDarkMode,
                    responsive,
                    valueColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canBook ? () => _showBookingDialog(trip) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canBook ? AppColors.primary : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.spacing(8)),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.spacing(14),
                  ),
                ),
                child: Text(
                  canBook
                      ? 'trips.bookNow'.tr()
                      : 'booking.selectLocationsFirst'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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

  void _navigateToLocationSelector(bool isPickup) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSelectorScreen(
          title: isPickup
              ? 'booking.selectPickupLocation'.tr()
              : 'booking.selectDropoffLocation'.tr(),
          isPickup: isPickup,
        ),
      ),
    );

    if (result != null && result is LocationPoint) {
      setState(() {
        if (isPickup) {
          selectedPickupLocation = result;
        } else {
          selectedDropoffLocation = result;
        }
      });
    }
  }

  void _showBookingDialog(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBookingBottomSheet(trip),
    );
  }

  Widget _buildBookingBottomSheet(Trip trip) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final instructionsController = TextEditingController();

    String selectedPaymentMethod = 'Cash';
    bool requiresAssistance = false;
    int numberOfPassengers = 1;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.spacing(20)),
            topRight: Radius.circular(responsive.spacing(20)),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: responsive.spacing(12)),
              width: responsive.spacing(40),
              height: responsive.spacing(4),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(responsive.spacing(2)),
              ),
            ),

            // Header
            Padding(
              padding: responsive.padding(20, 16),
              child: Text(
                'booking.bookingDetails'.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip summary
                    Container(
                      padding: responsive.padding(16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${('locations.${trip.fromLocation}').tr()} → ${('locations.${trip.toLocation}').tr()}',
                            style: TextStyle(
                              fontSize: responsive.fontSize(16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: responsive.spacing(8)),
                          Text(
                            '${'booking.pickup'.tr()}: ${selectedPickupLocation?.name}',
                            style: TextStyle(
                              fontSize: responsive.fontSize(14),
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${'booking.dropoff'.tr()}: ${selectedDropoffLocation?.name}',
                            style: TextStyle(
                              fontSize: responsive.fontSize(14),
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: responsive.spacing(20)),

                    // Passenger details form
                    _buildTextField(
                      nameController,
                      'booking.passengerName'.tr(),
                      'booking.enterYourName'.tr(),
                      Icons.person,
                      isDarkMode,
                      responsive,
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    _buildTextField(
                      phoneController,
                      'booking.phoneNumber'.tr(),
                      'booking.enterPhoneNumber'.tr(),
                      Icons.phone,
                      isDarkMode,
                      responsive,
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    _buildTextField(
                      emailController,
                      '${'booking.email'.tr()} (${'booking.optional'.tr()})',
                      'booking.enterEmail'.tr(),
                      Icons.email,
                      isDarkMode,
                      responsive,
                      keyboardType: TextInputType.emailAddress,
                      required: false,
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    _buildTextField(
                      instructionsController,
                      '${'booking.specialInstructions'.tr()} (${'booking.optional'.tr()})',
                      'booking.enterInstructions'.tr(),
                      Icons.note,
                      isDarkMode,
                      responsive,
                      maxLines: 3,
                      required: false,
                    ),

                    SizedBox(height: responsive.spacing(20)),

                    // Payment method
                    Text(
                      'booking.paymentMethod'.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),

                    SizedBox(height: responsive.spacing(12)),

                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('booking.cash'.tr()),
                            value: 'Cash',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) =>
                                setState(() => selectedPaymentMethod = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('booking.card'.tr()),
                            value: 'Credit Card',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) =>
                                setState(() => selectedPaymentMethod = value!),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: responsive.spacing(20)),

                    // Additional options
                    SwitchListTile(
                      title: Text('booking.requiresAssistance'.tr()),
                      subtitle: Text('booking.assistanceDescription'.tr()),
                      value: requiresAssistance,
                      onChanged: (value) =>
                          setState(() => requiresAssistance = value),
                    ),

                    SizedBox(height: responsive.spacing(20)),
                  ],
                ),
              ),
            ),

            // Book button
            Container(
              padding: responsive.padding(20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createBooking(
                    trip,
                    nameController.text,
                    phoneController.text,
                    emailController.text.isEmpty ? null : emailController.text,
                    instructionsController.text.isEmpty
                        ? null
                        : instructionsController.text,
                    selectedPaymentMethod,
                    requiresAssistance,
                    numberOfPassengers,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(12)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.spacing(16),
                    ),
                  ),
                  child: Text(
                    '${'booking.confirmBooking'.tr()} - ${trip.finalPrice.toStringAsFixed(1)} ${'common.currency'.tr()}',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _createBooking(
    Trip trip,
    String name,
    String phone,
    String? email,
    String? instructions,
    String paymentMethod,
    bool requiresAssistance,
    int numberOfPassengers,
  ) {
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('booking.fillRequiredFields'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop(); // Close bottom sheet

    _bookingBloc.add(CreateBooking(
      trip: trip,
      pickupLocation: selectedPickupLocation!,
      dropoffLocation: selectedDropoffLocation!,
      passengerName: name,
      passengerPhone: phone,
      passengerEmail: email,
      specialInstructions: instructions,
      paymentMethod: paymentMethod,
      requiresSpecialAssistance: requiresAssistance,
      numberOfPassengers: numberOfPassengers,
    ));

    // Listen for booking creation success
    _bookingBloc.stream.listen((state) {
      if (state is BookingCreated) {
        _showBookingSuccess(state.booking.id);
      } else if (state is BookingError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showBookingSuccess(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('booking.bookingConfirmed'.tr()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('booking.bookingSuccessMessage'.tr()),
            SizedBox(height: 8),
            Text(
              '${'booking.bookingId'.tr()}: $bookingId',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }
}
