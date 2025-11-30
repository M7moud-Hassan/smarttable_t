import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomExpansionWidget extends StatefulWidget {
  const CustomExpansionWidget({
    super.key,
    required this.titleWidget,
    required this.contentWidget,
  });

  final Widget titleWidget;
  final List<Widget> contentWidget;

  @override
  State<CustomExpansionWidget> createState() => _CustomExpansionWidgetState();
}

class _CustomExpansionWidgetState extends State<CustomExpansionWidget>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      splashColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: expanded ? AppColors.yellowColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: widget.titleWidget),
                Container(
                  decoration: BoxDecoration(
                    color: expanded
                        ? AppColors.primaryColor
                        : AppColors.grayBordredColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    color: expanded ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Use AnimatedSize to animate the height change of content widgets
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.contentWidget,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
