// Automatic FlutterFlow imports
// Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class HalfSizeSwitch extends StatefulWidget {
  const HalfSizeSwitch({
    super.key,
    this.width,
    this.height,
    this.initialValue,
    required this.onChanged,
    this.activeColor,
  });

  final double? width;
  final double? height;
  final bool? initialValue;
  final Future Function(bool newValue)? onChanged;
  final Color? activeColor;

  @override
  State<HalfSizeSwitch> createState() => _HalfSizeSwitchState();
}

class _HalfSizeSwitchState extends State<HalfSizeSwitch> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.initialValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 18,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: _switchValue,
          // Define a cor do fundo quando ativo
          activeThumbColor: widget.activeColor ?? Theme.of(context).primaryColor,
          // Força a bolinha (thumb) a ser sempre branca
          thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
          // Remove a borda padrão que às vezes aparece em certas plataformas
          trackOutlineColor:
              const WidgetStatePropertyAll<Color>(Colors.transparent),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (bool value) async {
            setState(() => _switchValue = value);
            if (widget.onChanged != null) {
              await widget.onChanged!(value);
            }
          },
        ),
      ),
    );
  }
}
