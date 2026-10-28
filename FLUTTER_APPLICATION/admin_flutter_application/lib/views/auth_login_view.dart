import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/user_login_viewmodel.dart';
import '../widgets/akea_ui.dart';

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
    final wide = MediaQuery.sizeOf(context).width >= 860;

    final form = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: AkeaCard(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text(
                  'Log in to manage events, quotations and bookings.',
                  style: TextStyle(color: AkeaColors.muted, fontSize: 15),
                ),
                const SizedBox(height: 28),
                const AkeaFieldLabel('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const AkeaFieldLabel('Password'),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(vm.errorMessage!, style: const TextStyle(color: AkeaColors.statusDangerInk)),
                ],
                const SizedBox(height: 24),
                AkeaButton(
                  label: 'Log in',
                  expand: true,
                  loading: vm.loading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final ok = await vm.login(_emailCtrl.text.trim(), _passwordCtrl.text);
                    if (!context.mounted) return;
                    if (ok) {
                      if (vm.role == 'owner') {
                        context.go('/dashboard');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This admin app is for owners only')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final brand = ColoredBox(
      color: AkeaColors.sidebar,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AkeaLogoMark(size: 88),
            const SizedBox(height: 16),
            Text(
              'EST. 2020',
              style: GoogleFonts.sourceSans3(
                color: AkeaColors.gold,
                letterSpacing: 3,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'AkeaEvents Admin',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Every celebration, thoughtfully managed',
              style: GoogleFonts.sourceSans3(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    if (!wide) {
      return Scaffold(
        backgroundColor: AkeaColors.bg,
        body: ListView(
          children: [
            SizedBox(height: 280, child: brand),
            Padding(padding: const EdgeInsets.all(24), child: form),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(child: brand),
          Expanded(
            child: ColoredBox(
              color: AkeaColors.bg,
              child: form,
            ),
          ),
        ],
      ),
    );
  }
}
