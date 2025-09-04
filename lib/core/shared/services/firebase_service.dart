// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import '../utils/depugging/debug_utils.dart';

// class FirebaseService {
//   // Singleton pattern
//   FirebaseService._internal();
//   static final FirebaseService _instance = FirebaseService._internal();
//   static FirebaseService get instance => _instance;
//   factory FirebaseService() => _instance;

//   // Firebase instances
//   late final FirebaseAuth _auth;
//   late final FirebaseFirestore _firestore;
//   late final FirebaseStorage _storage;
//   late final FirebaseMessaging _messaging;
//   late final FirebaseAnalytics _analytics;
//   late final FirebaseCrashlytics _crashlytics;
//   late final FirebaseRemoteConfig _remoteConfig;

//   // Stream controllers
//   final StreamController<User?> _authStateController =
//       StreamController<User?>.broadcast();
//   final StreamController<String?> _fcmTokenController =
//       StreamController<String?>.broadcast();

//   // Phone verification
//   String? _verificationId;
//   int? _resendToken;

//   // Getters
//   FirebaseAuth get auth => _auth;
//   FirebaseFirestore get firestore => _firestore;
//   FirebaseStorage get storage => _storage;
//   FirebaseMessaging get messaging => _messaging;
//   FirebaseAnalytics get analytics => _analytics;
//   FirebaseCrashlytics get crashlytics => _crashlytics;
//   FirebaseRemoteConfig get remoteConfig => _remoteConfig;

//   Stream<User?> get authStateChanges => _authStateController.stream;
//   Stream<String?> get fcmTokenStream => _fcmTokenController.stream;
//   User? get currentUser => _auth.currentUser;
//   bool get isAuthenticated => currentUser != null;
//   String? get userId => currentUser?.uid;

//   // Initialize Firebase
//   Future<void> initialize() async {
//     try {
//       Console.printInfo('🔥 Initializing Firebase...');

//       await Firebase.initializeApp();

//       _auth = FirebaseAuth.instance;
//       _firestore = FirebaseFirestore.instance;
//       _storage = FirebaseStorage.instance;
//       _messaging = FirebaseMessaging.instance;
//       _analytics = FirebaseAnalytics.instance;
//       _crashlytics = FirebaseCrashlytics.instance;
//       _remoteConfig = FirebaseRemoteConfig.instance;

//       // Remove Google Sign In for now
//       // _googleSignIn = GoogleSignIn();

//       // Setup listeners
//       _setupAuthListener();
//       await _setupMessaging();
//       await _setupRemoteConfig();
//       await _setupCrashlytics();

//       Console.printSuccess('✅ Firebase initialized successfully');
//     } catch (e, stack) {
//       Console.printError('❌ Firebase initialization failed: $e');
//       if (!kIsWeb) {
//         _crashlytics.recordError(e, stack);
//       }
//     }
//   }

//   // ============= AUTH METHODS =============

//   // Phone Authentication - Send OTP
//   Future<PhoneAuthResult> sendOTP({
//     required String phoneNumber,
//   }) async {
//     try {
//       Console.printInfo('🔥 Sending OTP to: $phoneNumber');
//       final completer = Completer<PhoneAuthResult>();

//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           // Auto-verification completed
//           try {
//             Console.printSuccess('📱 Auto verification completed');
//             final userCredential = await _auth.signInWithCredential(credential);
//             await _postAuthSuccess(userCredential.user);
//             if (userCredential.user != null) {
//               completer.complete(
//                   PhoneAuthResult.autoVerified(user: userCredential.user!));
//             } else {
//               completer.complete(PhoneAuthResult.error(
//                   message: 'Auto-verification failed: User is null'));
//             }
//           } catch (e) {
//             Console.printError('❌ Auto-verification error: $e');
//             completer.complete(
//                 PhoneAuthResult.error(message: 'Auto-verification failed: $e'));
//           }
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           Console.printError('❌ Phone verification failed: ${e.message}');
//           completer.complete(PhoneAuthResult.error(
//             message: _getAuthErrorMessage(e.code),
//             code: e.code,
//           ));
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           Console.printSuccess('✅ OTP code sent successfully');
//           Console.printInfo(
//               '📋 Verification ID: ${verificationId.substring(0, 20)}...');
//           _verificationId = verificationId;
//           _resendToken = resendToken;
//           completer.complete(PhoneAuthResult.codeSent(
//             verificationId: verificationId,
//             resendToken: resendToken,
//           ));
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           Console.printInfo('⏰ Code auto-retrieval timeout - this is normal');
//           Console.printInfo('📋 User can still manually enter OTP');
//           _verificationId = verificationId;
//           // Note: This is expected behavior, not an error
//           // The user can still manually enter the OTP using this verification ID
//         },
//         timeout: const Duration(seconds: 60),
//         forceResendingToken: _resendToken,
//       );

