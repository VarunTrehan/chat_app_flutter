import 'package:chat_app_flutter/core/localization/app_localizations.dart';
import 'package:chat_app_flutter/core/theme/app_theme.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxlines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final String? errorText;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxlines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatter,
    this.focusNode,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObsecureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObsecureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.isPassword ? 1 : widget.maxlines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatter,
          focusNode: widget.focusNode,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(color: AppColors.accent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(color: AppColors.accent, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
            counterText: widget.maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        onPressed: () {
          setState(() {
            _isObsecureText = !_isObsecureText;
          });
        },
        icon: Icon(
          _isObsecureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconPressed,
        icon: Icon(
          widget.suffixIcon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    return null;
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  if (onClear != null) onClear!();
                  if (onChanged != null) onChanged!('');
                },
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,

        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
    );
  }
}

class TextFieldValidators {
  static String? email(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.tr('email_required');
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.tr('password_required');
    }
    if (value.length < AppConstants.minPasswordLength) {
      return context
          .tr('password_short')
          .replaceFirst('{min}', AppConstants.minPasswordLength.toString());
    }
    return null;
  }

  static String? required(
    BuildContext context,
    String? value, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      final field = fieldName ?? context.tr('this_field');
      return context.tr('field_required').replaceFirst('{field}', field);
    }
    return null;
  }

  static String? name(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('name_required');
    }
    if (value.trim().length < 2) {
      return context.tr('name_min_length');
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return context.tr(
        'name_max_length',
      ).replaceFirst('{max}', AppConstants.maxNameLength.toString());
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return context.tr('confirm_password_required');
    }
    if (value != password) {
      return context.tr('passwords_do_not_match');
    }
    return null;
  }
}
