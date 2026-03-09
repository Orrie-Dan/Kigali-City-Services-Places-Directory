import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_overlay.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    final profile = auth.profile;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.settingsTitle),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (settings.errorMessage != null)
                  ErrorBanner(
                    message: settings.errorMessage!,
                    onClose: settings.clearError,
                  ),
                ListTile(
                  title: Text(profile?.displayName ?? ''),
                  subtitle: Text(profile?.email ?? ''),
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                SwitchListTile(
                  title:
                      const Text(AppStrings.locationNotificationsLabel),
                  value: settings.locationNotificationsEnabled,
                  onChanged: settings.setLocationNotificationsEnabled,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text(AppStrings.logoutButton),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (settings.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

