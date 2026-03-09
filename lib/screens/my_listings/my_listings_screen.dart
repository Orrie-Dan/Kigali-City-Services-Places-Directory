import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/loading_overlay.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final currentUid = auth.firebaseUser?.uid;

    final myListings = currentUid == null
        ? <Listing>[]
        : listingsProvider.listings
            .where((listing) => listing.createdBy == currentUid)
            .toList();

    Future<void> confirmDelete(Listing listing) async {
      final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(AppStrings.deleteButton),
              content: Text(
                'Delete "${listing.name}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(AppStrings.deleteButton),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldDelete) {
        await listingsProvider.deleteListing(listing.id);
      }
    }

    void openForm([Listing? listing]) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ListingFormScreen(existing: listing),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.tabMyListings),
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (listingsProvider.errorMessage != null)
                  ErrorBanner(
                    message: listingsProvider.errorMessage!,
                    onClose: listingsProvider.clearError,
                  ),
                Expanded(
                  child: myListings.isEmpty
                      ? const Center(
                          child: Text(AppStrings.myListingsEmpty),
                        )
                      : ListView.builder(
                          itemCount: myListings.length,
                          itemBuilder: (context, index) {
                            final listing = myListings[index];
                            return ListingCard(
                              listing: listing,
                              onTap: () => openForm(listing),
                              onEdit: () => openForm(listing),
                              onDelete: () => confirmDelete(listing),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openForm(),
            child: const Icon(Icons.add),
          ),
        ),
        if (listingsProvider.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

