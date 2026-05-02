import '../../domain/entities/user.dart';

class UserModel extends UserEntity {

  UserModel({
    required super.uid,
    required super.email,
    required super.role,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {

    return UserModel(
      uid: uid,
      email: data['email'],
      role: data['role'],
    );
  }
}