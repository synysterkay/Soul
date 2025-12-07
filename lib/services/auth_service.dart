import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'email_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final EmailService _emailService = EmailService();

  // Initialize Google Sign In
  Future<void> initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web platform: use GoogleAuthProvider directly with popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Sign in with popup
        final userCredential = await _auth.signInWithPopup(googleProvider);

        // Create or update user in Firestore
        if (userCredential.user != null) {
          await _createOrUpdateUser(userCredential.user!);
        }

        return userCredential;
      } else {
        // Mobile/Desktop: use GoogleSignIn package
        // Initialize if needed (can be called multiple times safely)
        await initializeGoogleSignIn();

        // Trigger the authentication flow
        final GoogleSignInAccount googleUser =
            await _googleSignIn.authenticate();

        // Obtain the auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential (v7 only provides idToken)
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        final userCredential = await _auth.signInWithCredential(credential);

        // Create or update user in Firestore
        if (userCredential.user != null) {
          await _createOrUpdateUser(userCredential.user!);
        }

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in with Apple - REMOVED
  /// Apple Sign In has been removed from the app
  @Deprecated('Apple Sign In is no longer supported')
  Future<UserCredential?> signInWithApple() async {
    throw Exception('Apple Sign In is no longer supported in this version');
  }

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(FirebaseAuthException error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in with phone number using OTP
  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with phone: $e');
      rethrow;
    }
  }

  /// Link phone number to existing account
  Future<void> linkPhoneNumber({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.linkWithCredential(credential);

      // Update user's phone number in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error linking phone number: $e');
      rethrow;
    }
  }

  /// Create or update user in Firestore
  Future<void> _createOrUpdateUser(User user, {String? displayName}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    final isNewUser = !docSnapshot.exists;

    if (docSnapshot.exists) {
      // Update existing user
      await userDoc.update({
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new user
      final newUser = UserModel.fromAuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: displayName ?? user.displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
      );

      await userDoc.set(newUser.toFirestore());
    }

    // Sync email with OneSignal for push & email notifications
    if (user.email != null && user.email!.isNotEmpty) {
      await _emailService.syncUserEmail(
        userId: user.uid,
        email: user.email!,
        name: displayName ?? user.displayName ?? 'User',
      );

      // Send welcome email only for new users
      if (isNewUser) {
        await _emailService.sendWelcomeEmail(
          recipientEmail: user.email!,
          recipientName: displayName ?? user.displayName ?? 'there',
        );
      }
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Stream user data from Firestore
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update user profile
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Find users by phone numbers (for contacts matching)
  Future<List<UserModel>> findUsersByPhoneNumbers(
      List<String> phoneNumbers) async {
    if (phoneNumbers.isEmpty) return [];

    try {
      // Firestore 'in' query limit is 10, so we need to batch
      final List<UserModel> users = [];

      for (int i = 0; i < phoneNumbers.length; i += 10) {
        final batch = phoneNumbers.skip(i).take(10).toList();
        final querySnapshot = await _firestore
            .collection('users')
            .where('phoneNumber', whereIn: batch)
            .get();

        for (final doc in querySnapshot.docs) {
          users.add(UserModel.fromFirestore(doc));
        }
      }

      return users;
    } catch (e) {
      print('Error finding users by phone: $e');
      return [];
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
