import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../core/shared/utils/responsive/responsive_utils.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for bookings
  List<Map<String, dynamic>> bookings = [
    {
      'id': 'BOOK001',
      'passengerName': 'Fatima Al-Zahra',
      'phone': '+968 9111 2233',
      'tripId': '1',
      'tripName': 'Morning Route A',
      'pickupLocation': 'Muscat Mall',
      'dropoffLocation': 'University Campus',
      'bookingDate': '2025-08-28',
      'status': 'confirmed',
      'seatNumber': 'A12',
      'fare': 2.5,
    },
    {
      'id': 'BOOK002',
      'passengerName': 'Khalid Al-Balushi',
      'phone': '+968 9444 5566',
      'tripId': '1',
      'tripName': 'Morning Route A',
      'pickupLocation': 'City Center',
      'dropoffLocation': 'University Campus',
      'bookingDate': '2025-08-28',
      'status': 'confirmed',
      'seatNumber': 'A15',
      'fare': 3.0,
    },
    {
      'id': 'BOOK003',
      'passengerName': 'Maryam Al-Kindi',
      'phone': '+968 9777 8899',
      'tripId': '2',
      'tripName': 'Evening Route B',
      'pickupLocation': 'Mall Central',
      'dropoffLocation': 'Al-Seeb',
      'bookingDate': '2025-08-28',
      'status': 'pending',
      'seatNumber': 'B05',
      'fare': 2.0,
    },
  ];

  // Mock trip data for passenger management
  Map<String, dynamic> selectedTrip = {
    'id': '1',
    'name': 'Morning Route A',
    'from': 'Downtown Terminal',
    'to': 'University Campus',
    'passengers': [
      {
        'id': 'PASS001',
        'name': 'Fatima Al-Zahra',
        'pickupLocation': 'Muscat Mall',
        'status': 'waiting', // waiting, picked_up, dropped_off
        'seatNumber': 'A12',
      },
      {
        'id': 'PASS002',
        'name': 'Khalid Al-Balushi',
        'pickupLocation': 'City Center',
        'status': 'waiting',
        'seatNumber': 'A15',
      },
      {
        'id': 'PASS003',
        'name': 'Ahmed Al-Rashid',
        'pickupLocation': 'Grand Mall',
        'status': 'picked_up',
        'seatNumber': 'A08',
      },
      {
        'id': 'PASS004',
        'name': 'Sara Al-Mamari',
        'pickupLocation': 'Hospital',
        'status': 'dropped_off',
        'seatNumber': 'A20',
      },
    ],
  };

  String selectedBookingFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Booking Management',
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Bookings', icon: Icon(Icons.book)),
            Tab(text: 'Trip Passengers', icon: Icon(Icons.people)),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDarkMode ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsTab(theme, isDarkMode, responsive),
          _buildPassengerManagementTab(theme, isDarkMode, responsive),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _addNewBooking,
              icon: const Icon(Icons.add),
              label: const Text('Add Booking'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildBookingsTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      children: [
        _buildBookingFilters(theme, isDarkMode, responsive),
        Expanded(
          child: _buildBookingsList(theme, isDarkMode, responsive),
        ),
      ],
    );
  }

  Widget _buildBookingFilters(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final filters = ['all', 'confirmed', 'pending', 'cancelled'];

    return Container(
      margin: responsive.padding(16, 16),
      child: Row(
        children: filters
            .map((filter) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedBookingFilter = filter),
                    child: Container(
                      margin: EdgeInsets.only(right: responsive.spacing(8)),
                      padding: EdgeInsets.symmetric(
                          vertical: responsive.spacing(12)),
                      decoration: BoxDecoration(
                        color: selectedBookingFilter == filter
                            ? AppColors.primary
                            : (isDarkMode ? Colors.grey[800] : Colors.white),
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(8)),
                        border: Border.all(
                          color: selectedBookingFilter == filter
                              ? AppColors.primary
                              : (isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        filter.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w500,
                          color: selectedBookingFilter == filter
                              ? Colors.white
                              : (isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBookingsList(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final filteredBookings = selectedBookingFilter == 'all'
        ? bookings
        : bookings
            .where((booking) => booking['status'] == selectedBookingFilter)
            .toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: responsive.spacing(16)),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _buildBookingCard(booking, theme, isDarkMode, responsive);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, ThemeData theme,
      bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['passengerName'],
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      booking['tripName'],
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildBookingStatusBadge(booking['status'], responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.blue),
              SizedBox(width: responsive.spacing(8)),
              Text(
                booking['phone'],
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.green),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: Text(
                  '${booking['pickupLocation']} → ${booking['dropoffLocation']}',
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event_seat, size: 16, color: Colors.orange),
                  SizedBox(width: responsive.spacing(8)),
                  Text(
                    'Seat ${booking['seatNumber']}',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                '${booking['fare']} OMR',
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editBooking(booking),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              SizedBox(width: responsive.spacing(8)),
              TextButton.icon(
                onPressed: () => _deleteBooking(booking['id']),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerManagementTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripHeader(theme, isDarkMode, responsive),
          SizedBox(height: responsive.spacing(24)),
          _buildPassengerStatusColumns(theme, isDarkMode, responsive),
        ],
      ),
    );
  }

  Widget _buildTripHeader(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedTrip['name'],
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            '${selectedTrip['from']} → ${selectedTrip['to']}',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTripStat(
                  'Waiting',
                  selectedTrip['passengers']
                      .where((p) => p['status'] == 'waiting')
                      .length,
                  Colors.orange,
                  responsive,
                  isDarkMode),
              _buildTripStat(
                  'Picked Up',
                  selectedTrip['passengers']
                      .where((p) => p['status'] == 'picked_up')
                      .length,
                  Colors.blue,
                  responsive,
                  isDarkMode),
              _buildTripStat(
                  'Dropped Off',
                  selectedTrip['passengers']
                      .where((p) => p['status'] == 'dropped_off')
                      .length,
                  Colors.green,
                  responsive,
                  isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripStat(String label, int count, Color color,
      ResponsiveUtils responsive, bool isDarkMode) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: responsive.fontSize(24),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerStatusColumns(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final waitingPassengers = selectedTrip['passengers']
        .where((p) => p['status'] == 'waiting')
        .toList();
    final pickedUpPassengers = selectedTrip['passengers']
        .where((p) => p['status'] == 'picked_up')
        .toList();
    final droppedOffPassengers = selectedTrip['passengers']
        .where((p) => p['status'] == 'dropped_off')
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPassengerColumn(
            'Waiting',
            waitingPassengers,
            Colors.orange,
            theme,
            isDarkMode,
            responsive,
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: _buildPassengerColumn(
            'Picked Up',
            pickedUpPassengers,
            Colors.blue,
            theme,
            isDarkMode,
            responsive,
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: _buildPassengerColumn(
            'Dropped Off',
            droppedOffPassengers,
            Colors.green,
            theme,
            isDarkMode,
            responsive,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerColumn(
    String title,
    List<dynamic> passengers,
    Color color,
    ThemeData theme,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: responsive.padding(16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(responsive.spacing(16)),
                topRight: Radius.circular(responsive.spacing(16)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(title.toLowerCase().replaceAll(' ', '_')),
                  color: color,
                  size: responsive.fontSize(16),
                ),
                SizedBox(width: responsive.spacing(8)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: responsive.spacing(200)),
            child: passengers.isEmpty
                ? Padding(
                    padding: responsive.padding(16, 16),
                    child: Center(
                      child: Text(
                        'No passengers',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: responsive.fontSize(12),
                        ),
                      ),
                    ),
                  )
                : ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) => _reorderPassengers(
                        title.toLowerCase().replaceAll(' ', '_'),
                        oldIndex,
                        newIndex),
                    children: passengers.asMap().entries.map((entry) {
                      final passenger = entry.value;
                      return _buildDraggablePassengerCard(
                        passenger,
                        title.toLowerCase().replaceAll(' ', '_'),
                        color,
                        isDarkMode,
                        responsive,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePassengerCard(
    Map<String, dynamic> passenger,
    String status,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      key: ValueKey(passenger['id']),
      margin: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      child: Card(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person,
              color: color,
              size: responsive.fontSize(20),
            ),
          ),
          title: Text(
            passenger['name'],
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passenger['pickupLocation'],
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                'Seat ${passenger['seatNumber']}',
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) =>
                _changePassengerStatus(passenger['id'], value),
            itemBuilder: (context) => [
              if (status != 'waiting')
                const PopupMenuItem(
                    value: 'waiting', child: Text('Mark as Waiting')),
              if (status != 'picked_up')
                const PopupMenuItem(
                    value: 'picked_up', child: Text('Mark as Picked Up')),
              if (status != 'dropped_off')
                const PopupMenuItem(
                    value: 'dropped_off', child: Text('Mark as Dropped Off')),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'waiting':
        return Icons.schedule;
      case 'picked_up':
        return Icons.directions_bus;
      case 'dropped_off':
        return Icons.check_circle;
      default:
        return Icons.person;
    }
  }

  Widget _buildBookingStatusBadge(String status, ResponsiveUtils responsive) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: responsive.fontSize(12),
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _reorderPassengers(String status, int oldIndex, int newIndex) {
    setState(() {
      final passengers = selectedTrip['passengers']
          .where((p) => p['status'] == status)
          .toList();
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final passenger = passengers.removeAt(oldIndex);
      passengers.insert(newIndex, passenger);
      // Update the main list
      selectedTrip['passengers'].removeWhere((p) => p['status'] == status);
      selectedTrip['passengers'].addAll(passengers);
    });
  }

  void _changePassengerStatus(String passengerId, String newStatus) {
    setState(() {
      final passengerIndex =
          selectedTrip['passengers'].indexWhere((p) => p['id'] == passengerId);
      if (passengerIndex != -1) {
        selectedTrip['passengers'][passengerIndex]['status'] = newStatus;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Passenger status updated to ${newStatus.replaceAll('_', ' ')}')),
    );
  }

  void _addNewBooking() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add booking feature coming soon!')),
    );
  }

  void _editBooking(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit booking feature coming soon!')),
    );
  }

  void _deleteBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                bookings.removeWhere((booking) => booking['id'] == bookingId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
