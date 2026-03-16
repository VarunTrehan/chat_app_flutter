import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

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
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occured $e';
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
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Signup error: $e';
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await updateUserOnlineStatus(currentUserId!, false);
      }
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      await ZIMKit().disconnectUser();

      await _auth.signOut();
    } catch (e) {
      throw 'Error Signing Out: $e';
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
      throw 'Error getting user data: $e';
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
      if (currentUserId == null) throw 'No user logged in';
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
      throw 'Error updating profile: $e';
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
      throw 'Error search users: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error sending reset email: $e';
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUserId == null) throw 'No User logged in';

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .delete();

      await currentUser?.delete();
    } catch (e) {
      throw 'Error deleting account: $e';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'user-disabled':
        return 'This user account has been disbaled';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-request':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'network-reqest-failed':
        return AppConstants.networkErrorMessage;
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
