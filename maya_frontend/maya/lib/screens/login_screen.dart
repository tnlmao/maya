import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maya/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordResetMode = false;
  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'maya',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Allura',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              if (!_isPasswordResetMode)
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  errorText: _emailError,
                ),
              const SizedBox(height: 16.0),
              if (!_isPasswordResetMode)
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  errorText: _passwordError,
                  obscureText: true,
                ),
              const SizedBox(height: 16.0),
              if (!_isPasswordResetMode)
                ElevatedButton(
                  onPressed: () async {
                    if (_validateEmail(_emailController.text) &&
                        _validatePassword(_passwordController.text)) {
                      User? user = await _authService.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        // Navigate to the next screen or update UI
                        print('User signed in: ${user.displayName}');
                        Navigator.pushReplacementNamed(context, '/');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sign-in failed'),
                          ),
                        );
                      }
                    }
                  },
                  style: _buttonStyle(),
                  child: const Text('Sign in'),
                ),
              const SizedBox(height: 16.0),
              if (!_isPasswordResetMode)
                ElevatedButton(
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      // Navigate to the next screen or update UI
                      print('User signed in: ${user.displayName}');
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sign-in failed'),
                        ),
                      );
                    }
                  },
                  style: _buttonStyle(),
                  child: const Text('Sign in with Google'),
                ),
              if (!_isPasswordResetMode)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordResetMode = true;
                    });
                  },
                  child: const Text('Forgot password?'),
                ),
              if (_isPasswordResetMode)
                Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_validateEmail(_emailController.text)) {
                          await _authService.sendPasswordResetEmail(
                              _emailController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset link sent to your email'),
                            ),
                          );
                          setState(() {
                            _isPasswordResetMode = false;
                          });
                        }
                      },
                      style: _buttonStyle(),
                      child: const Text('Send reset link'),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordResetMode = false;
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = null;
      });
      return true;
    } else {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return false;
    }
  }

  bool _validatePassword(String password) {
    if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters long';
      });
      return false;
    }
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasSpecialCharacter = password.contains(RegExp(r'[!@#$&*]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasUppercase && !hasSpecialCharacter && !hasNumber) {
      setState(() {
        _passwordError =
            'Include an uppercase letter, a special character, and a number';
      });
      return false;
    } else if (!hasUppercase) {
      setState(() {
        _passwordError = 'Password must include an uppercase letter';
      });
      return false;
    } else if (!hasSpecialCharacter) {
      setState(() {
        _passwordError = 'Password must include a special character';
      });
      return false;
    } else if (!hasNumber) {
      setState(() {
        _passwordError = 'Password must include a number';
      });
      return false;
    }

    setState(() {
      _passwordError = null;
    });
    return true;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? errorText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        errorText: errorText,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    );
  }
}
