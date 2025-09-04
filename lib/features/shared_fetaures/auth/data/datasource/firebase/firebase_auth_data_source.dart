// import 'package:Aman/core/shared/services/firebase_service.dart';
// import 'package:Aman/features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source_abstract.dart';
// import 'package:Aman/features/shared_fetaures/auth/data/models/user_model.dart';
// import 'package:Aman/core/shared/error_handling/exceptions.dart';

// class FirebaseAuthDataSource implements AuthRemoteDataSourceAbstract {
//   final FirebaseService _firebaseService;

//   FirebaseAuthDataSource(this._firebaseService);

//   String? _lastVerificationId;
//   DateTime? _lastOtpRequestTime;
//   static const _minRequestInterval =
//       Duration(seconds: 60); // Prevent spam requests

//   // Check if phone number is a test number
//   bool _isTestNumber(String phone) {
//     final normalizedPhone = phone.replaceAll(' ', '');
//     return normalizedPhone == '+96892423333' ||
//         normalizedPhone == '+96892421111' ||
//         _firebaseService.isAdminNumber(normalizedPhone);
//   }

//   @override
//   Future<void> sendOtp({required String phone}) async {
//     try {
//       print('🔥 [FirebaseAuth] Sending OTP to: $phone');
//       print('🧪 [FirebaseAuth] Is test number: ${_isTestNumber(phone)}');

//       // Check if this is a test number - skip rate limiting
//       if (!_isTestNumber(phone)) {
//         // Check rate limiting for real numbers
//         final now = DateTime.now();
//         if (_lastOtpRequestTime != null &&
//             now.difference(_lastOtpRequestTime!) < _minRequestInterval) {
//           final remainingSeconds = _minRequestInterval.inSeconds -
//               now.difference(_lastOtpRequestTime!).inSeconds;
//           throw ServerException(
//               message:
//                   'Please wait $remainingSeconds seconds before requesting another OTP');
//         }
//         _lastOtpRequestTime = now;
//       }

//       final result = await _firebaseService.sendOTP(phoneNumber: phone);

//       if (result.success && result.verificationId != null) {
//         _lastVerificationId = result.verificationId;
//         print('✅ [FirebaseAuth] OTP sent successfully, verification ID stored');
//         print(
//             '🔑 [FirebaseAuth] Verification ID: ${result.verificationId!.substring(0, 20)}...');
//       } else if (!result.success) {
//         // Check if it's a billing error and provide helpful message
//         String errorMessage = result.message ?? 'Failed to send OTP';
//         print('❌ [FirebaseAuth] OTP send failed: $errorMessage');

//         // Handle rate limiting specifically
//         if (errorMessage.toLowerCase().contains('unusual activity') ||
//             errorMessage.toLowerCase().contains('blocked all requests') ||
//             errorMessage.toLowerCase().contains('too many requests')) {
//           errorMessage =
//               'Device temporarily blocked. Use test number: +96892421111 with OTP: 111111';
//         } else if (errorMessage.toLowerCase().contains('billing')) {
//           if (_isTestNumber(phone)) {
//             errorMessage = 'Test number detected. Use OTP: 111111';
//           } else {
//             errorMessage =
//                 'SMS service not available. Please use test number: +96892421111 with OTP: 111111';
//           }
//         }
//         throw ServerException(message: errorMessage);
//       }
//     } catch (e) {
//       print('❌ [FirebaseAuth] Exception in sendOtp: $e');
//       if (e is ServerException) {
//         rethrow;
//       }
//       // Check if it's a rate limiting error
//       String errorMessage = e.toString();
//       if (errorMessage.toLowerCase().contains('unusual activity') ||
//           errorMessage.toLowerCase().contains('blocked all requests') ||
//           errorMessage.toLowerCase().contains('too many requests')) {
//         errorMessage =
//             'Device temporarily blocked. Use test number: +96892421111 with OTP: 111111';
//       } else if (errorMessage.toLowerCase().contains('billing')) {
//         if (_isTestNumber(phone)) {
//           errorMessage = 'Test number detected. Use OTP: 111111';
//         } else {
//           errorMessage =
//               'SMS service not available. Please use test number: +96892421111 with OTP: 111111';
//         }
//       }
//       throw ServerException(
//         message: errorMessage.contains('Failed to send OTP')
//             ? errorMessage
//             : 'Failed to send OTP: $errorMessage',
//       );
//     }
//   }

