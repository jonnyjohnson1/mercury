import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SMSVerificationInputField extends StatefulWidget {
  final Function(String) onSubmit;

  const SMSVerificationInputField({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  _SMSVerificationInputFieldState createState() =>
      _SMSVerificationInputFieldState();
}

class _SMSVerificationInputFieldState extends State<SMSVerificationInputField> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isIconVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatVerificationNumber);
  }

  void _formatVerificationNumber() {
    String text =
        _controller.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digits

    // Show or hide the icon based on input length
    _isIconVisible.value = text.length == 6;
    setState(() {});
  }

  void _handleIconTap() {
    if (_controller.text.length == 6) {
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
        children: [
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 5),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                          color: Colors.white, letterSpacing: 3),
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.transparent, // Hide the cursor
                      showCursor: false, // Disable the cursor
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _controller.text.isEmpty ? 'Enter code' : '',
                        hintStyle:
                            TextStyle(color: Colors.white54, letterSpacing: 1),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                            6), // Limit to 6 digits
                      ],
                      onSubmitted: (value) => _handleIconTap,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      if (_controller.text.isNotEmpty)
                        Text(
                          '-' * (6 - _controller.text.length),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w100,
                            fontSize: 24,
                            letterSpacing: 5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
