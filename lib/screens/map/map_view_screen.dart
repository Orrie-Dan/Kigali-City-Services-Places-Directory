import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocationPermission());
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  LatLng _initialCamera(List<Listing> listings) {
    if (listings.isNotEmpty) {
      final first = listings.first;
      return LatLng(first.latitude, first.longitude);
    }
    // Kigali approximate center
    return const LatLng(-1.94995, 30.05885);
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();
    final listings = listingsProvider.listings;

    final markers = listings
        .map(
          (listing) => Marker(
            markerId: MarkerId(listing.id),
            position: LatLng(listing.latitude, listing.longitude),
            infoWindow: InfoWindow(
              title: listing.name,
              snippet: listing.category,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ListingDetailScreen(listing: listing),
                  ),
                );
              },
            ),
          ),
        )
        .toSet();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.mapViewTitle),
          ),
          body: SizedBox.expand(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCamera(listings),
                zoom: 13,
              ),
              markers: markers,
              myLocationButtonEnabled: true,
            ),
          ),
        ),
        if (listingsProvider.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