//   @override
//   Future<UserModel> verifyOtpAndLogin({
//     required String phone,
//     required String otp,
//   }) async {
//     try {
//       print('🔥 [FirebaseAuth] Verifying OTP: $otp for phone: $phone');
//       print(
//           '🔑 [FirebaseAuth] Using stored verification ID: ${_lastVerificationId != null ? "${_lastVerificationId!.substring(0, 20)}..." : "null"}');
//       print(
//           '🔑 [FirebaseAuth] Firebase service verification ID: ${_firebaseService.currentVerificationId != null ? "${_firebaseService.currentVerificationId!.substring(0, 20)}..." : "null"}');

//       // Handle test numbers first
//       final normalizedPhone = phone.replaceAll(' ', '');
//       final isAdmin = _firebaseService.isAdminNumber(normalizedPhone);

//       print('📱 [FirebaseAuth] Normalized phone: $normalizedPhone');
//       print('👑 [FirebaseAuth] Is admin: $isAdmin');
//       print('🔢 [FirebaseAuth] Provided OTP: $otp');

//       if (isAdmin && otp == '111111') {
//         // Create mock admin user
//         final mockUser = UserModel.fromJson({
//           'id': 'admin_${DateTime.now().millisecondsSinceEpoch}',
//           'name': 'Admin User',
//           'phone': phone,
//           'role': 'admin',
//           'profileCompleted': true,
//           'token': 'mock_admin_token',
//         });
//         print('✅ [FirebaseAuth] Admin login successful');
//         return mockUser;
//       }

//       print(
//           '🧪 [FirebaseAuth] Test number check: ${_isTestNumber(normalizedPhone)}');
//       print(
//           '🔢 [FirebaseAuth] OTP comparison: "$otp" == "111111" -> ${otp == '111111'}');

//       if (_isTestNumber(normalizedPhone) && otp == '111111') {
//         // Create mock regular user
//         final mockUser = UserModel.fromJson({
//           'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
//           'name': 'Test User',
//           'phone': phone,
//           'role': 'passenger',
//           'profileCompleted': false,
//           'token': 'mock_user_token',
//         });
//         print('✅ [FirebaseAuth] Test user login successful');
//         return mockUser;
//       }

//       // Try Firebase OTP verification for real numbers
//       print('🔄 [FirebaseAuth] Attempting Firebase OTP verification...');
//       final result = await _firebaseService.verifyOTP(
//         otp: otp,
//         verificationId: _lastVerificationId, // Use stored verification ID
//       );

//       if (!result.success || result.user == null) {
//         print(
//             '❌ [FirebaseAuth] Firebase OTP verification failed: ${result.message}');
//         throw ServerException(
//           message: result.message ?? 'OTP verification failed',
//         );
//       }

//       final user = result.user!;
//       final role = isAdmin ? 'admin' : 'passenger';

//       print(
//           '✅ [FirebaseAuth] Firebase OTP verification successful for user: ${user.uid}');

//       // Try to create/get user profile (skip if Firestore not available)
//       try {
//         await _firebaseService.createUserProfile(
//           uid: user.uid,
//           phone: phone,
//           role: role,
//         );

//         final userData = await _firebaseService.getUserProfile(user.uid);
//         if (userData != null) {
//           print('✅ [FirebaseAuth] User profile retrieved from Firestore');
//           return UserModel.fromFirestore(userData);
//         }
//       } catch (e) {
//         print(
//             '⚠️ [FirebaseAuth] Firestore operation failed (database might not exist): $e');
//         // Continue with mock user if Firestore fails
//       }

//       // Fallback: create mock user from Firebase auth
//       final mockUser = UserModel.fromJson({
//         'id': user.uid,
//         'name': user.displayName ?? 'Firebase User',
//         'phone': phone,
//         'role': role,
//         'profileCompleted': false,
//         'token': await user.getIdToken(),
//       });

//       print('✅ [FirebaseAuth] Firebase auth successful with fallback user');
//       return mockUser;
//     } catch (e) {
//       print('❌ [FirebaseAuth] OTP verification error: $e');
//       if (e is ServerException) {
//         rethrow;
//       }
//       throw ServerException(
//         message: 'Failed to verify OTP and login: ${e.toString()}',
//       );
//     }
//   }

//   @override
//   Future<UserModel> register({
//     required String phone,
//     required String name,
//   }) async {
//     try {
//       print('📝 Registering user: $name with phone: $phone');

//       // For now, skip Firestore operations and create a mock user
//       // This allows the app to work without Firestore collections
//       final mockUser = UserModel.fromJson({
//         'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
//         'name': name,
//         'phone': phone,
//         'role': 'passenger',
//         'profileCompleted': true, // Mark as completed after registration
//         'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
//       });

//       print('✅ Mock user created successfully');
//       return mockUser;

