import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _emailFound = false;
  bool _showNewPassword = false;

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }
    final usersBox = HiveService.getUsersBox();
    if (usersBox.containsKey(email)) {
      setState(() => _emailFound = true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email not registered')));
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim().toLowerCase();
    final newPassword = _newPassController.text;
    final usersBox = HiveService.getUsersBox();
    final user = usersBox.get(email);
    if (user != null) {
      user.password = newPassword;
      await user.save();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password reset successful')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unexpected error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _emailFound ? _buildResetForm() : _buildEmailForm(),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Enter your registered email to reset password',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkEmail,
          child: const Text('Check Email', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text(
            'Enter new password',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _newPassController,
            obscureText: !_showNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter password';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetPassword,
            child: const Text('Reset Password', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
