import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                        begin: const Offset(0.8, 0.8), duration: 600.ms),

                const SizedBox(height: 24),

                // App name
                Text(
                  'BrainBash',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Train your brain, track your progress',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Google Sign-In button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authProvider.notifier)
                                .loginWithGoogle();
                          },
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 28,
                            color: AppColors.textPrimary,
                          ),
                    label: Text(
                      authState.isLoading
                          ? 'Signing in...'
                          : 'Continue with Google',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 16,
                              ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(
                          color: AppColors.border, width: 1.5),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, duration: 500.ms),

                const SizedBox(height: 32),

                // Footer text
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                  textAlign: TextAlign.center,
                ).animate(delay: 800.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
