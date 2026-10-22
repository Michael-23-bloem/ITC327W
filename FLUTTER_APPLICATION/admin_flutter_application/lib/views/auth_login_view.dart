import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/user_login_viewmodel.dart';

class AuthLoginView extends StatefulWidget {
  const AuthLoginView({super.key});

  @override
  State<AuthLoginView> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends State<AuthLoginView> {
  final _emailCtrl = TextEditingController(text: 'owner@test.com');
  final _passwordCtrl = TextEditingController(text: 'Test1234!');
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserLoginViewModel>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(209, 172, 130, 68),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_seat, size: 80, color: Color(0xFF6A1B9A)),
                const SizedBox(height: 16),
                const Text('AkeaEvents Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 124, 37))),
                const SizedBox(height: 8),
                const Text('Owner login only', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 8),

                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: vm.loading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      
                      final ok = await vm.login(_emailCtrl.text.trim(), _passwordCtrl.text);
                      
                      if (!mounted) return;
                      
                      if (ok) {
                        // Route by role
                        if (vm.role == 'owner') {
                          context.go('/dashboard'); // owner dashboard
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('This admin app is for owners only')),
                          );
                        }
                      }
                    },
                    child: vm.loading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
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