import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenSettings;

  const AppDrawer({
    super.key,
    required this.onOpenAccount,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              accountName: const Text('Guest user'),
              accountEmail: const Text('Tap to sign in'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                onOpenAccount();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                onOpenSettings();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Flood Monitor – Wales River'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
