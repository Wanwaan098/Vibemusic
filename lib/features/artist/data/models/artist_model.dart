import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/artist.dart';

class ArtistModel extends Artist {
  ArtistModel({
    required super.id,
    required super.name,
    required super.biography,
    required super.avatarUrl,
    required super.createdAt,
  });

  factory ArtistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ArtistModel(
      id: doc.id,
      name: data['name'] ?? '',
      biography: data['biography'] ?? '',
      avatarUrl: data['avatar_url'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "biography": biography,
      "avatar_url": avatarUrl,
      "createdAt": createdAt,
    };
  }
}