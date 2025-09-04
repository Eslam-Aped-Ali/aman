import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../core/shared/utils/responsive/responsive_utils.dart';

class AdminDriverApprovalScreen extends StatefulWidget {
  const AdminDriverApprovalScreen({super.key});

  @override
  State<AdminDriverApprovalScreen> createState() =>
      _AdminDriverApprovalScreenState();
}

class _AdminDriverApprovalScreenState extends State<AdminDriverApprovalScreen> {
  // Mock data for driver applications
  List<Map<String, dynamic>> driverApplications = [
    {
      'id': 'APP001',
      'name': 'Hassan Al-Mamari',
      'phone': '+968 9555 7890',
      'email': 'hassan.mamari@email.com',
      'licenseNumber': 'LIC12345',
      'experienceYears': 4,
      'status': 'pending',
      'appliedDate': '2025-08-25',
      'documents': ['license', 'id', 'experience'],
      'rating': null,
      'notes': 'Looking for part-time driving opportunities',
    },
    {
      'id': 'APP002',
      'name': 'Abdullah Al-Hinai',
      'phone': '+968 9777 1234',
      'email': 'abdullah.hinai@email.com',
      'licenseNumber': 'LIC67890',
      'experienceYears': 7,
      'status': 'pending',
      'appliedDate': '2025-08-24',
      'documents': ['license', 'id', 'experience', 'medical'],
      'rating': null,
      'notes': 'Has experience with passenger transport',
    },
    {
      'id': 'APP003',
      'name': 'Saif Al-Busaidi',
      'phone': '+968 9333 5678',
      'email': 'saif.busaidi@email.com',
      'licenseNumber': 'LIC11111',
      'experienceYears': 2,
      'status': 'approved',
      'appliedDate': '2025-08-20',
      'documents': ['license', 'id', 'experience'],
      'rating': 4.5,
      'notes': 'Approved for probation period',
    },
    {
      'id': 'APP004',
      'name': 'Omar Al-Rawahi',
      'phone': '+968 9666 9999',
      'email': 'omar.rawahi@email.com',
      'licenseNumber': 'LIC22222',
      'experienceYears': 1,
      'status': 'rejected',
      'appliedDate': '2025-08-18',
      'documents': ['license', 'id'],
      'rating': null,
      'notes': 'Insufficient experience, missing documents',
    },
  ];

  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Driver Applications',
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterOptions,
        ),
      ),
      body: Column(
        children: [
          _buildStatsHeader(theme, isDarkMode, responsive),
          _buildFilterTabs(theme, isDarkMode, responsive),
          Expanded(
            child: _buildApplicationsList(theme, isDarkMode, responsive),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final pending =
        driverApplications.where((app) => app['status'] == 'pending').length;
    final approved =
        driverApplications.where((app) => app['status'] == 'approved').length;
    final rejected =
        driverApplications.where((app) => app['status'] == 'rejected').length;

    return Container(
      margin: responsive.padding(16, 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              'Pending', pending, Colors.orange, responsive, isDarkMode),
          _buildDivider(isDarkMode),
          _buildStatItem(
              'Approved', approved, Colors.green, responsive, isDarkMode),
          _buildDivider(isDarkMode),
          _buildStatItem(
              'Rejected', rejected, Colors.red, responsive, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color,
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

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      height: 30,
      width: 1,
      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
    );
  }

  Widget _buildFilterTabs(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'approved', 'label': 'Approved'},
      {'key': 'rejected', 'label': 'Rejected'},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: Row(
        children: filters
            .map((filter) => Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => selectedFilter = filter['key']!),
                    child: Container(
                      margin: EdgeInsets.only(right: responsive.spacing(8)),
                      padding: EdgeInsets.symmetric(
                          vertical: responsive.spacing(12)),
                      decoration: BoxDecoration(
                        color: selectedFilter == filter['key']
                            ? AppColors.primary
                            : (isDarkMode ? Colors.grey[800] : Colors.white),
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(8)),
                        border: Border.all(
                          color: selectedFilter == filter['key']
                              ? AppColors.primary
                              : (isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        filter['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          fontWeight: FontWeight.w500,
                          color: selectedFilter == filter['key']
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

  Widget _buildApplicationsList(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    final filteredApplications = selectedFilter == 'all'
        ? driverApplications
        : driverApplications
            .where((app) => app['status'] == selectedFilter)
            .toList();

    if (filteredApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: responsive.spacing(16)),
            Text(
              'No applications found',
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
      padding: responsive.padding(16, 16),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final application = filteredApplications[index];
        return _buildApplicationCard(
            application, theme, isDarkMode, responsive);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application,
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
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
                child: Row(
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
                        size: responsive.fontSize(24),
                      ),
                    ),
                    SizedBox(width: responsive.spacing(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application['name'],
                            style: TextStyle(
                              fontSize: responsive.fontSize(18),
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Applied ${application['appliedDate']}',
                            style: TextStyle(
                              fontSize: responsive.fontSize(14),
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(application['status'], responsive),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoRow(
              Icons.phone, application['phone'], isDarkMode, responsive),
          SizedBox(height: responsive.spacing(8)),
          _buildInfoRow(
              Icons.email, application['email'], isDarkMode, responsive),
          SizedBox(height: responsive.spacing(8)),
          _buildInfoRow(Icons.badge, 'License: ${application['licenseNumber']}',
              isDarkMode, responsive),
          SizedBox(height: responsive.spacing(8)),
          _buildInfoRow(
              Icons.work,
              '${application['experienceYears']} years experience',
              isDarkMode,
              responsive),
          if (application['notes'].isNotEmpty) ...[
            SizedBox(height: responsive.spacing(12)),
            Container(
              padding: responsive.padding(12, 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Text(
                      application['notes'],
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: responsive.spacing(16)),
          _buildDocumentsSection(
              application['documents'], isDarkMode, responsive),
          if (application['status'] == 'pending') ...[
            SizedBox(height: responsive.spacing(20)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectApplication(application['id']),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: responsive.spacing(12)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(8)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveApplication(application['id']),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: responsive.spacing(12)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (application['status'] != 'pending') ...[
            SizedBox(height: responsive.spacing(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showApplicationDetails(application),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ResponsiveUtils responsive) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'PENDING';
        icon = Icons.schedule;
        break;
      case 'approved':
        color = Colors.green;
        text = 'APPROVED';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: responsive.spacing(4)),
          Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String text, bool isDarkMode, ResponsiveUtils responsive) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        SizedBox(width: responsive.spacing(8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(
      List<String> documents, bool isDarkMode, ResponsiveUtils responsive) {
    final documentIcons = {
      'license': Icons.drive_eta,
      'id': Icons.credit_card,
      'experience': Icons.work,
      'medical': Icons.medical_services,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents Submitted:',
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
          children: documents
              .map((doc) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(12),
                      vertical: responsive.spacing(6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(16)),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          documentIcons[doc] ?? Icons.description,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          doc.toUpperCase(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(12),
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Applications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Applications'),
              onTap: () {
                setState(() => selectedFilter = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Pending'),
              onTap: () {
                setState(() => selectedFilter = 'pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Approved'),
              onTap: () {
                setState(() => selectedFilter = 'approved');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Rejected'),
              onTap: () {
                setState(() => selectedFilter = 'rejected');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _approveApplication(String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: const Text(
            'Are you sure you want to approve this driver application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final appIndex = driverApplications
                    .indexWhere((app) => app['id'] == applicationId);
                if (appIndex != -1) {
                  driverApplications[appIndex]['status'] = 'approved';
                  driverApplications[appIndex]['notes'] =
                      'Application approved by admin';
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Driver application approved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectApplication(String applicationId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                setState(() {
                  final appIndex = driverApplications
                      .indexWhere((app) => app['id'] == applicationId);
                  if (appIndex != -1) {
                    driverApplications[appIndex]['status'] = 'rejected';
                    driverApplications[appIndex]['notes'] =
                        'Rejected: ${reasonController.text}';
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Driver application rejected.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(application['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Phone: ${application['phone']}'),
              const SizedBox(height: 8),
              Text('Email: ${application['email']}'),
              const SizedBox(height: 8),
              Text('License: ${application['licenseNumber']}'),
              const SizedBox(height: 8),
              Text('Experience: ${application['experienceYears']} years'),
              const SizedBox(height: 8),
              Text('Applied: ${application['appliedDate']}'),
              const SizedBox(height: 8),
              Text('Status: ${application['status'].toUpperCase()}'),
              if (application['notes'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${application['notes']}'),
              ],
            ],
          ),
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
}
