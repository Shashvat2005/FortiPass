import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_manager/Pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _showPasscode = false;
  final TextEditingController _passcodeController = TextEditingController();
  final _gradientColors = const [Color(0xFF4CAF50), Color(0xFF2E7D32)];
  final _backgroundColors = const [Color(0xFFF1F8E9), Color(0xFFE8F5E9)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkFirstLaunch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requireAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('has_launched') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('has_launched', false);
      setState(() => _showPasscode = false);
    }
  }

  void _requireAuth() async {
    if (_isAuthenticated) return; // Prevent re-triggering if already authenticated
  }

  Future<void> _authenticate() async {
    if (_isAuthenticated) {
      return; // Prevent re-triggering if already authenticated
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your passwords',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        setState(() => _isAuthenticated = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PasswordDashboard(),
            settings: const RouteSettings(name: '/home'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPasscode = prefs.getString('user_pin');

    if (_passcodeController.text == storedPasscode) {
      setState(() => _isAuthenticated = true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PasswordDashboard(),
            settings: const RouteSettings(name: '/home'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid passcode. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        _passcodeController.clear();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background
      setState(() {
        _isAuthenticated = false;
        _showPasscode = false;
        _passcodeController.clear();
      });
    } else if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      // App coming back to foreground
        if (mounted) {
          if (_isAuthenticated) return; // Or show passcode screen depending on your logic
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _backgroundColors,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showPasscode) ...[
                  _buildAuthHeader(),
                  const SizedBox(height: 40),
                  _buildAuthOptions(),
                ] else ...[
                  _buildPasscodeEntry(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(
            Icons.lock_outline,
            size: 48,
            color: _gradientColors[1],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Secure Access',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D375B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your authentication method',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthOptions() {
    return Column(
      children: [
        _buildGradientButton(
          icon: Icons.fingerprint,
          label: 'Use Biometrics',
          onPressed: _authenticate,
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          icon: Icons.pin_outlined,
          label: 'Use Passcode',
          onPressed: () => setState(() => _showPasscode = true),
        ),
      ],
    );
  }

  Widget _buildPasscodeEntry() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Enter Passcode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D375B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _passcodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(letterSpacing: 8),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              label: 'Verify Passcode',
              onPressed: _verifyPasscode,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showPasscode = false;
                  _passcodeController.clear();
                });
              },
              child: Text(
                'Back to Options',
                style: TextStyle(
                  color: _gradientColors[1],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _gradientColors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _gradientColors[1].withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: _gradientColors[1]),
      label: Text(
        label,
        style: TextStyle(
          color: _gradientColors[1],
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: BorderSide(color: _gradientColors[1]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
