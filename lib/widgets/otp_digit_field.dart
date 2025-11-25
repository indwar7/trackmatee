import 'package:flutter/material.dart';

class OTPDigitField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const OTPDigitField({super.key, required this.controller, required this.focusNode, required this.hasError, this.onChanged});

  @override
  State<OTPDigitField> createState() => _OTPDigitFieldState();
}

class _OTPDigitFieldState extends State<OTPDigitField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() { setState(() { _focused = widget.focusNode.hasFocus; }); });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError ? Colors.redAccent : (_focused ? const Color(0xFF8B5CF6) : Colors.grey.shade700);
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: const Color(0xFF141418),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2.4)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2.8)),
      ),
      onChanged: (v) {
        if (v.length > 1) {
          widget.controller.text = v.substring(v.length - 1);
        }
        if (widget.onChanged != null) widget.onChanged!(v);
      },
    );
  }
}
