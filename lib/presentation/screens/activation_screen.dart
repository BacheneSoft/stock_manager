import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/activation_keys.dart';
import '../../core/config/app_config.dart';
import 'home_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({Key? key}) : super(key: key);

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _activate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final key = _controller.text.trim();
    if (validActivationKeys.contains(key)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isActivated', true);

      if (isTestKey(key)) {
        final expirationMinutes = getTestKeyExpirationMinutes(key);
        if (expirationMinutes != null) {
          await prefs.setString('activation_type', 'test');
          await prefs.setInt(
            'activation_timestamp',
            DateTime.now().millisecondsSinceEpoch,
          );
          await prefs.setInt('test_expiration_minutes', expirationMinutes);
        }
      } else {
        await prefs.setString('activation_type', 'permanent');
        await prefs.remove('activation_timestamp');
        await prefs.remove('test_expiration_minutes');
      }

      setState(() {
        _loading = false;
      });
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _error = 'Clé d\'activation invalide';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.vpn_key_rounded,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Activation requise',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Veuillez entrer votre clé d\'activation pour utiliser l\'application.',
                        textAlign: TextAlign.center,
                      ),
                      if (AppConfig.isDemoMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'La période d\'essai de ${AppConfig.demoTrialDays} jours est terminée.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Clé d\'activation',
                          errorText: _error,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: !_loading,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _activate,
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Activer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

