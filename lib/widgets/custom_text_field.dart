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
              color: AppConstants.textPrimaryColor,
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
          style: TextStyle(fontSize: 16, color: AppConstants.textPrimaryColor),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppConstants.textSecondaryColor.withOpacity(0.6),
              fontSize: 16,
            ),
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 22,
                    color: AppConstants.textSecondaryColor,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: Colors.grey.shade100,
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
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(color: AppConstants.accentColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: BorderSide(color: AppConstants.accentColor, width: 2),
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
          color: AppConstants.textSecondaryColor,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconPressed,
        icon: Icon(widget.suffixIcon, color: AppConstants.textSecondaryColor),
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
      style: TextStyle(fontSize: 16, color: AppConstants.textPrimaryColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppConstants.textSecondaryColor.withOpacity(0.6),
        ),
        prefixIcon: Icon(Icons.search, color: AppConstants.textSecondaryColor),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  if (onClear != null) onClear!();
                  if (onChanged != null) onChanged!('');
                },
                icon: Icon(Icons.clear, color: AppConstants.textSecondaryColor),
              )
            : null,

        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
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
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordShortMessage;
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return "Name must be atleast 2 characters";
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return "Name must be less than ${AppConstants.maxNameLength} characters";
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Password do not match';
    }
    return null;
  }
}
