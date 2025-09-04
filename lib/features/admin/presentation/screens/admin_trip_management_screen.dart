import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../core/shared/utils/responsive/responsive_utils.dart';

class AdminTripManagementScreen extends StatefulWidget {
  const AdminTripManagementScreen({super.key});

  @override
  State<AdminTripManagementScreen> createState() =>
      _AdminTripManagementScreenState();
}

class _AdminTripManagementScreenState extends State<AdminTripManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _selectedDate;

  // Mock data for trips
  List<Map<String, dynamic>> trips = [
    {
      'id': '1',
      'name': 'Morning Route A',
      'from': 'Downtown Terminal',
      'to': 'University Campus',
      'date': '2025-08-28',
      'startTime': '08:00',
      'endTime': '09:30',
      'status': 'scheduled',
      'passengers': 25,
      'capacity': 30,
      'busId': 'BUS001',
      'driverId': 'DRV001',
    },
    {
      'id': '2',
      'name': 'Evening Route B',
      'from': 'Mall Central',
      'to': 'Residential Area',
      'date': '2025-08-28',
      'startTime': '17:00',
      'endTime': '18:15',
      'status': 'in_progress',
      'passengers': 18,
      'capacity': 25,
      'busId': 'BUS002',
      'driverId': 'DRV002',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _tripNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: Column(
        children: [
          // Tab bar without AppBar
          Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Trips', icon: Icon(Icons.list)),
                Tab(text: 'Add Trip', icon: Icon(Icons.add)),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDarkMode ? Colors.grey[400] : Colors.grey[600],
              indicatorColor: AppColors.primary,
            ),
          ),
          // Tab bar view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTripsListTab(theme, isDarkMode, responsive),
                _buildAddTripTab(theme, isDarkMode, responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsListTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(theme, isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildTripsList(theme, isDarkMode, responsive),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search trips...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('All', true, isDarkMode, responsive),
              ),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: _buildFilterChip(
                    'Scheduled', false, isDarkMode, responsive),
              ),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: _buildFilterChip(
                    'In Progress', false, isDarkMode, responsive),
              ),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: _buildFilterChip(
                    'Completed', false, isDarkMode, responsive),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDarkMode,
      ResponsiveUtils responsive) {
    return GestureDetector(
      onTap: () {
        // Handle filter selection
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(12),
          vertical: responsive.spacing(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(responsive.spacing(20)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTripsList(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      children: trips
          .map((trip) => _buildTripCard(trip, theme, isDarkMode, responsive))
          .toList(),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, ThemeData theme,
      bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
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
                child: Text(
                  trip['name'],
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              _buildStatusBadge(trip['status'], responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            children: [
              Icon(Icons.location_on,
                  size: responsive.fontSize(16), color: Colors.green),
              SizedBox(width: responsive.spacing(4)),
              Expanded(
                child: Text(
                  '${trip['from']} → ${trip['to']}',
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
            children: [
              Icon(Icons.access_time,
                  size: responsive.fontSize(16), color: Colors.blue),
              SizedBox(width: responsive.spacing(4)),
              Text(
                '${trip['startTime']} - ${trip['endTime']}',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Icon(Icons.people,
                  size: responsive.fontSize(16), color: Colors.orange),
              SizedBox(width: responsive.spacing(4)),
              Text(
                '${trip['passengers']}/${trip['capacity']}',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showTripDetails(trip),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Details'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              SizedBox(width: responsive.spacing(8)),
              TextButton.icon(
                onPressed: () => _editTrip(trip),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              SizedBox(width: responsive.spacing(8)),
              TextButton.icon(
                onPressed: () => _deleteTrip(trip['id']),
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

  Widget _buildStatusBadge(String status, ResponsiveUtils responsive) {
    Color color;
    String text;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        text = 'Scheduled';
        break;
      case 'in_progress':
        color = Colors.green;
        text = 'In Progress';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
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
        text,
        style: TextStyle(
          fontSize: responsive.fontSize(12),
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddTripTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Container(
        padding: responsive.padding(20, 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
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
              'Create New Trip',
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: responsive.spacing(20)),
            _buildTextField(
              controller: _tripNameController,
              label: 'Trip Name',
              hint: 'Enter trip name',
              icon: Icons.trip_origin,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
            SizedBox(height: responsive.spacing(16)),
            _buildTextField(
              controller: _fromController,
              label: 'From Location',
              hint: 'Enter starting location',
              icon: Icons.location_on,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
            SizedBox(height: responsive.spacing(16)),
            _buildTextField(
              controller: _toController,
              label: 'To Location',
              hint: 'Enter destination',
              icon: Icons.location_off,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
            SizedBox(height: responsive.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Date',
                    value: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                    icon: Icons.calendar_today,
                    onTap: _selectDate,
                    isDarkMode: isDarkMode,
                    responsive: responsive,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Start Time',
                    value: _startTime != null
                        ? _startTime!.format(context)
                        : 'Select time',
                    icon: Icons.access_time,
                    onTap: () => _selectTime(true),
                    isDarkMode: isDarkMode,
                    responsive: responsive,
                  ),
                ),
                SizedBox(width: responsive.spacing(16)),
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'End Time',
                    value: _endTime != null
                        ? _endTime!.format(context)
                        : 'Select time',
                    icon: Icons.schedule,
                    onTap: () => _selectTime(false),
                    isDarkMode: isDarkMode,
                    responsive: responsive,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(32)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: responsive.spacing(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                ),
                child: Text(
                  'Create Trip',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
              borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
              border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _createTrip() {
    if (_tripNameController.text.isEmpty ||
        _fromController.text.isEmpty ||
        _toController.text.isEmpty ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Create new trip
    final newTrip = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _tripNameController.text,
      'from': _fromController.text,
      'to': _toController.text,
      'date':
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      'startTime': _startTime!.format(context),
      'endTime': _endTime!.format(context),
      'status': 'scheduled',
      'passengers': 0,
      'capacity': 30,
      'busId': null,
      'driverId': null,
    };

    setState(() {
      trips.add(newTrip);
      // Clear form
      _tripNameController.clear();
      _fromController.clear();
      _toController.clear();
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
    });

    // Switch to trips list tab
    _tabController.animateTo(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip created successfully!')),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trip['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route: ${trip['from']} → ${trip['to']}'),
            Text('Date: ${trip['date']}'),
            Text('Time: ${trip['startTime']} - ${trip['endTime']}'),
            Text('Status: ${trip['status']}'),
            Text('Passengers: ${trip['passengers']}/${trip['capacity']}'),
            if (trip['busId'] != null) Text('Bus: ${trip['busId']}'),
            if (trip['driverId'] != null) Text('Driver: ${trip['driverId']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editTrip(Map<String, dynamic> trip) {
    // Navigate to edit screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit trip feature coming soon!')),
    );
  }

  void _deleteTrip(String tripId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                trips.removeWhere((trip) => trip['id'] == tripId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
