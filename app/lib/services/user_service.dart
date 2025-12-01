import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  /// Create or update a user document in Firestore
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  /// Get a user document from Firestore by UID
  /// Returns null if the document does not exist
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get();

      if (!docSnapshot.exists) {
        print('User document with uid $uid does not exist');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('User document with uid $uid has no data');
        return null;
      }

      return UserModel.fromMap(data);
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }
}
