import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onLoginRequested;
  const RegisterScreen({Key? key, this.onLoginRequested}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final RegExp _emailRegex = RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$");
  bool _showPassword = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final usersBox = HiveService.getUsersBox();
    final email = _emailCtrl.text.trim().toLowerCase();

    if (usersBox.containsKey(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already registered')));
      return;
    }

    final user = User(
      name: _nameCtrl.text.trim(),
      email: email,
      password: _passwordCtrl.text,
    );

    await usersBox.put(email, user);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));

    if (widget.onLoginRequested != null) {
      widget.onLoginRequested!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter your email';
                  if (!_emailRegex.hasMatch(val)) return 'Enter a valid email';
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter password';
                  if (val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