//       return await completer.future;
//     } catch (e) {
//       Console.printError('❌ Phone authentication failed: $e');
//       return PhoneAuthResult.error(message: 'Phone authentication failed: $e');
//     }
//   }

//   // Phone Authentication - Verify OTP
//   Future<AuthResult> verifyOTP({
//     required String otp,
//     String? verificationId,
//   }) async {
//     try {
//       final String? finalVerificationId = verificationId ?? _verificationId;

//       if (finalVerificationId == null) {
//         Console.printError(
//             '❌ No verification ID available. Please request OTP again.');
//         return AuthResult.error(
//             message: 'No verification ID available. Please request OTP again.');
//       }

//       Console.printInfo('🔐 Verifying OTP: $otp');
//       Console.printInfo(
//           '📋 Using verification ID: ${finalVerificationId.substring(0, 20)}...');

//       final credential = PhoneAuthProvider.credential(
//         verificationId: finalVerificationId,
//         smsCode: otp,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       await _postAuthSuccess(userCredential.user);

//       Console.printSuccess('✅ OTP verification successful');
//       return AuthResult.success(user: userCredential.user);
//     } on FirebaseAuthException catch (e) {
//       Console.printError('❌ Firebase OTP verification failed: ${e.message}');
//       return _handleAuthException(e);
//     } catch (e) {
//       Console.printError('❌ OTP verification failed: $e');
//       return AuthResult.error(message: 'Verification failed: $e');
//     }
//   }

//   // Check if phone number is admin
//   bool isAdminNumber(String phoneNumber) {
//     const adminNumber = '+96892420578';
//     return phoneNumber == adminNumber;
//   }

//   // Get current verification ID (for debugging)
//   String? get currentVerificationId => _verificationId;

