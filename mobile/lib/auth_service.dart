import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// Client ID run command ke saath aati hai (code ya GitHub mein nahi jaati)
const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

// Chrome: 127.0.0.1, Android emulator: 10.0.2.2 (emulator ka "computer" address)
String get apiBase => kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final ValueNotifier<Map<String, dynamic>?> user = ValueNotifier(null);
  final ValueNotifier<bool> busy = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  String? accessToken;
  bool _started = false;

  Future<void> init() async {
    if (_started) return;
    _started = true;
    if (googleClientId.isEmpty) {
      error.value = 'GOOGLE_CLIENT_ID missing. Run command mein --dart-define lagaiye.';
      return;
    }
    try {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? googleClientId : null,
        serverClientId: kIsWeb ? null : googleClientId,
      );
      GoogleSignIn.instance.authenticationEvents.listen(_onEvent, onError: (_) {
        error.value = 'Google sign-in cancel ya fail ho gaya.';
      });
    } catch (e) {
      error.value = 'Google setup fail: ${e.runtimeType}';
    }
  }

  // Mobile par button yahi chalata hai. Web par Google ka apna button hota hai.
  Future<void> startSignIn() async {
    error.value = null;
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (_) {
      error.value = 'Google sign-in cancel ya fail ho gaya.';
    }
  }

  void _onEvent(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      _backendLogin(event.user);
    }
  }

  Future<void> _backendLogin(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      error.value = 'Google se ID token nahi mila.';
      return;
    }
    busy.value = true;
    error.value = null;
    try {
      final res = await http
          .post(
            Uri.parse('$apiBase/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        accessToken = data['access_token'] as String;
        user.value = data['user'] as Map<String, dynamic>;
      } else {
        error.value = 'Login fail (${res.statusCode}). Backend terminal dekhiye.';
      }
    } catch (_) {
      error.value = 'Server se connect nahi ho paya. Backend chal raha hai?';
    } finally {
      busy.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    accessToken = null;
    user.value = null;
  }
}