import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/categories.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class ListingsProvider extends ChangeNotifier {
  ListingsProvider({
    required FirestoreService firestoreService,
    required LocationService locationService,
  })  : _firestoreService = firestoreService,
        _locationService = locationService;

  final FirestoreService _firestoreService;
  final LocationService _locationService;

  bool isLoading = false;
  String? errorMessage;

  final List<Listing> _allListings = <Listing>[];
  String? _selectedCategory;
  String _searchQuery = '';

  StreamSubscription<List<Listing>>? _allListingsSub;

  List<Listing> get listings {
    Iterable<Listing> result = _allListings;

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where(
        (listing) => listing.category == _selectedCategory,
      );
    }

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      result = result.where(
        (listing) => listing.name.toLowerCase().contains(queryLower),
      );
    }

    return result.toList();
  }

  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get availableCategories => kCategories;

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void startListeningToListings() {
    _allListingsSub?.cancel();
    _allListingsSub = _firestoreService.watchAllListings().listen(
      (items) {
        _allListings
          ..clear()
          ..addAll(items);
        notifyListeners();
      },
      onError: (error) {
        errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final listing = Listing(
        id: '',
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        timestamp: DateTime.now(),
      );
      await _firestoreService.createListing(listing);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateListing(Listing listing) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateListing(listing);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteListing(id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<(double latitude, double longitude)?> useCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return null;
      return (position.latitude, position.longitude);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allListingsSub?.cancel();
    super.dispose();
  }
}