//       // TODO: Re-enable when Firestore is ready
//       // final currentUser = _firebaseService.currentUser;
//       // if (currentUser == null) {
//       //   throw ServerException(message: 'User not authenticated');
//       // }

//       // final userData = {
//       //   'name': name,
//       //   'profileCompleted': true,
//       // };

//       // final success = await _firebaseService.updateUserProfile(
//       //   uid: currentUser.uid,
//       //   data: userData,
//       // );

//       // if (!success) {
//       //   throw ServerException(message: 'Failed to update user profile');
//       // }

//       // final updatedProfile =
//       //     await _firebaseService.getUserProfile(currentUser.uid);
//       // if (updatedProfile == null) {
//       //   throw ServerException(message: 'Failed to get updated user profile');
//       // }

//       // return UserModel.fromFirestore(updatedProfile);
//     } catch (e) {
//       print('❌ Registration error: $e');
//       if (e is ServerException) {
//         rethrow;
//       }

//       // Fallback: create mock user even if there's an error
//       print('⏭️ Creating fallback mock user due to error');
//       final fallbackUser = UserModel.fromJson({
//         'id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
//         'name': name,
//         'phone': phone,
//         'role': 'passenger',
//         'profileCompleted': true,
//         'token': 'fallback_token',
//       });

//       return fallbackUser;
//     }
//   }

//   @override
//   Future<void> logout() async {
//     try {
//       await _firebaseService.signOut();
//     } catch (e) {
//       throw ServerException(
//         message: 'Failed to logout: ${e.toString()}',
//       );
//     }
//   }

//   @override
//   Future<UserModel> refreshToken() async {
//     try {
//       final currentUser = _firebaseService.currentUser;
//       if (currentUser == null) {
//         // Return mock user if no current user
//         print('⏭️ No current user - returning mock user');
//         return UserModel.fromJson({
//           'id': 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
//           'name': 'Refreshed Mock User',
//           'phone': '+96892421111',
//           'role': 'passenger',
//           'profileCompleted': true,
//           'token': 'refreshed_mock_token',
//         });
//       }

//       // Try to refresh Firebase token, fallback to mock if it fails
//       try {
//         final idToken = await currentUser.getIdToken(true);

//         // Skip Firestore query and return mock user with real token
//         final mockUser = UserModel.fromJson({
//           'id': currentUser.uid,
//           'name': currentUser.displayName ?? 'Firebase User',
//           'phone': '+96892421111',
//           'role': 'passenger',
//           'profileCompleted': true,
//           'token': idToken,
//         });

//         return mockUser;
//       } catch (e) {
//         print('⚠️ Firebase token refresh failed: $e');
//         // Return mock user with mock token
//         return UserModel.fromJson({
//           'id': currentUser.uid,
//           'name': 'Fallback User',
//           'phone': '+96892421111',
//           'role': 'passenger',
//           'profileCompleted': true,
//           'token': 'fallback_token',
//         });
//       }

//       // TODO: Re-enable when Firestore is ready
//       // final userData = await _firebaseService.getUserProfile(currentUser.uid);
//       // if (userData == null) {
//       //   throw ServerException(message: 'Failed to get user profile');
//       // }

//       // return UserModel.fromFirestore(userData, token: idToken);
//     } catch (e) {
//       print('❌ Refresh token error: $e');
//       // Return mock user instead of throwing exception
//       return UserModel.fromJson({
//         'id': 'error_fallback_${DateTime.now().millisecondsSinceEpoch}',
//         'name': 'Error Fallback User',
//         'phone': '+96892421111',
//         'role': 'passenger',
//         'profileCompleted': true,
//         'token': 'error_fallback_token',
//       });
//     }
//   }

//   @override
//   Future<UserModel> updateProfile({
//     required String id,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       print('📝 Updating profile for id: $id with data: $data');

//       // Skip Firestore update for now and return updated mock user
//       final mockUser = UserModel.fromJson({
//         'id': id,
//         'name': data['name'] ?? 'Updated User',
//         'phone': data['phone'] ?? '+96892421111',
//         'role': data['role'] ?? 'passenger',
//         'profileCompleted': true,
//         'token': 'updated_token_$id',
//         ...data, // Include any additional data
//       });

//       print('✅ Mock profile updated successfully');
//       return mockUser;

//       // TODO: Re-enable when Firestore is ready
//       // final success = await _firebaseService.updateUserProfile(
//       //   uid: id,
//       //   data: data,
//       // );

//       // if (!success) {
//       //   throw ServerException(message: 'Failed to update profile');
//       // }

