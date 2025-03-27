import 'package:flutter/material.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';
import 'package:mobile_app/app/res/image/app_images.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/ui/widget/touchable_widget.dart';

class CommonTextField extends StatefulWidget {
  final double? fontSize; // cỡ chữ
  final Color? color; // màu chữ
  final String? errorText; // nội dung lỗi (null: ẩn)
  final double? errorFontSize; // cỡ chữ lỗi
  final Color? errorColor; // màu chữ lỗi
  final Color? focusColor; // màu dòng gạch chân khi focus
  final String? fontFamily; // font chữ
  final bool? hasFloatingPlaceholder; // floating label hay không
  final String? hintText; // nội dung label
  final double? hintTextFontSize; // kích thước label (khi chưa floating)
  final String? hintTextFontFamily; // font chữ label
  final Widget? suffix; // widget sau (mặc định là nút clear)
  final Widget? prefixIcon; // widget trước
  final TextEditingController controller; // controller (bắt buộc phải có)
  final int? maxLength; //
  final bool? showMaxLengthCount; // hiện bộ đếm của maxLength
  final TextInputType? keyboardType; //
  final bool? obscureText; // ân text (vd: mật khẩu)
  final FocusNode? focusNode; //
  final bool? autoFocus; //
  final Function? onChanged; //
  final EdgeInsetsGeometry? contentPadding; //
  final bool? hideUnderBorderLine; // ẩn hiện gạch chân
  final Widget? imageClear; // widget thay cho nút clear mặc định
  final ThemeData? themeData; // dùng để thay đổi Theme (vd: màu chữ label khi floating)
  final Brightness? keyboardAppearance;

  const CommonTextField({
    Key? key,
    this.fontSize,
    this.errorText,
    this.errorFontSize,
    this.fontFamily,
    this.color,
    this.focusColor,
    this.errorColor,
    this.hasFloatingPlaceholder,
    this.hintText,
    this.hintTextFontSize,
    this.hintTextFontFamily,
    this.suffix,
    this.prefixIcon,
    required this.controller,
    this.maxLength,
    this.showMaxLengthCount,
    this.keyboardType,
    this.obscureText,
    this.focusNode,
    this.onChanged,
    this.contentPadding,
    this.hideUnderBorderLine,
    this.imageClear,
    this.themeData,
    this.autoFocus,
    this.keyboardAppearance,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommonTextFieldState();
  }
}

class _CommonTextFieldState extends State<CommonTextField> {
  late FocusNode _internalFocusNode;
  bool _showClearButton = false;

  void _onChanged(String text) {
    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }
    if (text.trim().isEmpty) {
      if (_showClearButton) {
        setState(() {
          _showClearButton = false;
        });
      }
    } else {
      if (!_showClearButton) {
        setState(() {
          _showClearButton = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ??
          ThemeData(
            primaryColor: AppColors.primary,
            hintColor: AppColors.tabUnSelected,
          ),
      child: TextField(
        style: TextStyle(
            fontSize: widget.fontSize ?? 18,
            color: widget.color ?? AppColors.blackText,
            fontFamily: widget.fontFamily ?? AppFonts.robotoRegular),
        decoration: InputDecoration(
            contentPadding: widget.contentPadding,
            floatingLabelBehavior:
                widget.hasFloatingPlaceholder == false ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
            labelText: widget.hasFloatingPlaceholder == false ? null : widget.hintText,
            labelStyle: TextStyle(
                color: _internalFocusNode.hasFocus ? AppColors.primary : AppColors.gray2,
                fontSize: widget.hintTextFontSize ?? 15,
                fontFamily: widget.hintTextFontFamily ?? AppFonts.robotoRegular),
            hintText: widget.hasFloatingPlaceholder == false ? widget.hintText : null,
            hintStyle: TextStyle(
                color: AppColors.primary,
                fontSize: widget.hintTextFontSize ?? 15,
                fontFamily: widget.hintTextFontFamily ?? AppFonts.robotoRegular),
            errorText: widget.errorText,
            errorStyle: TextStyle(fontSize: widget.errorFontSize ?? 14, color: widget.errorColor ?? AppColors.redText),
            suffix: widget.suffix ??
                (_showClearButton
                    ? TouchableWidget(
                        width: 30,
                        height: widget.fontSize == null ? 17 : widget.fontSize! - 1,
                        padding: const EdgeInsets.all(0),
                        child: widget.imageClear ??
                            Image.asset(
                              AppImages.icClearText2,
                              width: 15,
                              height: 15,
                            ),
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 50)).then((_) {
                            widget.controller.clear();
                            _onChanged('');
                          });
                        },
                      )
                    : null),
            prefixIcon: widget.prefixIcon,
            counter: widget.showMaxLengthCount == true
                ? null
                : const SizedBox(
                    height: 0.0,
                  ),
            focusedBorder: widget.hideUnderBorderLine == true
                ? const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.transparent, width: 0.1))
                : UnderlineInputBorder(borderSide: BorderSide(color: widget.focusColor ?? AppColors.primary, width: 2)),
            enabledBorder: widget.hideUnderBorderLine == true
                ? const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.transparent, width: 0.1))
                : const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.tabUnSelected, width: 1))),
        controller: widget.controller,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ?? false,
        focusNode: _internalFocusNode,
        onChanged: _onChanged,
        autofocus: widget.autoFocus ?? false,
        keyboardAppearance: widget.keyboardAppearance ?? Brightness.light,
      ),
    );
  }
}
