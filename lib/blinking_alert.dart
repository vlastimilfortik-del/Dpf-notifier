import 'package:flutter/material.dart';

class BlinkingAlert extends StatefulWidget {
  final bool active;
  const BlinkingAlert({Key? key, required this.active}) : super(key: key);

  @override
  State<BlinkingAlert> createState() => _BlinkingAlertState();
}

class _BlinkingAlertState extends State<BlinkingAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _controller,
      child: Center(
        child: Text(
          '⚠️ POZOR: REGENERACE DPF ⚠️',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
