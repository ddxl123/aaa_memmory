import 'package:flutter/material.dart';
import 'package:tools/src/other.dart';

/// 需要配套使用 [FloatingRoundCornerButtonLocation]
///
/// 若需要占位框，则可以使用 [floatingRoundCornerButtonPlaceholderBox]。
class CustomRoundCornerButton extends StatelessWidget {
  const CustomRoundCornerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.border,
    this.color = Colors.tealAccent,
    this.isElevated = true,
    this.isMinVisualDensity = false,
  });

  final Widget text;
  final void Function() onPressed;
  final OutlinedBorder? border;
  final Color color;
  final bool isElevated;
  final bool isMinVisualDensity;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        visualDensity: isMinVisualDensity ? kMinVisualDensity : null,
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
        elevation: isElevated == true ? MaterialStateProperty.all(5) : null,
        shape: MaterialStateProperty.all(border),
      ),
      child: text,
      onPressed: () {
        onPressed();
      },
    );
  }
}

class FloatingRoundCornerButtonLocation extends FloatingActionButtonLocation {
  FloatingRoundCornerButtonLocation({
    required this.context,
    this.offset = Offset.zero,
  });

  final BuildContext context;
  final Offset offset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final centerDockedOffset = FloatingActionButtonLocation.centerDocked.getOffset(scaffoldGeometry);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    if (bottom > 0) return centerDockedOffset;
    return centerDockedOffset + offset;
  }
}

Widget floatingRoundCornerButtonPlaceholderBox([double height = 100]) => SizedBox(height: height);