//       // final updatedProfile = await _firebaseService.getUserProfile(id);
//       // if (updatedProfile == null) {
//       //   throw ServerException(message: 'Failed to get updated profile');
//       // }

//       // return UserModel.fromFirestore(updatedProfile);
//     } catch (e) {
//       print('❌ Update profile error: $e');
//       // Return fallback user instead of throwing exception
//       final fallbackUser = UserModel.fromJson({
//         'id': id,
//         'name': data['name'] ?? 'Fallback User',
//         'phone': data['phone'] ?? '+96892421111',
//         'role': data['role'] ?? 'passenger',
//         'profileCompleted': true,
//         'token': 'fallback_updated_token',
//         ...data,
//       });

//       return fallbackUser;
//     }
//   }

//   @override
//   Future<UserModel> getUserProfile(String id) async {
//     try {
//       // Skip Firestore query for now and return mock user
//       print('⏭️ Skipping getUserProfile - creating mock user for id: $id');

//       final mockUser = UserModel.fromJson({
//         'id': id,
//         'name': 'Mock User',
//         'phone': '+96892421111',
//         'role': 'passenger',
//         'profileCompleted': true,
//         'token': 'mock_token_$id',
//       });

//       return mockUser;

//       // TODO: Re-enable when Firestore is ready
//       // final userData = await _firebaseService.getUserProfile(id);
//       // if (userData == null) {
//       //   throw ServerException(message: 'User profile not found');
//       // }

//       // return UserModel.fromFirestore(userData);
//     } catch (e) {
//       print('❌ Get user profile error: $e');
//       // Return mock user instead of throwing exception
//       final fallbackUser = UserModel.fromJson({
//         'id': id,
//         'name': 'Fallback User',
//         'phone': '+96892421111',
//         'role': 'passenger',
//         'profileCompleted': true,
//         'token': 'fallback_token',
//       });

//       return fallbackUser;
//     }
//   }

//   @override
//   Future<List<UserModel>> getAllUsers() async {
//     try {
//       // Skip Firestore query for now and return empty list
//       print('⏭️ Skipping getAllUsers - Firestore not available');
//       return [];

//       // TODO: Re-enable when Firestore is ready
//       // final users = await _firebaseService.queryDocuments(
//       //   collection: 'users',
//       // );

//       // return users
//       //     .map((userData) => UserModel.fromFirestore(userData))
//       //     .toList();
//     } catch (e) {
//       print('❌ Get all users error: $e');
//       // Return empty list instead of throwing exception
//       return [];
//     }
//   }

//   @override
//   Future<void> deleteUser(String id) async {
//     try {
//       print('🗑️ Deleting user with id: $id');

//       // Skip Firestore deletion for now - just log success
//       print(
//           '⏭️ Skipping Firestore deletion - operation completed successfully');

//       // TODO: Re-enable when Firestore is ready
//       // final success = await _firebaseService.deleteDocument(
//       //   collection: 'users',
//       //   documentId: id,
//       // );

//       // if (!success) {
//       //   throw ServerException(message: 'Failed to delete user');
//       // }
//     } catch (e) {
//       print('❌ Delete user error: $e');
//       // Don't throw exception - just log the error
//       print('⏭️ Continuing despite deletion error (Firestore not available)');
//     }
//   }

//   @override
//   Future<bool> checkUserExists(String phone) async {
//     try {
//       print('🔍 Checking if user exists for phone: $phone');

//       // Clear any previous verification state to ensure fresh start
//       _firebaseService.clearVerificationId();
//       _lastVerificationId = null;

//       // First, send OTP for Firebase phone authentication
//       await sendOtp(phone: phone);
//       print('✅ OTP sent successfully');

//       // Skip Firestore validation for now - always return false to navigate to complete profile
//       print(
//           '⏭️ Skipping Firestore validation - navigating to complete profile');
//       return false;

//       // TODO: Re-enable when Firestore collections are ready
//       // Try to check if user exists in Firestore (skip if database doesn't exist)
//       // try {
//       //   final users = await _firebaseService.queryDocuments(
//       //     collection: 'users',
//       //     queryBuilder: (query) => query.where('phone', isEqualTo: phone),
//       //   );
//       //   print('📊 Found ${users.length} existing users');
//       //   return users.isNotEmpty;
//       // } catch (e) {
//       //   print('⚠️ Firestore query failed (database might not exist): $e');
//       //   // Return false for new users if Firestore is not available
//       //   return false;
//       // }
//     } catch (e) {
//       print('❌ Check user exists error: $e');
//       // Don't throw exception for now - just return false to allow navigation to complete profile
//       print('⏭️ Returning false to allow profile completion flow');
//       return false;
//     }
//   }
// }
