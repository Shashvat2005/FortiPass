import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_manager/Pages/Authentication/Auth_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  Future<void> _savePINAndEnableBiometrics() async {
    if (_pinController.text.length != 6) return;

    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _pinController.text);
    await prefs.setBool('has_pin', true);

    final localAuth = LocalAuthentication();
    if (await localAuth.canCheckBiometrics) {
      await localAuth.authenticate(
        localizedReason: 'Enable biometric for login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    }

    setState(() => _isLoading = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSecurityIllustration(),
                const SizedBox(height: 32),
                _buildPinInputField(),
                const SizedBox(height: 32),
                _buildActionButton(),
                const SizedBox(height: 24),
                _buildBiometricInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityIllustration() {
    return Column(
      children: [
        Icon(Icons.security, size: 80, color: Color(0xFF2D375B)),
        const SizedBox(height: 16),
        const Text(
          'Secure Your Vault',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D375B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a 6-digit PIN and enable biometric authentication\nfor enhanced security',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF2D375B).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            'Enter PIN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D375B)),
            ),
        ),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: _obscurePin,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D375B)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePin ? Icons.visibility_off : Icons.visibility,
                color: Color(0xFFB0BEC5),
              ),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
            hintText: '••••••',
            hintStyle: TextStyle(
              color: Color(0xFFB0BEC5),
              letterSpacing: 8,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePINAndEnableBiometrics,  // Removed conditional check
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'SAVE & CONTINUE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBiometricInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fingerprint, size: 24, color: Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Flexible(
        child: Text(
          'Biometric authentication will be enabled automatically',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D375B).withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      ],
    );
  }
}