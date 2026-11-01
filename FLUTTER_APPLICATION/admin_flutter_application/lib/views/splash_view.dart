import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/akea_theme.dart';
import '../widgets/akea_ui.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _continue() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continue,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.black45,
                    Colors.black54,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const AkeaLogoMark(size: 88),
                  const SizedBox(height: 20),
                  Text(
                    'EST. 2020',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AkeaColors.gold,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AkeaEvents Admin',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(flex: 5),
                  AnimatedBuilder(
                    animation: _bounce,
                    builder: (context, child) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20 + _bounce.value),
                        child: child,
                      );
                    },
                    child: IconButton(
                      onPressed: _continue,
                      icon: const Icon(
                        Icons.keyboard_double_arrow_down,
                        size: 32,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}