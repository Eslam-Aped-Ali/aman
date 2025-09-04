import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../app/routing/routes.dart';
import '../../../domain/entities/driver_profile.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_event.dart';
import '../../bloc/driver_profile_state.dart';
import '../widgets/complete_profile_header.dart';
import '../widgets/complete_profile_form.dart';
import '../widgets/complete_profile_submit_button.dart';

class CompleteDriverProfileScreen extends StatefulWidget {
  final String phoneNumber;

  const CompleteDriverProfileScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<CompleteDriverProfileScreen> createState() =>
      _CompleteDriverProfileScreenState();
}

class _CompleteDriverProfileScreenState
    extends State<CompleteDriverProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Gender _selectedGender = Gender.male;
  int _selectedBirthYear = DateTime.now().year - 25;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: BlocListener<DriverProfileBloc, DriverProfileState>(
          listener: (context, state) {
            if (state is DriverProfileCreated) {
              replacement(
                NamedRoutes.i.driverApprovalScreen,
                arguments: {
                  'driverProfile': state.profile,
                  'phoneNumber': widget.phoneNumber,
                  'shouldLoadProfile': false,
                },
              );
            } else if (state is DriverProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: responsive.padding(20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompleteProfileHeader(slideAnimation: _slideAnimation),
                  SizedBox(height: responsive.spacing(40)),
                  CompleteProfileForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    selectedGender: _selectedGender,
                    selectedBirthYear: _selectedBirthYear,
                    onGenderChanged: (gender) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                    onBirthYearChanged: (year) {
                      setState(() {
                        _selectedBirthYear = year;
                      });
                    },
                    slideAnimation: _slideAnimation,
                  ),
                  SizedBox(height: responsive.spacing(40)),
                  CompleteProfileSubmitButton(
                    onSubmit: _submitProfile,
                    slideAnimation: _slideAnimation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<DriverProfileBloc>().add(
            CreateDriverProfile(
              name: _nameController.text.trim(),
              phoneNumber: widget.phoneNumber,
              gender: _selectedGender,
              birthYear: _selectedBirthYear,
            ),
          );
    }
  }
}
