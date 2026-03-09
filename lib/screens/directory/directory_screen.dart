import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/listings_provider.dart';
import '../../screens/directory/listing_detail_screen.dart';
import '../../widgets/category_filter_bar.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/loading_overlay.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Kigali City'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listingsProvider.errorMessage != null)
                  ErrorBanner(
                    message: listingsProvider.errorMessage!,
                    onClose: listingsProvider.clearError,
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: AppStrings.searchHint,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: listingsProvider.setSearchQuery,
                  ),
                ),
                CategoryFilterBar(
                  categories: listingsProvider.availableCategories,
                  selected: listingsProvider.selectedCategory,
                  onSelected: listingsProvider.setCategory,
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Near you',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final listings = listingsProvider.listings;
                      if (listings.isEmpty) {
                        return const Center(
                          child: Text(AppStrings.noListings),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ListingDetailScreen(listing: listing),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (listingsProvider.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

