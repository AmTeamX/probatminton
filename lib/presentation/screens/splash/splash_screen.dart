import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _navigated = false;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _textSlide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _textController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted && !_navigated) _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    if (_navigated || !mounted) return;
    final authState = ref.read(authProvider);
    authState.when(
      loading: () {
        ref.listenManual<AsyncValue<AuthStatus>>(authProvider, (_, next) {
          if (!_navigated && mounted) _navigate(next);
        });
      },
      error: (_, _) => _navigate(authState),
      data: (_) => _navigate(authState),
    );
  }

  void _navigate(AsyncValue<AuthStatus> authState) {
    if (_navigated || !mounted) return;
    _navigated = true;
    authState.when(
      loading: () => _navigated = false,
      error: (_, _) => context.go('/login'),
      data: (status) {
        if (status is Authenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, Color(0xFF00802B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Animated logo
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: const Icon(
                    Icons.sports_tennis,
                    size: 96,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Animated text
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: FadeTransition(opacity: _textFade, child: child),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'Pro Badminton',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find & Book Courts Near You',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Animated loading dots
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final progress =
                          (_dotsController.value * 3 - index) % 1.0;
                      final scale = progress < 0.5
                          ? progress * 2
                          : 2 - progress * 2;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.scale(
                          scale: 0.5 + scale * 0.5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.4 + scale * 0.6,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
