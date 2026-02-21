import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: February 2025',
                style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _Section(
                theme: theme,
                title: 'Introduction',
                body:
                    'BrainBash ("we", "our", or "us") is committed to protecting your privacy. '
                    'This Privacy Policy explains how we collect, use, and safeguard your information when you use our app and services.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'Information We Collect',
                body:
                    'We may collect information you provide directly (e.g. when you sign in with Google, such as name and email), '
                    'usage data (e.g. quiz scores, response times, and game results), and device or technical information necessary to run the app.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'How We Use Your Information',
                body:
                    'We use your information to provide and improve the app, personalize your experience, '
                    'display your progress and leaderboard standings, and to communicate with you when necessary.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'Data Sharing',
                body:
                    'We do not sell your personal information. We may share data with service providers that help us operate the app (e.g. hosting, analytics). '
                    'When you sign in with Google, Google\'s privacy policy also applies to that sign-in process.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'Security',
                body:
                    'We take reasonable measures to protect your data. However, no method of transmission or storage is completely secure.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'Your Choices',
                body:
                    'You can choose not to sign in and use the app as a guest. You may request access to or deletion of your data by contacting us.',
              ),
              const SizedBox(height: 20),
              _Section(
                theme: theme,
                title: 'Contact Us',
                body:
                    'If you have questions about this Privacy Policy, please contact us at the support or contact details provided in the app or on our website.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.title,
    required this.body,
  });

  final ThemeData theme;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
