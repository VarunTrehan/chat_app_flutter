import 'package:chat_app_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isOutlined;
  final double borderRadius;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
    this.borderRadius = AppConstants.borderRadiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: isOutlined ? _buildOutlinedButton() : _buildFilledButton(),
    );
  }

  Widget _buildFilledButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(borderRadius),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingSmall,
          horizontal: AppConstants.paddingMedium,
        ),
      ),
      child: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor ?? AppConstants.primaryColor,
        side: BorderSide(
          color: backgroundColor ?? AppConstants.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(borderRadius),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingSmall,
          horizontal: AppConstants.paddingMedium,
        ),
      ),
      child: isLoading
          ? _buildLoadingIndicator(isOutlined: true)
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildLoadingIndicator({bool isOutlined = false}) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined
              ? (backgroundColor ?? AppConstants.primaryColor)
              : (textColor ?? Colors.white),
        ),
      ),
    );
  }
}

class CusomSmallButtom extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? icon;
  const CusomSmallButtom({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final IconData? icon;
  final bool underline;
  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.icon,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor ?? AppConstants.primaryColor),
            SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor ?? AppConstants.primaryColor,
              fontWeight: FontWeight.w600,
              decoration: underline ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}
