import 'package:flutter/material.dart';

class OverlayWidget extends StatelessWidget {

  const OverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 0.7,
      child: ModalBarrier(dismissible: true, color: Colors.black),
    );
  }
}
