import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style Input Field với 3D card effect
class DuoInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Color? iconColor;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const DuoInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.iconColor,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onTap,
  });

  @override
  State<DuoInput> createState() => _DuoInputState();
}

class _DuoInputState extends State<DuoInput> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.errorText != null) return AppColors.red;
    if (_isFocused) return widget.iconColor ?? AppColors.primary;
    return AppColors.border;
  }

  Color get _iconBgColor {
    final color = widget.iconColor ?? AppColors.primary;
    return AppColors.withAlpha(color, 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: AppStyles.durationFast,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.roundedXl,
            border: Border.all(
              color: _borderColor,
              width: _isFocused ? AppStyles.border3 : AppStyles.border2,
            ),
            boxShadow: AppColors.cardBoxShadow(
              color: _isFocused ? _borderColor : null,
              offset: _isFocused ? 2 : AppStyles.shadowMd,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword && !widget.isPasswordVisible,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            style: TextStyle(
              fontSize: AppStyles.textBase,
              fontWeight: AppStyles.fontSemibold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: TextStyle(
                color: widget.iconColor ?? AppColors.primary,
                fontWeight: AppStyles.fontSemibold,
              ),
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: AppStyles.fontNormal,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                      margin: EdgeInsets.all(AppStyles.space3),
                      padding: EdgeInsets.all(AppStyles.space2),
                      decoration: BoxDecoration(
                        color: _iconBgColor,
                        borderRadius: AppStyles.roundedLg,
                      ),
                      child: Icon(
                        widget.prefixIcon,
                        color: widget.iconColor ?? AppColors.primary,
                        size: AppStyles.iconSm,
                      ),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        widget.isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: widget.onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppStyles.space4,
                vertical: AppStyles.space4,
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: AppStyles.space2),
          Padding(
            padding: EdgeInsets.only(left: AppStyles.space3),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.red,
                fontSize: AppStyles.textSm,
                fontWeight: AppStyles.fontMedium,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

