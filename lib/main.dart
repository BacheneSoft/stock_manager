import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/article_provider.dart';
import 'providers/category_provider.dart';
import 'providers/client_provider.dart';
import 'providers/vente_provider.dart';
import 'providers/fournisseur_provider.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'utils/activation_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isActivated = prefs.getBool('isActivated') ?? false;

  // Check if activation has expired (for test keys)
  if (isActivated) {
    final activationType = prefs.getString('activation_type');
    if (activationType == 'test') {
      final activationTimestamp = prefs.getInt('activation_timestamp');
      final expirationMinutes = prefs.getInt('test_expiration_minutes');

      if (activationTimestamp != null && expirationMinutes != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedMinutes = (now - activationTimestamp) ~/ (1000 * 60);

        if (elapsedMinutes >= expirationMinutes) {
          // Activation expired, clear activation data
          await prefs.setBool('isActivated', false);
          await prefs.remove('activation_type');
          await prefs.remove('activation_timestamp');
          await prefs.remove('test_expiration_minutes');
          isActivated = false;
        }
      }
    }
  }

  runApp(MyApp(isActivated: isActivated));
}

class MyApp extends StatelessWidget {
  final bool isActivated;
  const MyApp({Key? key, required this.isActivated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1976D2),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFB300),
      onSecondary: Color(0xFF212121),
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      background: Color(0xFFF5F6FA),
      onBackground: Color(0xFF212121),
      surface: Colors.white,
      onSurface: Color(0xFF212121),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => VenteProvider()),
        ChangeNotifierProvider(create: (_) => FournisseurProvider()),
      ],
      child: MaterialApp(
        title: 'Stock Manager',
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: colorScheme.background,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.primary),
            titleTextStyle: GoogleFonts.poppins(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            color: Colors.white, // <-- Pure white for contrast
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: isActivated ? const _PinLockWrapper() : const ActivationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

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

      // Check if this is a test key
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
        // Regular key - permanent activation
        await prefs.setString('activation_type', 'permanent');
        await prefs.remove('activation_timestamp');
        await prefs.remove('test_expiration_minutes');
      }

      setState(() {
        _loading = false;
      });
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Clé d\'activation',
                          errorText: _error,
                          border: OutlineInputBorder(),
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

class _PinLockWrapper extends StatefulWidget {
  const _PinLockWrapper({Key? key}) : super(key: key);

  @override
  State<_PinLockWrapper> createState() => _PinLockWrapperState();
}

class _PinLockWrapperState extends State<_PinLockWrapper> {
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
                    ? Text(
                      'Vous pouvez réinitialiser le code PIN avec votre empreinte digitale ou reconnaissance faciale.',
                    )
                    : Text(
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
                    // Move dialog pop before biometric for better UX
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
                          // Unlock immediately after PIN removal
                          widget.onUnlock();
                          // Optionally show a snackbar
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
