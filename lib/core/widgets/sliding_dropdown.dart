import 'package:flutter/material.dart';

/// A dropdown whose options expand below the field while keeping the field
/// visible. The expanded options participate in layout and push following
/// content down instead of covering it.
class SlidingDropdown<T> extends StatefulWidget {
  const SlidingDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.decoration,
    this.value,
    this.hint,
    this.style,
    this.iconColor,
    this.menuMaxHeight = 240,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final T? value;
  final Widget? hint;
  final TextStyle? style;
  final Color? iconColor;
  final double menuMaxHeight;

  @override
  State<SlidingDropdown<T>> createState() => _SlidingDropdownState<T>();
}

class _SlidingDropdownState<T> extends State<SlidingDropdown<T>> {
  final Object _tapRegionGroup = Object();
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant SlidingDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged == null && _expanded) _expanded = false;
  }

  DropdownMenuItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  void _toggle() {
    if (widget.onChanged == null || widget.items.isEmpty) return;
    setState(() => _expanded = !_expanded);
  }

  void _select(T? value) {
    setState(() => _expanded = false);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onChanged != null && widget.items.isNotEmpty;
    final selectedItem = _selectedItem;
    final fieldContents = selectedItem?.child ?? widget.hint;

    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) {
        if (_expanded) setState(() => _expanded = false);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? _toggle : null,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                isEmpty: selectedItem == null,
                isFocused: _expanded,
                decoration: widget.decoration.copyWith(enabled: enabled),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: widget.style ?? theme.textTheme.titleMedium!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: fieldContents ?? const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.iconColor ?? theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.menuMaxHeight,
                      ),
                      child: Material(
                        color: Colors.white,
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            return SizedBox(
                              height: kMinInteractiveDimension,
                              child: InkWell(
                                onTap: item.enabled
                                    ? () => _select(item.value)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Align(
                                    alignment: item.alignment,
                                    child: item.child,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
