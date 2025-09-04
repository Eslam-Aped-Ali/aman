import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../core/shared/utils/responsive/responsive_utils.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'week';

  // Mock analytics data
  final Map<String, dynamic> analyticsData = {
    'overview': {
      'totalTrips': 1247,
      'totalRevenue': 8543.50,
      'totalPassengers': 3892,
      'averageRating': 4.7,
      'activeDrivers': 156,
      'activeBuses': 89,
    },
    'tripStats': {
      'completed': 1120,
      'inProgress': 15,
      'cancelled': 112,
      'scheduled': 45,
    },
    'revenueData': [
      {'period': 'Mon', 'revenue': 1200.0},
      {'period': 'Tue', 'revenue': 1450.0},
      {'period': 'Wed', 'revenue': 1100.0},
      {'period': 'Thu', 'revenue': 1650.0},
      {'period': 'Fri', 'revenue': 1800.0},
      {'period': 'Sat', 'revenue': 2100.0},
      {'period': 'Sun', 'revenue': 1750.0},
    ],
    'busUtilization': [
      {'busId': 'BUS001', 'utilization': 85.0, 'trips': 24},
      {'busId': 'BUS002', 'utilization': 92.0, 'trips': 28},
      {'busId': 'BUS003', 'utilization': 78.0, 'trips': 19},
      {'busId': 'BUS004', 'utilization': 88.0, 'trips': 22},
    ],
    'driverPerformance': [
      {
        'driverId': 'DRV001',
        'name': 'Ahmed Al-Rashid',
        'rating': 4.9,
        'trips': 32,
        'revenue': 2150.0
      },
      {
        'driverId': 'DRV002',
        'name': 'Mohammed Al-Balushi',
        'rating': 4.7,
        'trips': 28,
        'revenue': 1890.0
      },
      {
        'driverId': 'DRV003',
        'name': 'Salem Al-Kindi',
        'rating': 4.8,
        'trips': 35,
        'revenue': 2340.0
      },
    ],
    'popularRoutes': [
      {'route': 'Downtown → University', 'trips': 245, 'revenue': 1225.0},
      {'route': 'Mall Central → Residential', 'trips': 189, 'revenue': 945.0},
      {'route': 'Airport → City Center', 'trips': 156, 'revenue': 1560.0},
      {'route': 'Hospital → Shopping District', 'trips': 134, 'revenue': 670.0},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      body: Column(
        children: [
          // Custom header with period selector
          Container(
            padding: responsive.padding(16, 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => selectedPeriod = value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'day', child: Text('Today')),
                    const PopupMenuItem(
                        value: 'week', child: Text('This Week')),
                    const PopupMenuItem(
                        value: 'month', child: Text('This Month')),
                    const PopupMenuItem(
                        value: 'year', child: Text('This Year')),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(12),
                      vertical: responsive.spacing(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getPeriodLabel(selectedPeriod),
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
              Tab(text: 'Revenue', icon: Icon(Icons.attach_money)),
              Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
              Tab(text: 'Routes', icon: Icon(Icons.route)),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor:
                isDarkMode ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: AppColors.primary,
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, isDarkMode, responsive),
                _buildRevenueTab(theme, isDarkMode, responsive),
                _buildPerformanceTab(theme, isDarkMode, responsive),
                _buildRoutesTab(theme, isDarkMode, responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final overview = analyticsData['overview'];
    final tripStats = analyticsData['tripStats'];

    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: responsive.spacing(16),
            mainAxisSpacing: responsive.spacing(16),
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Total Trips',
                overview['totalTrips'].toString(),
                Icons.directions_bus,
                Colors.blue,
                '+12%',
                isDarkMode,
                responsive,
              ),
              _buildMetricCard(
                'Revenue',
                '${overview['totalRevenue']} OMR',
                Icons.attach_money,
                Colors.green,
                '+8.5%',
                isDarkMode,
                responsive,
              ),
              _buildMetricCard(
                'Passengers',
                overview['totalPassengers'].toString(),
                Icons.people,
                Colors.orange,
                '+15%',
                isDarkMode,
                responsive,
              ),
              _buildMetricCard(
                'Avg Rating',
                overview['averageRating'].toString(),
                Icons.star,
                Colors.amber,
                '+0.2',
                isDarkMode,
                responsive,
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(24)),

          // Trip Status Chart
          _buildSectionHeader(
              'Trip Status Distribution', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildTripStatusChart(tripStats, isDarkMode, responsive),

          SizedBox(height: responsive.spacing(24)),

          // Fleet Status
          _buildSectionHeader('Fleet Status', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Expanded(
                child: _buildFleetCard(
                  'Active Drivers',
                  overview['activeDrivers'].toString(),
                  Icons.person,
                  Colors.blue,
                  isDarkMode,
                  responsive,
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: _buildFleetCard(
                  'Active Buses',
                  overview['activeBuses'].toString(),
                  Icons.directions_bus,
                  Colors.green,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final revenueData = analyticsData['revenueData'];
    final maxRevenue = revenueData
        .map((e) => e['revenue'] as double)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Summary
          Container(
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
              children: [
                Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  '${analyticsData['overview']['totalRevenue']} OMR',
                  style: TextStyle(
                    fontSize: responsive.fontSize(32),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(8),
                    vertical: responsive.spacing(4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Text(
                    '+8.5% from last $selectedPeriod',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.spacing(24)),

          // Revenue Chart
          _buildSectionHeader('Revenue Trend', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          Container(
            height: 250,
            padding: responsive.padding(20, 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(responsive.spacing(16)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: revenueData.map<Widget>((data) {
                      final revenue = data['revenue'] as double;
                      final height = (revenue / maxRevenue) * 180;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(8)),
                          Text(
                            data['period'],
                            style: TextStyle(
                              fontSize: responsive.fontSize(12),
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final busUtilization = analyticsData['busUtilization'];
    final driverPerformance = analyticsData['driverPerformance'];

    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus Utilization
          _buildSectionHeader('Bus Utilization', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          ...busUtilization
              .map<Widget>(
                  (bus) => _buildUtilizationCard(bus, isDarkMode, responsive))
              .toList(),

          SizedBox(height: responsive.spacing(24)),

          // Driver Performance
          _buildSectionHeader('Top Performing Drivers', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          ...driverPerformance
              .map<Widget>((driver) =>
                  _buildDriverPerformanceCard(driver, isDarkMode, responsive))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRoutesTab(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final popularRoutes = analyticsData['popularRoutes'];

    return SingleChildScrollView(
      padding: responsive.padding(16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Popular Routes', isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          ...popularRoutes
              .map<Widget>(
                  (route) => _buildRouteCard(route, isDarkMode, responsive))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(16, 16),
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
              Icon(icon, color: color, size: responsive.fontSize(24)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(6),
                  vertical: responsive.spacing(2),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: responsive.fontSize(10),
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStatusChart(Map<String, dynamic> tripStats, bool isDarkMode,
      ResponsiveUtils responsive) {
    final total = tripStats.values.cast<int>().reduce((a, b) => a + b);

    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      child: Column(
        children: tripStats.entries.map<Widget>((entry) {
          final value = entry.value as int;
          final percentage = (value / total * 100).round();
          final color = _getStatusColor(entry.key);

          return Container(
            margin: EdgeInsets.only(bottom: responsive.spacing(12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '$value ($percentage%)',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(4)),
                LinearProgressIndicator(
                  value: value / total,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFleetCard(String title, String value, IconData icon, Color color,
      bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(20, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.fontSize(32)),
          SizedBox(height: responsive.spacing(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationCard(
      Map<String, dynamic> bus, bool isDarkMode, ResponsiveUtils responsive) {
    final utilization = bus['utilization'] as double;
    final color = utilization >= 90
        ? Colors.green
        : utilization >= 70
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bus['busId'],
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${utilization.toInt()}%',
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bus['trips']} trips',
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                _getUtilizationLabel(utilization),
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverPerformanceCard(Map<String, dynamic> driver,
      bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: Column(
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
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(16)),
                    Text(
                      '${driver['trips']} trips',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${driver['revenue']} OMR',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
      Map<String, dynamic> route, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route,
                  color: AppColors.primary, size: responsive.fontSize(20)),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: Text(
                  route['route'],
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${route['trips']} trips',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Total Trips',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${route['revenue']} OMR',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'inProgress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getUtilizationLabel(double utilization) {
    if (utilization >= 90) return 'Excellent';
    if (utilization >= 70) return 'Good';
    return 'Needs Improvement';
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'day':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return 'This Week';
    }
  }
}
