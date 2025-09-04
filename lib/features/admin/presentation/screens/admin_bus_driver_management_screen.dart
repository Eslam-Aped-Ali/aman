import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../core/shared/utils/responsive/responsive_utils.dart';

class AdminBusDriverManagementScreen extends StatefulWidget {
  const AdminBusDriverManagementScreen({super.key});

  @override
  State<AdminBusDriverManagementScreen> createState() =>
      _AdminBusDriverManagementScreenState();
}

class _AdminBusDriverManagementScreenState
    extends State<AdminBusDriverManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for bus form
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _busModelController = TextEditingController();
  final TextEditingController _busLicensePlateController =
      TextEditingController();
  final TextEditingController _busCapacityController = TextEditingController();

  // Mock data for buses
  List<Map<String, dynamic>> buses = [
    {
      'id': 'BUS001',
      'number': 'A001',
      'model': 'Mercedes Sprinter',
      'licensePlate': 'ABC-123',
      'capacity': 30,
      'status': 'active',
      'driverId': 'DRV001',
      'driverName': 'Ahmed Al-Rashid',
    },
    {
      'id': 'BUS002',
      'number': 'A002',
      'model': 'Ford Transit',
      'licensePlate': 'XYZ-789',
      'capacity': 25,
      'status': 'active',
      'driverId': null,
      'driverName': null,
    },
    {
      'id': 'BUS003',
      'number': 'A003',
      'model': 'Toyota Hiace',
      'licensePlate': 'DEF-456',
      'capacity': 15,
      'status': 'maintenance',
      'driverId': null,
      'driverName': null,
    },
  ];

  // Mock data for drivers
  List<Map<String, dynamic>> drivers = [
    {
      'id': 'DRV001',
      'name': 'Ahmed Al-Rashid',
      'licenseNumber': 'LIC001',
      'experienceYears': 5,
      'status': 'assigned',
      'rating': 4.8,
      'busId': 'BUS001',
      'phone': '+968 9123 4567',
    },
    {
      'id': 'DRV002',
      'name': 'Mohammed Al-Balushi',
      'licenseNumber': 'LIC002',
      'experienceYears': 3,
      'status': 'available',
      'rating': 4.6,
      'busId': null,
      'phone': '+968 9876 5432',
    },
    {
      'id': 'DRV003',
      'name': 'Salem Al-Kindi',
      'licenseNumber': 'LIC003',
      'experienceYears': 8,
      'status': 'available',
      'rating': 4.9,
      'busId': null,
      'phone': '+968 9555 1234',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busNumberController.dispose();
    _busModelController.dispose();
    _busLicensePlateController.dispose();
    _busCapacityController.dispose();
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
                Tab(text: 'Buses', icon: Icon(Icons.directions_bus)),
                Tab(text: 'Drivers', icon: Icon(Icons.person)),
                Tab(text: 'Assignments', icon: Icon(Icons.link)),
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
                _buildBusesTab(theme, isDarkMode, responsive),
                _buildDriversTab(theme, isDarkMode, responsive),
                _buildAssignmentsTab(theme, isDarkMode, responsive),
                _buildBusesTab(theme, isDarkMode, responsive),
                _buildDriversTab(theme, isDarkMode, responsive),
                _buildAssignmentsTab(theme, isDarkMode, responsive),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBusesTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        children: [
          _buildSearchBar('Search buses...', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          ...buses
              .map((bus) => _buildBusCard(bus, theme, isDarkMode, responsive)),
        ],
      ),
    );
  }

  Widget _buildDriversTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        children: [
          _buildSearchBar('Search drivers...', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          ...drivers.map((driver) =>
              _buildDriverCard(driver, theme, isDarkMode, responsive)),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final assignedBuses =
        buses.where((bus) => bus['driverId'] != null).toList();
    final unassignedBuses = buses
        .where((bus) => bus['driverId'] == null && bus['status'] == 'active')
        .toList();
    final availableDrivers =
        drivers.where((driver) => driver['status'] == 'available').toList();

    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Current Assignments', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(12)),
          ...assignedBuses.map((bus) =>
              _buildAssignmentCard(bus, theme, isDarkMode, responsive)),
          SizedBox(height: responsive.spacing(24)),
          _buildSectionHeader(
              'Available for Assignment', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(12)),
          if (unassignedBuses.isNotEmpty && availableDrivers.isNotEmpty)
            ...unassignedBuses.map((bus) => _buildUnassignedBusCard(
                bus, availableDrivers, theme, isDarkMode, responsive))
          else
            Container(
              padding: responsive.padding(20, 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
              child: Center(
                child: Text(
                  unassignedBuses.isEmpty
                      ? 'All buses are assigned'
                      : 'No available drivers',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      String hint, bool isDarkMode, ResponsiveUtils responsive) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus, ThemeData theme,
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
              Row(
                children: [
                  Container(
                    padding: responsive.padding(8, 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(8)),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: AppColors.primary,
                      size: responsive.fontSize(20),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus ${bus['number']}',
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        bus['model'],
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildBusStatusBadge(bus['status'], responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            children: [
              _buildInfoChip(
                  Icons.badge, bus['licensePlate'], isDarkMode, responsive),
              SizedBox(width: responsive.spacing(8)),
              _buildInfoChip(Icons.people, '${bus['capacity']} seats',
                  isDarkMode, responsive),
            ],
          ),
          if (bus['driverId'] != null) ...[
            SizedBox(height: responsive.spacing(8)),
            _buildInfoChip(
                Icons.person, bus['driverName'], isDarkMode, responsive),
          ],
          SizedBox(height: responsive.spacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editBus(bus),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              SizedBox(width: responsive.spacing(8)),
              TextButton.icon(
                onPressed: () => _deleteBus(bus['id']),
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

  Widget _buildDriverCard(Map<String, dynamic> driver, ThemeData theme,
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
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: responsive.fontSize(20),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['name'],
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: responsive.spacing(4)),
                          Text(
                            '${driver['rating']}',
                            style: TextStyle(
                              fontSize: responsive.fontSize(14),
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              _buildDriverStatusBadge(driver['status'], responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            children: [
              _buildInfoChip(
                  Icons.badge, driver['licenseNumber'], isDarkMode, responsive),
              SizedBox(width: responsive.spacing(8)),
              _buildInfoChip(Icons.work, '${driver['experienceYears']} years',
                  isDarkMode, responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          _buildInfoChip(Icons.phone, driver['phone'], isDarkMode, responsive),
          if (driver['busId'] != null) ...[
            SizedBox(height: responsive.spacing(8)),
            _buildInfoChip(Icons.directions_bus, 'Bus ${driver['busId']}',
                isDarkMode, responsive),
          ],
          SizedBox(height: responsive.spacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editDriver(driver),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              SizedBox(width: responsive.spacing(8)),
              TextButton.icon(
                onPressed: () => _deleteDriver(driver['id']),
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

  Widget _buildAssignmentCard(Map<String, dynamic> bus, ThemeData theme,
      bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: responsive.padding(12, 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
            ),
            child: Icon(Icons.link,
                color: Colors.green, size: responsive.fontSize(20)),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus ${bus['number']} ↔ ${bus['driverName']}',
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${bus['model']} • ${bus['capacity']} seats',
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _unassignDriver(bus['id'], bus['driverId']),
            child: const Text('Unassign', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedBusCard(
      Map<String, dynamic> bus,
      List<Map<String, dynamic>> availableDrivers,
      ThemeData theme,
      bool isDarkMode,
      ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: responsive.padding(8, 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Icon(Icons.directions_bus,
                    color: Colors.orange, size: responsive.fontSize(20)),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus ${bus['number']} (${bus['model']})',
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Available for assignment',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Text(
            'Available Drivers:',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Wrap(
            spacing: responsive.spacing(8),
            runSpacing: responsive.spacing(8),
            children: availableDrivers
                .map((driver) => GestureDetector(
                      onTap: () => _assignDriver(
                          bus['id'], driver['id'], driver['name']),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(12),
                          vertical: responsive.spacing(6),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(responsive.spacing(16)),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              driver['name'],
                              style: TextStyle(
                                fontSize: responsive.fontSize(12),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: responsive.spacing(4)),
                            Icon(Icons.add, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, bool isDarkMode, ResponsiveUtils responsive) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.fontSize(18),
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildBusStatusBadge(String status, ResponsiveUtils responsive) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      case 'inactive':
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

  Widget _buildDriverStatusBadge(String status, ResponsiveUtils responsive) {
    Color color;
    switch (status) {
      case 'available':
        color = Colors.green;
        break;
      case 'assigned':
        color = Colors.blue;
        break;
      case 'inactive':
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

  Widget _buildInfoChip(
      IconData icon, String text, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          SizedBox(width: responsive.spacing(4)),
          Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Add Bus'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddBusForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Add Driver'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddDriverForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBusForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Bus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _busNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bus Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _busModelController,
                decoration: const InputDecoration(
                  labelText: 'Bus Model',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _busLicensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _busCapacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addBus();
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDriverForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add driver form coming soon!')),
    );
  }

  void _addBus() {
    if (_busNumberController.text.isNotEmpty &&
        _busModelController.text.isNotEmpty &&
        _busLicensePlateController.text.isNotEmpty &&
        _busCapacityController.text.isNotEmpty) {
      final newBus = {
        'id': 'BUS${DateTime.now().millisecondsSinceEpoch}',
        'number': _busNumberController.text,
        'model': _busModelController.text,
        'licensePlate': _busLicensePlateController.text,
        'capacity': int.parse(_busCapacityController.text),
        'status': 'active',
        'driverId': null,
        'driverName': null,
      };

      setState(() {
        buses.add(newBus);
      });

      // Clear form
      _busNumberController.clear();
      _busModelController.clear();
      _busLicensePlateController.clear();
      _busCapacityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus added successfully!')),
      );
    }
  }

  void _assignDriver(String busId, String driverId, String driverName) {
    setState(() {
      // Update bus
      final busIndex = buses.indexWhere((bus) => bus['id'] == busId);
      if (busIndex != -1) {
        buses[busIndex]['driverId'] = driverId;
        buses[busIndex]['driverName'] = driverName;
      }

      // Update driver
      final driverIndex =
          drivers.indexWhere((driver) => driver['id'] == driverId);
      if (driverIndex != -1) {
        drivers[driverIndex]['status'] = 'assigned';
        drivers[driverIndex]['busId'] = busId;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Driver $driverName assigned to bus successfully!')),
    );
  }

  void _unassignDriver(String busId, String driverId) {
    setState(() {
      // Update bus
      final busIndex = buses.indexWhere((bus) => bus['id'] == busId);
      if (busIndex != -1) {
        buses[busIndex]['driverId'] = null;
        buses[busIndex]['driverName'] = null;
      }

      // Update driver
      final driverIndex =
          drivers.indexWhere((driver) => driver['id'] == driverId);
      if (driverIndex != -1) {
        drivers[driverIndex]['status'] = 'available';
        drivers[driverIndex]['busId'] = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Driver unassigned successfully!')),
    );
  }

  void _editBus(Map<String, dynamic> bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit bus feature coming soon!')),
    );
  }

  void _deleteBus(String busId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                buses.removeWhere((bus) => bus['id'] == busId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bus deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editDriver(Map<String, dynamic> driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit driver feature coming soon!')),
    );
  }

  void _deleteDriver(String driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Driver'),
        content: const Text('Are you sure you want to delete this driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                drivers.removeWhere((driver) => driver['id'] == driverId);
                // Also unassign from any buses
                for (var bus in buses) {
                  if (bus['driverId'] == driverId) {
                    bus['driverId'] = null;
                    bus['driverName'] = null;
                  }
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Driver deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
