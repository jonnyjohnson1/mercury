import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatefulWidget {
  final Function(String) onSubmit;

  const PhoneInputField({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isIconVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatPhoneNumber);
  }

  void _formatPhoneNumber() {
    String text =
        _controller.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    String formattedText = '';

    if (text.length >= 1) {
      formattedText = '(${text.substring(0, text.length.clamp(0, 3))}';
    }
    if (text.length > 3) {
      formattedText += ') ${text.substring(3, text.length.clamp(3, 6))}';
    }
    if (text.length > 6) {
      formattedText += '-${text.substring(6, text.length.clamp(6, 10))}';
    }

    // Update the text field with the formatted text
    _controller.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );

    // Show or hide the icon based on input length
    _isIconVisible.value = text.length >= 10;
  }

  void _handleIconTap() {
    if (_controller.text.length >= 10) {
      widget.onSubmit(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isIconVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 43, 43, 43),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        // alignment: Alignment.centerRight,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Phone Number',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
              onSubmitted: (value) => _handleIconTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(3.0, 4, 1, 4),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isIconVisible,
              builder: (context, isVisible, child) {
                return isVisible
                    ? InkWell(
                        onTap: _handleIconTap,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
