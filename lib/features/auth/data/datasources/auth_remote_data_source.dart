// auth_remote_data_source.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.auth, this.firestore);

  Future<User> register(String email, String password, {String? name}) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await firestore.collection("users").doc(credential.user!.uid).set({
      "email": email,
      "role": "user",
      if (name != null && name.isNotEmpty) "name": name,
    });

    return credential.user!;
  }

  Future<User> login(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<String> getRole(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();
    return doc.data()?["role"] ?? "user";
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}
