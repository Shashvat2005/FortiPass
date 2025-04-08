import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_manager/Pages/Super_secure.dart';
import 'package:password_manager/Pages/home.dart';
import 'package:password_manager/Pages/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _currentIndex = 3;
  bool isDarkMode = false;
  final TextEditingController _currentPasscodeController =
      TextEditingController();
  final TextEditingController _newPasscodeController = TextEditingController();
  final TextEditingController _confirmPasscodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  void dispose() {
    _currentPasscodeController.dispose();
    _newPasscodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }

  Future<void> _superSecure() async {
    if (PasswordDashboardState.isAuthenticating) return;

    final auth = LocalAuthentication();

    setState(() {
      PasswordDashboardState.isAuthenticating = true;
    });

    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access Super Secure',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuperSecureDashboard(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
    } finally {
      if (mounted) {
        setState(() {
          PasswordDashboardState.isAuthenticating =
              false; // Reset static variable
        });
      }
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  void _showChangePasscodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Passcode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasscodeController,
                decoration: const InputDecoration(
                  labelText: 'Current Passcode',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasscodeController,
                decoration: const InputDecoration(
                  labelText: 'New Passcode',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasscodeController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Passcode',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _changePasscode(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPasscode = prefs.getString('user_pin');

    if (_currentPasscodeController.text != storedPasscode) {
      _showError('Current passcode is incorrect');
      return;
    }

    if (_newPasscodeController.text.length != 6) {
      _showError('New passcode must be 6 digits');
      return;
    }

    if (_newPasscodeController.text != _confirmPasscodeController.text) {
      _showError('New passcodes do not match');
      return;
    }

    await prefs.setString('user_pin', _newPasscodeController.text);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passcode changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    _currentPasscodeController.clear();
    _newPasscodeController.clear();
    _confirmPasscodeController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.dark_mode, color: Color(0xFF2E7D32)),
                  title: const Text('Dark Theme'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: _toggleTheme,
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                  title: const Text('Change Passcode'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color(0xFF2E7D32)),
                  onTap: _showChangePasscodeDialog,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // Handle navigation based on index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PasswordDashboard(),
              ),
            );
            // Navigate to Home
            break;
          case 1:
            _superSecure();
            // Navigate to Analysis
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchDashboard(),
              ),
            );
            // Navigate to Search
            break;
          case 3:
            // Navigate to Settings
            break;
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: index_color(_currentIndex),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.security_rounded),
          label: 'Super Secure',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Color index_color(index1) {
    if (index1 == 1) {
      return Color(0xFF1565C0);
    } else {
      return Color(0xFF2E7D32);
    }
  }
}
