import 'package:chat_app_flutter/core/security/secure_storage_service.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class AuthError implements Exception {
  final String code;
  final String? details;

  const AuthError(this.code, [this.details]);

  @override
  String toString() => details ?? code;
}

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String getUserAvatar(String name) {
    return "https://ui-avatars.com/api/?background=6C63FF&color=fff&name=";
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await SecureStorageService.instance.cacheAuthFromFirebaseUser(user);
        await updateUserOnlineStatus(user.uid, true);

        DocumentSnapshot userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromDocument(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthError(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthError('unexpected_error', e.toString());
    }
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await SecureStorageService.instance.cacheAuthFromFirebaseUser(user);
        await user.updateDisplayName(name);

        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          photoUrl: AppConstants().getUserAvatarUrl(name),
          createdAt: DateTime.now(),
          isOnline: true,
        );

        // Save user to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthError(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthError('unexpected_error', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await updateUserOnlineStatus(currentUserId!, false);
      }
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      await ZIMKit().disconnectUser();
      await SecureStorageService.instance.clearAll();

      await _auth.signOut();
    } catch (e) {
      throw AuthError('sign_out_failed', e.toString());
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromDocument(userDoc);
      }
      return null;
    } catch (e) {
      throw AuthError('user_data_fetch_failed', e.toString());
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUserId != null) {
      return await getUserData(currentUserId!);
    }
    return null;
  }

  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      if (currentUserId == null) {
        throw const AuthError('not_logged_in');
      }
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (bio != null) updates['bio'] = bio;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId)
            .update(updates);

        if (name != null) {
          await currentUser?.updateDisplayName(name);
        }
      }
    } catch (e) {
      throw AuthError('profile_update_failed', e.toString());
    }
  }

  Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {
          'isOnline': isOnline,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromDocument(doc))
              .toList();
        });
  }

  Future<List<UserModel>> seachUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isGreaterThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .where((user) => user.uid != currentUserId)
          .toList();
    } catch (e) {
      throw AuthError('search_users_failed', e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthError(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthError('unexpected_error', e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUserId == null) {
        throw const AuthError('not_logged_in');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .delete();

      await currentUser?.delete();
    } catch (e) {
      throw AuthError('account_delete_failed', e.toString());
    }
  }

  String _mapAuthErrorCode(String? firebaseCode) {
    switch (firebaseCode) {
      case 'weak-password':
        return 'weak_password';
      case 'email-already-in-use':
        return 'email_already_in_use';
      case 'invalid-email':
        return 'invalid_email';
      case 'user-disabled':
        return 'user_disabled';
      case 'user-not-found':
        return 'user_not_found';
      case 'wrong-password':
        return 'wrong_password';
      case 'too-many-request':
        return 'too_many_attempts';
      case 'operation-not-allowed':
        return 'operation_not_allowed';
      case 'network-request-failed':
      case 'network-reqest-failed':
        return 'network_request_failed';
      default:
        return 'unknown_error';
    }
  }
}
