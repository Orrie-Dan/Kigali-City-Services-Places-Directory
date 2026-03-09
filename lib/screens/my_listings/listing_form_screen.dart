import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/categories.dart';
import '../../core/utils/validators.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_overlay.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, this.existing});

  final Listing? existing;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _category;
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _category = existing.category;
      _addressController.text = existing.address;
      _contactController.text = existing.contactNumber;
      _descriptionController.text = existing.description;
      _latitudeController.text = existing.latitude.toString();
      _longitudeController.text = existing.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    final provider = context.read<ListingsProvider>();
    final coords = await provider.useCurrentLocation();
    if (coords != null) {
      _latitudeController.text = coords.$1.toStringAsFixed(6);
      _longitudeController.text = coords.$2.toStringAsFixed(6);
    }
  }

  Future<void> _submit() async {
    final listingsProvider = context.read<ListingsProvider>();
    final auth = context.read<AuthProvider>();
    if (!_formKey.currentState!.validate()) return;

    final currentUser = auth.firebaseUser;
    if (currentUser == null) return;

    final lat = double.parse(_latitudeController.text.trim());
    final lng = double.parse(_longitudeController.text.trim());

    if (widget.existing == null) {
      await listingsProvider.createListing(
        name: _nameController.text.trim(),
        category: _category ?? kCategories.first,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        createdBy: currentUser.uid,
      );
    } else {
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        category: _category ?? kCategories.first,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
      );
      await listingsProvider.updateListing(updated);
    }

    if (mounted && listingsProvider.errorMessage == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();
    final isEdit = widget.existing != null;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              isEdit
                  ? AppStrings.listingFormTitleEdit
                  : AppStrings.listingFormTitleCreate,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (listingsProvider.errorMessage != null)
                    ErrorBanner(
                      message: listingsProvider.errorMessage!,
                      onClose: listingsProvider.clearError,
                    ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.listingNameLabel,
                          ),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _category ?? kCategories.first,
                          decoration: const InputDecoration(
                            labelText: AppStrings.listingCategoryLabel,
                          ),
                          items: kCategories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _category = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.listingAddressLabel,
                          ),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.listingContactLabel,
                          ),
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.listingDescriptionLabel,
                          ),
                          minLines: 2,
                          maxLines: 4,
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.listingLatitudeLabel,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: Validators.latitude,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.listingLongitudeLabel,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: Validators.longitude,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _useMyLocation,
                            icon: const Icon(Icons.my_location),
                            label:
                                const Text(AppStrings.useMyLocationButton),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: listingsProvider.isLoading ? null : _submit,
                          child: const Text(AppStrings.saveButton),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (listingsProvider.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

