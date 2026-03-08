import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class PinLockWrapper extends StatefulWidget {
  const PinLockWrapper({Key? key}) : super(key: key);

  @override
  State<PinLockWrapper> createState() => _PinLockWrapperState();
}

class _PinLockWrapperState extends State<PinLockWrapper> {
  String? _pin;
  bool _loading = true;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pin = prefs.getString('app_pin');
      _loading = false;
      _unlocked = _pin == null;
    });
  }

  void _onUnlock() {
    setState(() {
      _unlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_unlocked) {
      return const HomeScreen();
    }
    return PinEntryScreen(correctPin: _pin!, onUnlock: _onUnlock);
  }
}

class PinEntryScreen extends StatefulWidget {
  final String correctPin;
  final VoidCallback onUnlock;
  const PinEntryScreen({
    Key? key,
    required this.correctPin,
    required this.onUnlock,
  }) : super(key: key);

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _obscure = true;
  bool _biometricAvailable = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available =
        await _localAuth.canCheckBiometrics &&
        await _localAuth.isDeviceSupported();
    setState(() {
      _biometricAvailable = available;
    });
  }

  Future<void> _tryBiometric() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Déverrouiller avec biométrie',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (didAuth) {
        widget.onUnlock();
      }
    } catch (e) {
      setState(() {
        _error = 'Échec de la biométrie';
      });
    }
  }

  void _checkPin() {
    if (_controller.text.trim() == widget.correctPin) {
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'Code PIN incorrect';
      });
    }
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Réinitialiser le code PIN',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content:
                _biometricAvailable
                    ? const Text(
                      'Vous pouvez réinitialiser le code PIN avec votre empreinte digitale ou reconnaissance faciale.',
                    )
                    : const Text(
                      'Pour réinitialiser le code PIN, vous devez effacer les données de l’application dans les paramètres de votre appareil. Cela supprimera toutes vos données.',
                    ),
            actions: [
              if (_biometricAvailable)
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      final didAuth = await _localAuth.authenticate(
                        localizedReason: 'Réinitialiser le code PIN',
                        options: const AuthenticationOptions(
                          biometricOnly: true,
                          stickyAuth: true,
                        ),
                      );
                      if (didAuth) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('app_pin');
                        if (mounted) {
                          widget.onUnlock();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Code PIN réinitialisé avec succès.',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                      }
                    } catch (_) {}
                  },
                  label: Text(
                    'Utiliser la biométrie',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Entrez le code PIN',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    obscureText: _obscure,
                    maxLength: 6,
                    style: GoogleFonts.poppins(fontSize: 20, letterSpacing: 8),
                    decoration: InputDecoration(
                      labelText: 'Code PIN',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _checkPin(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.lock_open_rounded,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _checkPin,
                      label: Text(
                        'Déverrouiller',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_biometricAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _tryBiometric,
                          label: Text(
                            'Déverrouiller avec biométrie',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _showForgotPinDialog,
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
