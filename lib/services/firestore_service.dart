import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing_model.dart';
import '../models/user_profile_model.dart';

/// Handles all Firestore CRUD operations for users and listings.
///
/// This is a pure Dart service and must not import Flutter UI packages.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';

  // User profile

  Future<void> createOrUpdateUserProfile(UserProfile profile) async {
    await _firestore
        .collection(usersCollection)
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return UserProfile.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
  }

  // Listings

  Stream<List<Listing>> watchAllListings() {
    return _firestore
        .collection(listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => Listing.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Listing>> watchListingsByUser(String uid) {
    return _firestore
        .collection(listingsCollection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => Listing.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  Future<String> createListing(Listing listing) async {
    final docRef =
        await _firestore.collection(listingsCollection).add(listing.toMap());
    return docRef.id;
  }

  Future<void> updateListing(Listing listing) {
    return _firestore
        .collection(listingsCollection)
        .doc(listing.id)
        .update(listing.toMap());
  }

  Future<void> deleteListing(String id) {
    return _firestore.collection(listingsCollection).doc(id).delete();
  }
}

