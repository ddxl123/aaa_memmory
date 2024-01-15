import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

String formatNumber(int number) {
  if (number >= 1000) {
    double result = number / 1000;
    return "${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}k";
  } else {
    return number.toString();
  }
}

class CustomTooltip extends StatefulWidget {
  const CustomTooltip({super.key, required this.texts});

  final List<CustomTooltipText> texts;

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  final justTheController = JustTheController();

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      controller: justTheController,
      backgroundColor: Colors.grey.shade800,
      content: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [...widget.texts],
        ),
      ),
      child: GestureDetector(
        child: Icon(Icons.error, color: Colors.blue, size: 18),
        onTap: () {
          justTheController.showTooltip();
        },
      ),
    );
  }
}

class CustomTooltipText extends StatelessWidget {
  const CustomTooltipText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Colors.white));
}
