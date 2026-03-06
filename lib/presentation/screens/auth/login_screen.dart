import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/auth_provider.dart';

/// ログイン画面。
/// Google / Apple / Email の3方式。
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // エラー表示 (Snackbar)
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AppLogo(),
              const SizedBox(height: 48),
              _SocialSignInButton(
                label: 'Googleでログイン',
                icon: Icons.login,
                onTap: authState.isLoading
                    ? null
                    : () => ref
                        .read(authNotifierProvider.notifier)
                        .signInWithGoogle(),
              ),
              const SizedBox(height: 12),
              _SocialSignInButton(
                label: 'Appleでログイン',
                icon: Icons.apple,
                onTap: authState.isLoading
                    ? null
                    : () => ref
                        .read(authNotifierProvider.notifier)
                        .signInWithApple(),
              ),
              const SizedBox(height: 32),
              const _EmailSignInForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.sports_soccer, size: 72),
        const SizedBox(height: 12),
        Text(
          'Sports Calendar Sync',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '推しチームの試合をカレンダーへ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _EmailSignInForm extends ConsumerStatefulWidget {
  const _EmailSignInForm();

  @override
  ConsumerState<_EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends ConsumerState<_EmailSignInForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'メールアドレス'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passCtrl,
          decoration: const InputDecoration(labelText: 'パスワード'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => ref
              .read(authNotifierProvider.notifier)
              .signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text),
          child: const Text('ログイン'),
        ),
      ],
    );
  }
}
