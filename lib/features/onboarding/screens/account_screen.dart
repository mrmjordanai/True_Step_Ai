import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/primary_button.dart';

/// Account creation screen with multiple sign-in options
///
/// Options:
/// - Apple Sign-In (Coming Soon)
/// - Google Sign-In (Coming Soon)
/// - Email/Password
/// - Continue as Guest (Anonymous)
class AccountScreen extends ConsumerStatefulWidget {
  /// Callback when account is created/signed in
  final VoidCallback onContinue;

  /// Optional callback when user taps Skip
  final VoidCallback? onSkip;

  const AccountScreen({
    super.key,
    required this.onContinue,
    this.onSkip,
  });

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _showEmailForm = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      widget.onContinue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: TrueStepColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      widget.onContinue();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueStepColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueStepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: _showEmailForm ? _buildEmailForm() : _buildMainView(),
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Padding(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TrueStepSpacing.xl),

          // Title
          Text(
            'Create Account',
            style: TrueStepTypography.headline,
          ),
          const SizedBox(height: TrueStepSpacing.sm),

          // Subtitle
          Text(
            'Sign up to save your progress and sync across devices',
            style: TrueStepTypography.body.copyWith(
              color: TrueStepColors.textSecondary,
            ),
          ),
          const SizedBox(height: TrueStepSpacing.xl),

          // Social buttons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Apple Sign-In
                  _SocialButton(
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    onPressed: _showComingSoon,
                  ),
                  const SizedBox(height: TrueStepSpacing.md),

                  // Google Sign-In
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    onPressed: _showComingSoon,
                  ),
                  const SizedBox(height: TrueStepSpacing.lg),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: TrueStepColors.glassBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TrueStepSpacing.md,
                        ),
                        child: Text(
                          'or',
                          style: TrueStepTypography.caption.copyWith(
                            color: TrueStepColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: TrueStepColors.glassBorder)),
                    ],
                  ),
                  const SizedBox(height: TrueStepSpacing.lg),

                  // Email Sign-In
                  _SocialButton(
                    icon: Icons.email_outlined,
                    label: 'Continue with Email',
                    onPressed: () => setState(() => _showEmailForm = true),
                  ),
                ],
              ),
            ),
          ),

          // Guest button
          PrimaryButton(
            label: 'Continue as Guest',
            onPressed: _isLoading ? null : _signInAnonymously,
            isLoading: _isLoading,
            variant: ButtonVariant.ghost,
          ),
          const SizedBox(height: TrueStepSpacing.lg),

          // Terms and Privacy Policy footer
          const _LegalFooter(),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Padding(
      padding: const EdgeInsets.all(TrueStepSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: TrueStepColors.textPrimary,
            onPressed: () => setState(() => _showEmailForm = false),
          ),
          const SizedBox(height: TrueStepSpacing.md),

          // Title
          Text(
            'Sign up with Email',
            style: TrueStepTypography.headline,
          ),
          const SizedBox(height: TrueStepSpacing.xl),

          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field
                    Text(
                      'Email',
                      style: TrueStepTypography.bodyLarge,
                    ),
                    const SizedBox(height: TrueStepSpacing.sm),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: _validateEmail,
                      style: TrueStepTypography.body,
                      decoration: _inputDecoration('Enter your email'),
                    ),
                    const SizedBox(height: TrueStepSpacing.lg),

                    // Password field
                    Text(
                      'Password',
                      style: TrueStepTypography.bodyLarge,
                    ),
                    const SizedBox(height: TrueStepSpacing.sm),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      style: TrueStepTypography.body,
                      decoration: _inputDecoration('Enter your password'),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: TrueStepSpacing.md),
                      Text(
                        _errorMessage!,
                        style: TrueStepTypography.caption.copyWith(
                          color: TrueStepColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Sign Up button
          PrimaryButton(
            label: 'Sign Up',
            onPressed: _isLoading ? null : _signUpWithEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TrueStepTypography.body.copyWith(
        color: TrueStepColors.textTertiary,
      ),
      filled: true,
      fillColor: TrueStepColors.glassSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        borderSide: BorderSide(color: TrueStepColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        borderSide: BorderSide(color: TrueStepColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        borderSide: BorderSide(color: TrueStepColors.accentBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
        borderSide: BorderSide(color: TrueStepColors.error),
      ),
      contentPadding: const EdgeInsets.all(TrueStepSpacing.md),
    );
  }
}

/// Social sign-in button widget
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: TrueStepSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label, style: TrueStepTypography.buttonLarge),
        style: OutlinedButton.styleFrom(
          foregroundColor: TrueStepColors.textPrimary,
          side: BorderSide(color: TrueStepColors.glassBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TrueStepSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// Legal footer with Terms of Service and Privacy Policy links
class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  // TODO: Replace with actual URLs when available
  static const String _termsUrl = 'https://truestep.ai/terms';
  static const String _privacyUrl = 'https://truestep.ai/privacy';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TrueStepSpacing.md),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TrueStepTypography.caption.copyWith(
              color: TrueStepColors.textTertiary,
            ),
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TrueStepTypography.caption.copyWith(
                  color: TrueStepColors.accentBlue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchUrl(_termsUrl),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TrueStepTypography.caption.copyWith(
                  color: TrueStepColors.accentBlue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchUrl(_privacyUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
