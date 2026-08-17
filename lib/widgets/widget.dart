import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Full-width primary action. Pass [loading] to show a spinner and block taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(label),
              ],
            ),
    );
  }
}

/// Full-width outlined action, for the lower-emphasis choice in a pair.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: AppColors.primary, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: AppText.button.copyWith(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Labelled text input matching the kit's rounded, filled field.
class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.hint,
    this.controller,
    this.label,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
  }) : super(key: key);

  final String hint;
  final TextEditingController? controller;
  final String? label;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: AppText.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// White rounded container with soft elevation — the kit's list/detail card.
class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
            boxShadow: kCardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small circular orange badge used beside titles and list rows.
class AccentIcon extends StatelessWidget {
  const AccentIcon(this.icon, {Key? key, this.size = 40}) : super(key: key);

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.primary),
    );
  }
}

/// Screen wrapper: white background, optional back arrow, consistent padding.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.showBack = true,
    this.bottom,
    this.padded = true,
  }) : super(key: key);

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottom;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: (title == null && !canPop && actions == null)
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
              title: title == null ? null : Text(title!),
              actions: actions,
            ),
      body: SafeArea(
        top: false,
        child: padded
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: child,
              )
            : child,
      ),
      bottomNavigationBar: bottom == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                  AppSpacing.screen, AppSpacing.lg),
              child: SafeArea(top: false, child: bottom!),
            ),
    );
  }
}
