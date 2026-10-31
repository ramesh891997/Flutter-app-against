import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Reusable styled text field with integrated password visibility toggle and validation.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.labelText,
    super.key,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.autovalidateMode,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget? suffixIcon;
    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        tooltip: _obscureText ? l10n.showPassword : l10n.hidePassword,
        onPressed: _toggleObscure,
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
