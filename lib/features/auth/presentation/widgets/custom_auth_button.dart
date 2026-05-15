import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.child,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : child,
      ),
    );
  }
}

class AuthSecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AuthSecondaryButton({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
