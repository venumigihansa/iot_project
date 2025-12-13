import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
  );

  GoogleSignInAccount? _currentUser;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });
    _googleSignIn.signInSilently().catchError((_) => null);
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      setState(() => _error = 'Could not sign in: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          CircleAvatar(
            radius: 40,
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Guest',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Sign in to sync preferences',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loading
                ? null
                : user == null
                    ? _handleSignIn
                    : _handleSignOut,
            icon: Icon(user == null ? Icons.account_circle : Icons.logout),
            label: Text(user == null ? 'Sign in with Google' : 'Sign out'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Account security'),
            subtitle: const Text('Manage connected services and sessions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Alert preferences'),
            subtitle: const Text('Coming soon'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
