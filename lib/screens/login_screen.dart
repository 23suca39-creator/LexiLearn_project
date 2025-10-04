import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;
  late Box userBox;

  @override
  void initState() {
    super.initState();
    initializeHive();
    // Show login dialog after first frame rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoginDialog();
    });
  }

  void initializeHive() async {
    await Hive.initFlutter();
    userBox = await Hive.openBox('userBox');
    if (userBox.get('email') != null) {
      _emailController.text = userBox.get('email');
      isChecked = true;
    }
    if (userBox.get('password') != null) {
      _passwordController.text = userBox.get('password');
    }
    setState(() {});
  }

  void login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show SnackBar via ScaffoldMessenger from post frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      });
      return;
    }

    const correctEmail = 'user@example.com';
    const correctPassword = 'password123';

    if (email == correctEmail && password == correctPassword) {
      if (isChecked) {
        userBox.put('email', email);
        userBox.put('password', password);
      } else {
        userBox.delete('email');
        userBox.delete('password');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Show SnackBar safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      });
    }
  }

  Future<void> showLoginDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog safely
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Empty container: UI is via dialog opened after frame
    return Container();
  }
}
