class UserModel {
  final String uid;
  final String email;
  final int? caloriesGoal;
  final int? proteinGoal;
  final int? carbsGoal;
  final int? fatsGoal;

  UserModel({
    required this.uid,
    required this.email,
    this.caloriesGoal,
    this.proteinGoal,
    this.carbsGoal,
    this.fatsGoal,
  });

  /// Convert UserModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'caloriesGoal': caloriesGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatsGoal': fatsGoal,
    };
  }

  /// Create UserModel from Map (e.g., from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      caloriesGoal: map['caloriesGoal'] as int?,
      proteinGoal: map['proteinGoal'] as int?,
      carbsGoal: map['carbsGoal'] as int?,
      fatsGoal: map['fatsGoal'] as int?,
    );
  }
}
