import 'package:flutter/material.dart';

class CategoryBox extends StatelessWidget {
  final String label;
  final double screenWidth;

  const CategoryBox({super.key, required this.label, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    double boxSize = (screenWidth - 70) / 3;
    return Column(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: Colors.orange[400],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}