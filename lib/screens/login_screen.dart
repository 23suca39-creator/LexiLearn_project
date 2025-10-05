import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/user.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterRequested;
  const LoginScreen({Key? key, this.onRegisterRequested}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showPassword = false;
  late AnimationController _animationController;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _formFadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadRememberedCredentials() {
    final box = HiveService.getRememberMeBox();
    final savedEmail = box.get('email');
    final savedPassword = box.get('password');
    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final usersBox = HiveService.getUsersBox();
    final user = usersBox.get(email);

    if (user == null || user.password != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
      return;
    }

    final rememberBox = HiveService.getRememberMeBox();
    if (_rememberMe) {
      await rememberBox.put('email', email);
      await rememberBox.put('password', password);
    } else {
      await rememberBox.delete('email');
      await rememberBox.delete('password');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FadeTransition(
            opacity: _formFadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 100, color: theme.primaryColor),
                const SizedBox(height: 20),
                Text('Welcome',
                    style:
                        textTheme.headlineSmall?.copyWith(fontFamily: 'OpenDyslexic')),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                          ),
                          const Text('Remember Me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:
                            const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No account?'),
                          TextButton(
                            onPressed: widget.onRegisterRequested ??
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen()),
                                  );
                                },
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
