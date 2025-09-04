import '../../domain/entities/location_point.dart';

class LocationPointModel extends LocationPoint {
  const LocationPointModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.addressAr,
    required super.type,
    super.isUserLocation = false,
    super.selectedTime,
  });

  factory LocationPointModel.fromEntity(LocationPoint location) {
    return LocationPointModel(
      id: location.id,
      name: location.name,
      nameAr: location.nameAr,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      addressAr: location.addressAr,
      type: location.type,
      isUserLocation: location.isUserLocation,
      selectedTime: location.selectedTime,
    );
  }

  factory LocationPointModel.fromJson(Map<String, dynamic> json) {
    return LocationPointModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      addressAr: json['addressAr'] as String,
      type: json['type'] as String,
      isUserLocation: json['isUserLocation'] as bool? ?? false,
      selectedTime: json['selectedTime'] != null
          ? DateTime.parse(json['selectedTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'addressAr': addressAr,
      'type': type,
      'isUserLocation': isUserLocation,
      'selectedTime': selectedTime?.toIso8601String(),
    };
  }

  @override
  LocationPointModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? latitude,
    double? longitude,
    String? address,
    String? addressAr,
    String? type,
    bool? isUserLocation,
    DateTime? selectedTime,
  }) {
    return LocationPointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      type: type ?? this.type,
      isUserLocation: isUserLocation ?? this.isUserLocation,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  // Dummy data generator for popular locations in Oman
  static List<LocationPointModel> getDummyPopularLocations() {
    return [
      // Muscat Popular Locations
      const LocationPointModel(
        id: 'loc_1',
        name: 'Muscat International Airport',
        nameAr: 'مطار مسقط الدولي',
        latitude: 23.5933,
        longitude: 58.2844,
        address: 'Seeb, Muscat Governorate, Oman',
        addressAr: 'السيب، محافظة مسقط، عمان',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_2',
        name: 'Grand Mosque',
        nameAr: 'الجامع الكبير',
        latitude: 23.5839,
        longitude: 58.3886,
        address: 'Sultan Qaboos Grand Mosque, Muscat',
        addressAr: 'جامع السلطان قابوس الأكبر، مسقط',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_3',
        name: 'Mutrah Souq',
        nameAr: 'سوق مطرح',
        latitude: 23.6260,
        longitude: 58.5735,
        address: 'Mutrah Corniche, Muscat',
        addressAr: 'كورنيش مطرح، مسقط',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_4',
        name: 'Royal Opera House',
        nameAr: 'دار الأوبرا السلطانية',
        latitude: 23.5996,
        longitude: 58.3803,
        address: 'Al Kharjiya Street, Muscat',
        addressAr: 'شارع الخارجية، مسقط',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_5',
        name: 'Al Amerat',
        nameAr: 'العامرات',
        latitude: 23.5889,
        longitude: 58.3558,
        address: 'Al Amerat, Muscat Governorate',
        addressAr: 'العامرات، محافظة مسقط',
        type: 'popular',
      ),

      // Nizwa Popular Locations
      const LocationPointModel(
        id: 'loc_6',
        name: 'Nizwa Fort',
        nameAr: 'حصن نزوى',
        latitude: 22.9333,
        longitude: 57.5333,
        address: 'Nizwa Fort, Ad Dakhiliyah Governorate',
        addressAr: 'حصن نزوى، محافظة الداخلية',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_7',
        name: 'Nizwa Souq',
        nameAr: 'سوق نزوى',
        latitude: 22.9288,
        longitude: 57.5322,
        address: 'Traditional Souq, Nizwa',
        addressAr: 'السوق التقليدي، نزوى',
        type: 'popular',
      ),

      // Salalah Popular Locations
      const LocationPointModel(
        id: 'loc_8',
        name: 'Salalah Airport',
        nameAr: 'مطار صلالة',
        latitude: 17.0394,
        longitude: 54.0913,
        address: 'Salalah Airport, Dhofar Governorate',
        addressAr: 'مطار صلالة، محافظة ظفار',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_9',
        name: 'Al Haffa Beach',
        nameAr: 'شاطئ الحافة',
        latitude: 17.0194,
        longitude: 54.0913,
        address: 'Al Haffa Beach, Salalah',
        addressAr: 'شاطئ الحافة، صلالة',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_10',
        name: 'Frankincense Land Museum',
        nameAr: 'متحف أرض اللبان',
        latitude: 17.0299,
        longitude: 54.0946,
        address: 'Al Baleed Archaeological Park, Salalah',
        addressAr: 'حديقة البليد الأثرية، صلالة',
        type: 'popular',
      ),

      // Sohar Popular Locations
      const LocationPointModel(
        id: 'loc_11',
        name: 'Sohar Fort',
        nameAr: 'حصن صحار',
        latitude: 24.3574,
        longitude: 56.7092,
        address: 'Sohar Fort, Al Batinah North Governorate',
        addressAr: 'حصن صحار، محافظة شمال الباطنة',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_12',
        name: 'Sohar Port',
        nameAr: 'ميناء صحار',
        latitude: 24.3665,
        longitude: 56.7275,
        address: 'Sohar Industrial Port, Sohar',
        addressAr: 'ميناء صحار الصناعي، صحار',
        type: 'popular',
      ),

      // Sur Popular Locations
      const LocationPointModel(
        id: 'loc_13',
        name: 'Sur Maritime Museum',
        nameAr: 'متحف صور البحري',
        latitude: 22.5667,
        longitude: 59.5289,
        address: 'Sur Maritime Museum, Al Sharqiyah South',
        addressAr: 'متحف صور البحري، جنوب الشرقية',
        type: 'popular',
      ),
      const LocationPointModel(
        id: 'loc_14',
        name: 'Ras Al Jinz Turtle Reserve',
        nameAr: 'محمية رأس الجنز للسلاحف',
        latitude: 22.5708,
        longitude: 59.7564,
        address: 'Ras Al Jinz, Sur',
        addressAr: 'رأس الجنز، صور',
        type: 'popular',
      ),

      // Ibra Popular Locations
      const LocationPointModel(
        id: 'loc_15',
        name: 'Ibra Old Town',
        nameAr: 'مدينة إبراء القديمة',
        latitude: 22.6919,
        longitude: 58.5347,
        address: 'Old Town, Ibra, Al Sharqiyah North',
        addressAr: 'البلدة القديمة، إبراء، شمال الشرقية',
        type: 'popular',
      ),
    ];
  }

  // Get dummy locations for searching/autocomplete
  static List<LocationPointModel> getDummyAllLocations() {
    final popularLocations = getDummyPopularLocations();

    // Additional locations for comprehensive search
    final additionalLocations = [
      // Muscat areas
      const LocationPointModel(
        id: 'loc_16',
        name: 'Qurum Beach',
        nameAr: 'شاطئ القرم',
        latitude: 23.6089,
        longitude: 58.4736,
        address: 'Qurum Beach, Muscat',
        addressAr: 'شاطئ القرم، مسقط',
        type: 'area',
      ),
      const LocationPointModel(
        id: 'loc_17',
        name: 'City Centre Muscat',
        nameAr: 'سيتي سنتر مسقط',
        latitude: 23.5885,
        longitude: 58.4067,
        address: 'City Centre Muscat, Seeb',
        addressAr: 'سيتي سنتر مسقط، السيب',
        type: 'mall',
      ),
      const LocationPointModel(
        id: 'loc_18',
        name: 'Al Khuwair',
        nameAr: 'الخوير',
        latitude: 23.5983,
        longitude: 58.4042,
        address: 'Al Khuwair, Muscat',
        addressAr: 'الخوير، مسقط',
        type: 'area',
      ),
      const LocationPointModel(
        id: 'loc_19',
        name: 'Al Ghubra',
        nameAr: 'الغبرة',
        latitude: 23.5944,
        longitude: 58.4319,
        address: 'Al Ghubra, Muscat',
        addressAr: 'الغبرة، مسقط',
        type: 'area',
      ),
      const LocationPointModel(
        id: 'loc_20',
        name: 'Bawshar',
        nameAr: 'بوشر',
        latitude: 23.5772,
        longitude: 58.3997,
        address: 'Bawshar, Muscat',
        addressAr: 'بوشر، مسقط',
        type: 'area',
      ),
    ];

    return [...popularLocations, ...additionalLocations];
  }
}
