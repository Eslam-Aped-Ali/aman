import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/entities/trip_filter.dart';
import '../../bloc/trips_bloc.dart';
import '../../bloc/trips_event.dart';

class TripsFilterWidget extends StatefulWidget {
  final VoidCallback? onClose;

  const TripsFilterWidget({
    super.key,
    this.onClose,
  });

  @override
  State<TripsFilterWidget> createState() => _TripsFilterWidgetState();
}

class _TripsFilterWidgetState extends State<TripsFilterWidget> {
  // Filter state variables
  RangeValues _priceRange = const RangeValues(0, 1000);
  TimeOfDay? _departureTimeFrom;
  TimeOfDay? _departureTimeTo;
  BusType? _selectedBusType;
  final List<TripAmenity> _selectedAmenities = [];
  double _minRating = 0;
  TripSortBy _sortBy = TripSortBy.price;
  SortOrder _sortOrder = SortOrder.ascending;
  bool _showOnlyPopular = false;
  bool _showOnlyAvailable = true;

  // Filter options
  final List<BusType> _busTypes = BusType.values;

  final List<TripAmenity> _amenities = TripAmenity.values;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'key': TripSortBy.price,
      'order': SortOrder.ascending,
      'label': 'Price: Low to High'
    },
    {
      'key': TripSortBy.price,
      'order': SortOrder.descending,
      'label': 'Price: High to Low'
    },
    {
      'key': TripSortBy.rating,
      'order': SortOrder.descending,
      'label': 'Rating: High to Low'
    },
    {
      'key': TripSortBy.departureTime,
      'order': SortOrder.ascending,
      'label': 'Departure: Earliest First'
    },
    {
      'key': TripSortBy.duration,
      'order': SortOrder.ascending,
      'label': 'Duration: Shortest First'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, isDarkMode, responsive),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.spacing(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildDepartureTimeFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildBusTypeFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildAmenitiesFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildRatingFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildSortByFilter(isDarkMode, responsive),
                  SizedBox(height: responsive.spacing(24)),
                  _buildToggleFilters(isDarkMode, responsive),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, isDarkMode, responsive),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.trips_filters_title.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(
            LocaleKeys.trips_filters_priceRange.tr(), responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '${_priceRange.start.round()} ${LocaleKeys.common_currency.tr()}',
              '${_priceRange.end.round()} ${LocaleKeys.common_currency.tr()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_priceRange.start.round()} ${LocaleKeys.common_currency.tr()}',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${_priceRange.end.round()} ${LocaleKeys.common_currency.tr()}',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartureTimeFilter(
      bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(LocaleKeys.trips_filters_departureTime.tr(),
            responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                label: LocaleKeys.trips_filters_from.tr(),
                time: _departureTimeFrom,
                onTap: () => _selectTime(true),
                isDarkMode: isDarkMode,
                responsive: responsive,
              ),
            ),
            SizedBox(width: responsive.spacing(12)),
            Expanded(
              child: _buildTimeSelector(
                label: LocaleKeys.trips_filters_to.tr(),
                time: _departureTimeTo,
                onTap: () => _selectTime(false),
                isDarkMode: isDarkMode,
                responsive: responsive,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(12)),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(responsive.spacing(8)),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: responsive.spacing(4)),
            Text(
              time?.format(context) ?? LocaleKeys.common_select.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: time != null
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.grey[500] : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusTypeFilter(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(
            LocaleKeys.trips_filters_busType.tr(), responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        Wrap(
          spacing: responsive.spacing(8),
          runSpacing: responsive.spacing(8),
          children: _busTypes.map((type) {
            final isSelected = _selectedBusType == type;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedBusType = isSelected ? null : type;
              }),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(12),
                  vertical: responsive.spacing(8),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  _getBusTypeName(type),
                  style: TextStyle(
                    fontSize: responsive.fontSize(12),
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(
            LocaleKeys.trips_filters_amenities.tr(), responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        Wrap(
          spacing: responsive.spacing(8),
          runSpacing: responsive.spacing(8),
          children: _amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedAmenities.remove(amenity);
                } else {
                  _selectedAmenities.add(amenity);
                }
              }),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(12),
                  vertical: responsive.spacing(8),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: responsive.fontSize(14),
                      color: isSelected
                          ? AppColors.primary
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      _getAmenityName(amenity),
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isSelected
                            ? AppColors.primary
                            : (isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700]),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(LocaleKeys.trips_filters_minimumRating.tr(),
            responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.amber,
            inactiveTrackColor: Colors.amber.withOpacity(0.3),
            thumbColor: Colors.amber,
            overlayColor: Colors.amber.withOpacity(0.2),
          ),
          child: Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 5,
            label: _minRating == 0
                ? LocaleKeys.trips_filters_any.tr()
                : '${_minRating.toInt()}+',
            onChanged: (value) => setState(() => _minRating = value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.trips_filters_any.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '5 ★',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortByFilter(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTitle(
            LocaleKeys.trips_filters_sortBy.tr(), responsive, isDarkMode),
        SizedBox(height: responsive.spacing(12)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _getSortKey(),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
              items: _sortOptions.map((option) {
                final key =
                    '${option['key'].toString().split('.').last}_${option['order'].toString().split('.').last}';
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(option['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _setSortFromKey(value);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleFilters(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      children: [
        _buildToggleOption(
          title: LocaleKeys.trips_filters_showOnlyPopular.tr(),
          value: _showOnlyPopular,
          onChanged: (value) => setState(() => _showOnlyPopular = value),
          isDarkMode: isDarkMode,
          responsive: responsive,
        ),
        SizedBox(height: responsive.spacing(12)),
        _buildToggleOption(
          title: LocaleKeys.trips_filters_showOnlyAvailable.tr(),
          value: _showOnlyAvailable,
          onChanged: (value) => setState(() => _showOnlyAvailable = value),
          isDarkMode: isDarkMode,
          responsive: responsive,
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
              ),
              child: Text(
                LocaleKeys.trips_filters_clear.tr(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _applyFilters(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
              ),
              child: Text(
                LocaleKeys.trips_filters_apply.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(
      String title, ResponsiveUtils responsive, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.fontSize(16),
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  IconData _getAmenityIcon(TripAmenity amenity) {
    switch (amenity) {
      case TripAmenity.wifi:
        return Icons.wifi;
      case TripAmenity.ac:
        return Icons.ac_unit;
      case TripAmenity.charging:
        return Icons.battery_charging_full;
      case TripAmenity.entertainment:
        return Icons.tv;
      case TripAmenity.meals:
        return Icons.restaurant;
      case TripAmenity.blanket:
        return Icons.bed;
      case TripAmenity.pillow:
        return Icons.bedroom_parent;
      case TripAmenity.restroom:
        return Icons.wc;
      case TripAmenity.reading:
        return Icons.book;
      case TripAmenity.music:
        return Icons.headphones;
    }
  }

  String _getAmenityName(TripAmenity amenity) {
    switch (amenity) {
      case TripAmenity.wifi:
        return LocaleKeys.trips_amenities_wifi.tr();
      case TripAmenity.ac:
        return LocaleKeys.trips_amenities_ac.tr();
      case TripAmenity.charging:
        return LocaleKeys.trips_amenities_charging.tr();
      case TripAmenity.entertainment:
        return LocaleKeys.trips_amenities_entertainment.tr();
      case TripAmenity.meals:
        return LocaleKeys.trips_amenities_meals.tr();
      case TripAmenity.blanket:
        return LocaleKeys.trips_amenities_blanket.tr();
      case TripAmenity.pillow:
        return LocaleKeys.trips_amenities_pillow.tr();
      case TripAmenity.restroom:
        return LocaleKeys.trips_amenities_restroom.tr();
      case TripAmenity.reading:
        return 'Reading Light'; // Fallback if not in translations
      case TripAmenity.music:
        return 'Music'; // Fallback if not in translations
    }
  }

  String _getBusTypeName(BusType busType) {
    switch (busType) {
      case BusType.acSleeper:
        return LocaleKeys.routes_busTypes_acSleeper.tr();
      case BusType.acDeluxe:
        return LocaleKeys.routes_busTypes_acDeluxe.tr();
      case BusType.ac:
        return LocaleKeys.routes_busTypes_ac.tr();
      case BusType.nonAc:
        return LocaleKeys.routes_busTypes_nonAc.tr();
      case BusType.luxury:
        return 'Luxury'; // Fallback if not in translations
      case BusType.express:
        return 'Express'; // Fallback if not in translations
    }
  }

  String _getSortKey() {
    return '${_sortBy.toString().split('.').last}_${_sortOrder.toString().split('.').last}';
  }

  void _setSortFromKey(String key) {
    final parts = key.split('_');
    if (parts.length == 2) {
      final sortByStr = parts[0];
      final sortOrderStr = parts[1];

      _sortBy = TripSortBy.values.firstWhere(
        (e) => e.toString().split('.').last == sortByStr,
        orElse: () => TripSortBy.price,
      );

      _sortOrder = SortOrder.values.firstWhere(
        (e) => e.toString().split('.').last == sortOrderStr,
        orElse: () => SortOrder.ascending,
      );
    }
  }

  Future<void> _selectTime(bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime
          ? (_departureTimeFrom ?? TimeOfDay.now())
          : (_departureTimeTo ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _departureTimeFrom = picked;
        } else {
          _departureTimeTo = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _departureTimeFrom = null;
      _departureTimeTo = null;
      _selectedBusType = null;
      _selectedAmenities.clear();
      _minRating = 0;
      _sortBy = TripSortBy.price;
      _sortOrder = SortOrder.ascending;
      _showOnlyPopular = false;
      _showOnlyAvailable = true;
    });
  }

  void _applyFilters(BuildContext context) {
    TimeRange? timeRange;
    if (_departureTimeFrom != null && _departureTimeTo != null) {
      timeRange = TimeRange(
        startHour: _departureTimeFrom!.hour,
        endHour: _departureTimeTo!.hour,
      );
    }

    final filterData = TripFilter(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 1000 ? _priceRange.end : null,
      departureTimeRange: timeRange,
      busTypes: _selectedBusType != null ? [_selectedBusType!] : [],
      requiredAmenities: _selectedAmenities,
      minRating: _minRating > 0 ? _minRating : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    context.read<TripsBloc>().add(ApplyFilter(filterData));
    widget.onClose?.call();
  }
}
