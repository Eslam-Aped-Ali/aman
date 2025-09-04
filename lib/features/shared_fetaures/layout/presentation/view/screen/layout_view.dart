import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/shared/commonWidgets/custtoms/appbar.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../navigationController/navigation_bloc.dart';
import '../../navigationController/navigation_event.dart';
import '../../navigationController/navigation_state.dart';
import '../widgets/custom_bottom_nav_item.dart';

class LayoutView extends StatefulWidget {
  final String? userType;
  const LayoutView({super.key, this.userType});

  @override
  State<LayoutView> createState() => _LayoutViewState();
}

class _LayoutViewState extends State<LayoutView> {
  NavigationBloc? bloc;
  String? currentUserType;

  @override
  void initState() {
    super.initState();
  }

  NavigationBloc _getBloc(BuildContext context) {
    if (bloc != null) return bloc!;

    // Get user type from arguments or widget parameter
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    currentUserType = args?['userType'] ?? widget.userType ?? 'passenger';

    // Initialize the bloc with user type
    bloc = NavigationBloc(userType: currentUserType)..add(NavigateToPage(0));
    return bloc!;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness to set system UI overlay style
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get the navigation bloc
    final navBloc = _getBloc(context);

    return BlocProvider<NavigationBloc>(
      create: (context) => navBloc,
      child: BlocBuilder<NavigationBloc, NavigationState>(
        bloc: navBloc,
        builder: (context, state) => PopScope(
          canPop: false,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: context.colors.surface,
              systemNavigationBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
              statusBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
              statusBarColor: Colors.transparent,
              statusBarBrightness:
                  isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: context.colors.background,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: Builder(
                  builder: (context) => AppBarWidget(
                    isSearch: false,
                    title: '',
                    // onMenuTap: () {
                    //   Scaffold.of(context).openDrawer();
                    // },
                  ),
                ),
              ),
              key: widget.key,
              floatingActionButton: Container(
                height: 60.h,
                width: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(52.r),
                  onTap: () {
                    navBloc.add(NavigateToPage(2));
                  },
                  child: Container(
                    height: 56.r,
                    width: 56.r,
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(56.r),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.shadow,
                          blurRadius: 10.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 60.h,
                          width: 60.w,
                          child: CircleAvatar(
                            backgroundColor: context.colors.primary,
                            child: Icon(
                              Icons.location_on,
                              size: 24,
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),

                        // Show notification badge only when this button is selected (index 2)
                        if (state.currentIndex == 2)
                          Positioned(
                            top: 12.h,
                            right: 10.w,
                            child: Container(
                              height: 10.r,
                              width: 10.r,
                              decoration: BoxDecoration(
                                color: context.colors.warning,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              body: navBloc.currentPage,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                height: 70.h,
                elevation: 5,
                notchMargin: 10,
                clipBehavior: Clip.antiAlias,
                shape: const CircularNotchedRectangle(),
                color: context.colors.surface,
                child:
                    buildLocalizedBottomNavigationBar(context, state, navBloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