//   // Clear verification ID (useful for fresh attempts)
//   void clearVerificationId() {
//     _verificationId = null;
//     _resendToken = null;
//     Console.printInfo('🧹 Cleared verification ID for fresh attempt');
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     try {
//       // await _googleSignIn.signOut();  // Temporarily disabled
//       await _auth.signOut();
//       Console.printSuccess('User signed out');
//     } catch (e) {
//       Console.printError('Sign out failed: $e');
//     }
//   }

//   // Delete Account
//   Future<bool> deleteAccount() async {
//     try {
//       await currentUser?.delete();
//       return true;
//     } catch (e) {
//       Console.printError('Account deletion failed: $e');
//       return false;
//     }
//   }

//   // ============= FIRESTORE METHODS =============

//   // Create or update user profile
//   Future<String?> createUserProfile({
//     required String uid,
//     required String phone,
//     required String role,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       final userData = {
//         'uid': uid,
//         'phone': phone,
//         'role': role,
//         'profileCompleted': false,
//         'status': role == 'admin' ? 'active' : 'pending',
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         ...?additionalData,
//       };

//       await _firestore
//           .collection('users')
//           .doc(uid)
//           .set(userData, SetOptions(merge: true));
//       return uid;
//     } catch (e) {
//       Console.printError('Create user profile failed: $e');
//       return null;
//     }
//   }

//   // Update user profile
//   Future<bool> updateUserProfile({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       data['updatedAt'] = FieldValue.serverTimestamp();
//       await _firestore.collection('users').doc(uid).update(data);
//       return true;
//     } catch (e) {
//       Console.printError('Update user profile failed: $e');
//       return false;
//     }
//   }

//   // Complete user profile
//   Future<bool> completeUserProfile({
//     required String uid,
//     required Map<String, dynamic> profileData,
//   }) async {
//     try {
//       profileData['profileCompleted'] = true;
//       profileData['updatedAt'] = FieldValue.serverTimestamp();

//       await _firestore.collection('users').doc(uid).update(profileData);
//       return true;
//     } catch (e) {
//       Console.printError('Complete user profile failed: $e');
//       return false;
//     }
//   }

//   // Get user profile
//   Future<Map<String, dynamic>?> getUserProfile(String uid) async {
//     try {
//       final doc = await _firestore.collection('users').doc(uid).get();
//       if (doc.exists) {
//         return {'id': doc.id, ...?doc.data()};
//       }
//       return null;
//     } catch (e) {
//       Console.printError('Get user profile failed: $e');
//       return null;
//     }
//   }

//   // Create document
//   Future<String?> createDocument({
//     required String collection,
//     required Map<String, dynamic> data,
//     String? documentId,
//   }) async {
//     try {
//       data['createdAt'] = FieldValue.serverTimestamp();
//       data['updatedAt'] = FieldValue.serverTimestamp();

//       if (documentId != null) {
//         await _firestore.collection(collection).doc(documentId).set(data);
//         return documentId;
//       } else {
//         final doc = await _firestore.collection(collection).add(data);
//         return doc.id;
//       }
//     } catch (e) {
//       Console.printError('Create document failed: $e');
//       return null;
//     }
//   }

//   // Read document
//   Future<Map<String, dynamic>?> getDocument({
//     required String collection,
//     required String documentId,
//   }) async {
//     try {
//       final doc = await _firestore.collection(collection).doc(documentId).get();
//       if (doc.exists) {
//         return {'id': doc.id, ...?doc.data()};
//       }
//       return null;
//     } catch (e) {
//       Console.printError('Get document failed: $e');
//       return null;
//     }
//   }

//   // Update document
//   Future<bool> updateDocument({
//     required String collection,
//     required String documentId,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       data['updatedAt'] = FieldValue.serverTimestamp();
//       await _firestore.collection(collection).doc(documentId).update(data);
//       return true;
//     } catch (e) {
//       Console.printError('Update document failed: $e');
//       return false;
//     }
//   }

//   // Delete document
//   Future<bool> deleteDocument({
//     required String collection,
//     required String documentId,
//   }) async {
//     try {
//       await _firestore.collection(collection).doc(documentId).delete();
//       return true;
//     } catch (e) {
//       Console.printError('Delete document failed: $e');
//       return false;
//     }
//   }

//   // Query documents
//   Future<List<Map<String, dynamic>>> queryDocuments({
//     required String collection,
//     Query Function(Query query)? queryBuilder,
//     int? limit,
//   }) async {
//     try {
//       Query query = _firestore.collection(collection);

//       if (queryBuilder != null) {
//         query = queryBuilder(query);
//       }

//       if (limit != null) {
//         query = query.limit(limit);
//       }

//       final snapshot = await query.get();
//       return snapshot.docs
//           .map((doc) => {
//                 'id': doc.id,
//                 ...doc.data() as Map<String, dynamic>,
//               })
//           .toList();
//     } catch (e) {
//       Console.printError('Query documents failed: $e');
//       return [];
//     }
//   }

//   // Real-time document listener
//   Stream<Map<String, dynamic>?> documentStream({
//     required String collection,
//     required String documentId,
//   }) {
//     return _firestore
//         .collection(collection)
//         .doc(documentId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         return {'id': snapshot.id, ...?snapshot.data()};
//       }
//       return null;
//     });
//   }

//   // Real-time collection listener
//   Stream<List<Map<String, dynamic>>> collectionStream({
//     required String collection,
//     Query Function(Query query)? queryBuilder,
//   }) {
//     Query query = _firestore.collection(collection);

//     if (queryBuilder != null) {
//       query = queryBuilder(query);
//     }

//     return query.snapshots().map((snapshot) {
//       return snapshot.docs
//           .map((doc) => {
//                 'id': doc.id,
//                 ...doc.data() as Map<String, dynamic>,
//               })
//           .toList();
//     });
//   }

//   // ============= STORAGE METHODS =============

//   // Upload file
//   Future<String?> uploadFile({
//     required File file,
//     required String path,
//     Function(double)? onProgress,
//   }) async {
//     try {
//       final ref = _storage.ref().child(path);
//       final uploadTask = ref.putFile(file);

//       if (onProgress != null) {
//         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//           final progress = snapshot.bytesTransferred / snapshot.totalBytes;
//           onProgress(progress);
//         });
//       }

//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       Console.printError('File upload failed: $e');
//       return null;
//     }
//   }

//   // Upload bytes
//   Future<String?> uploadBytes({
//     required Uint8List bytes,
//     required String path,
//     Map<String, String>? metadata,
//   }) async {
//     try {
//       final ref = _storage.ref().child(path);

//       SettableMetadata? settableMetadata;
//       if (metadata != null) {
//         settableMetadata = SettableMetadata(
//           customMetadata: metadata,
//         );
//       }

//       final snapshot = await ref.putData(bytes, settableMetadata);
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       Console.printError('Bytes upload failed: $e');
//       return null;
//     }
//   }

//   // Delete file
//   Future<bool> deleteFile(String path) async {
//     try {
//       await _storage.ref().child(path).delete();
//       return true;
//     } catch (e) {
//       Console.printError('File deletion failed: $e');
//       return false;
//     }
//   }

//   // ============= MESSAGING METHODS =============

//   // Setup messaging
//   Future<void> _setupMessaging() async {
//     try {
//       final settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//         announcement: false,
//         carPlay: false,
//         criticalAlert: false,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         Console.printSuccess('✅ Push notifications authorized');

//         String? token;
//         if (kIsWeb) {
//           token = await _messaging.getToken();
//         } else {
//           token = await _messaging.getToken();
//         }

//         if (token != null) {
//           _fcmTokenController.add(token);
//           Console.printInfo('FCM Token: $token');
//         }

//         _messaging.onTokenRefresh.listen((token) {
//           _fcmTokenController.add(token);
//           Console.printInfo('FCM Token refreshed: $token');
//         });
//       } else {
//         Console.printWarning('⚠️ Push notifications not authorized');
//       }
//     } catch (e) {
//       Console.printError('Messaging setup failed: $e');
//     }
//   }

//   // ============= ANALYTICS METHODS =============

//   // Log event
//   Future<void> logEvent({
//     required String name,
//     Map<String, dynamic>? parameters,
//   }) async {
//     try {
//       Map<String, Object>? analyticsParams;
//       if (parameters != null) {
//         analyticsParams = {};
//         parameters.forEach((key, value) {
//           if (value != null) {
//             analyticsParams![key] = value as Object;
//           }
//         });
//       }

//       await _analytics.logEvent(
//         name: name,
//         parameters: analyticsParams,
//       );
//     } catch (e) {
//       Console.printError('Analytics event logging failed: $e');
//     }
//   }

//   // Set user property
//   Future<void> setUserProperty({
//     required String name,
//     required String? value,
//   }) async {
//     try {
//       await _analytics.setUserProperty(
//         name: name,
//         value: value,
//       );
//     } catch (e) {
//       Console.printError('Set user property failed: $e');
//     }
//   }

//   // ============= CRASHLYTICS METHODS =============

//   // Setup Crashlytics
//   Future<void> _setupCrashlytics() async {
//     try {
//       if (!kIsWeb) {
//         await _crashlytics.setCrashlyticsCollectionEnabled(true);
//         FlutterError.onError = _crashlytics.recordFlutterError;
//         Console.printSuccess('✅ Crashlytics initialized');
//       } else {
//         Console.printInfo('ℹ️ Crashlytics is not supported on web');
//       }
//     } catch (e) {
//       Console.printError('Crashlytics setup failed: $e');
//     }
//   }

//   // Log error
//   void logError(dynamic error, StackTrace? stackTrace) {
//     if (!kIsWeb) {
//       _crashlytics.recordError(error, stackTrace);
//     }
//   }

//   // Set user identifier
//   Future<void> setUserId(String userId) async {
//     if (!kIsWeb) {
//       await _crashlytics.setUserIdentifier(userId);
//     }
//   }

//   // ============= REMOTE CONFIG METHODS =============

//   // Setup Remote Config
//   Future<void> _setupRemoteConfig() async {
//     try {
//       await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//         fetchTimeout: const Duration(minutes: 1),
//         minimumFetchInterval: const Duration(hours: 1),
//       ));

//       await _remoteConfig.setDefaults({
//         'welcome_message': 'Welcome to Aman!',
//         'feature_enabled': true,
//         'minimum_version': '1.0.0',
//       });

//       await fetchAndActivateRemoteConfig();
//       Console.printSuccess('✅ Remote Config initialized');
//     } catch (e) {
//       Console.printError('Remote Config setup failed: $e');
//     }
//   }

//   // Fetch and activate
//   Future<bool> fetchAndActivateRemoteConfig() async {
//     try {
//       final updated = await _remoteConfig.fetchAndActivate();
//       if (updated) {
//         Console.printSuccess('Remote Config updated');
//       }
//       return updated;
//     } catch (e) {
//       Console.printError('Remote Config fetch failed: $e');
//       return false;
//     }
//   }

//   // Get config value
//   T getConfigValue<T>(String key) {
//     final value = _remoteConfig.getValue(key);

//     if (T == String) {
//       return value.asString() as T;
//     } else if (T == int) {
//       return value.asInt() as T;
//     } else if (T == double) {
//       return value.asDouble() as T;
//     } else if (T == bool) {
//       return value.asBool() as T;
//     } else {
//       throw Exception('Unsupported type for Remote Config');
//     }
//   }

//   // ============= PRIVATE METHODS =============

//   void _setupAuthListener() {
//     _auth.authStateChanges().listen((User? user) {
//       _authStateController.add(user);
//       if (user != null) {
//         Console.printSuccess('User authenticated: ${user.uid}');
//         setUserId(user.uid);
//       } else {
//         Console.printInfo('User not authenticated');
//       }
//     });
//   }

//   Future<void> _postAuthSuccess(User? user) async {
//     if (user != null) {
//       await logEvent(
//         name: 'login',
//         parameters: {
//           'method': user.providerData.firstOrNull?.providerId ?? 'phone',
//         },
//       );

//       await setUserProperty(name: 'user_id', value: user.uid);

//       final token = await _messaging.getToken();
//       if (token != null) {
//         await updateUserToken(user.uid, token);
//       }
//     }
//   }

//   Future<void> updateUserToken(String userId, String token) async {
//     await updateDocument(
//       collection: 'users',
//       documentId: userId,
//       data: {
//         'fcmToken': token,
//         'lastActive': FieldValue.serverTimestamp(),
//       },
//     );
//   }

//   AuthResult _handleAuthException(FirebaseAuthException e) {
//     final message = _getAuthErrorMessage(e.code);
//     return AuthResult.error(message: message, code: e.code);
//   }

//   String _getAuthErrorMessage(String code) {
//     switch (code) {
//       case 'invalid-phone-number':
//         return 'The phone number is invalid.';
//       case 'too-many-requests':
//         return 'Too many requests. Try again later.';
//       case 'network-request-failed':
//         return 'Network error. Please check your connection.';
//       case 'invalid-verification-code':
//         return 'The verification code is invalid.';
//       case 'session-expired':
//         return 'The verification session has expired.';
//       case 'quota-exceeded':
//         return 'SMS quota exceeded. Try again later.';
//       case 'user-disabled':
//         return 'This user has been disabled.';
//       case 'operation-not-allowed':
//         return 'This operation is not allowed.';
//       case 'billing-not-enabled':
//         return 'SMS service not configured. Please use test numbers only.';
//       default:
//         // Check if error message contains billing info
//         if (code.toLowerCase().contains('billing')) {
//           return 'SMS service not configured. Please use test numbers only.';
//         }
//         return 'An error occurred. Please try again.';
//     }
//   }

//   // Cleanup
//   void dispose() {
//     _authStateController.close();
//     _fcmTokenController.close();
//   }
// }

// // Auth Result Models
// class AuthResult {
//   final bool success;
//   final User? user;
//   final String? message;
//   final String? code;

//   AuthResult({
//     required this.success,
//     this.user,
//     this.message,
//     this.code,
//   });

//   factory AuthResult.success({User? user}) {
//     return AuthResult(
//       success: true,
//       user: user,
//     );
//   }

//   factory AuthResult.error({
//     required String message,
//     String? code,
//   }) {
//     return AuthResult(
//       success: false,
//       message: message,
//       code: code,
//     );
//   }
// }

// class PhoneAuthResult {
//   final bool success;
//   final String? verificationId;
//   final int? resendToken;
//   final User? user;
//   final String? message;
//   final String? code;
//   final PhoneAuthResultType type;

//   PhoneAuthResult({
//     required this.success,
//     required this.type,
//     this.verificationId,
//     this.resendToken,
//     this.user,
//     this.message,
//     this.code,
//   });

//   factory PhoneAuthResult.codeSent({
//     required String verificationId,
//     int? resendToken,
//   }) {
//     return PhoneAuthResult(
//       success: true,
//       type: PhoneAuthResultType.codeSent,
//       verificationId: verificationId,
//       resendToken: resendToken,
//     );
//   }

//   factory PhoneAuthResult.autoVerified({required User user}) {
//     return PhoneAuthResult(
//       success: true,
//       type: PhoneAuthResultType.autoVerified,
//       user: user,
//     );
//   }

//   factory PhoneAuthResult.error({
//     required String message,
//     String? code,
//   }) {
//     return PhoneAuthResult(
//       success: false,
//       type: PhoneAuthResultType.error,
//       message: message,
//       code: code,
//     );
//   }
// }

// enum PhoneAuthResultType {
//   codeSent,
//   autoVerified,
//   error,
// }
