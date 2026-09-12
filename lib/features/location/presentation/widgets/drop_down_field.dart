import 'package:flutter/material.dart';

/// A label, a closed box showing the current answer, and a list that opens
/// under it.
///
/// Generic over the item type so the value that comes back is the row itself,
/// not its name: two cities in different governorates may be called the same
/// thing, and a name cannot be looked up.
class DropdownField<T> extends StatelessWidget {
  final String title;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final T? value;
  final bool isOpen;
  final bool isLoading;

  /// Shown in place of the list when [items] is empty and nothing is loading.
  final String emptyText;

  /// Null disables the field -- a city cannot be picked before a governorate.
  final VoidCallback? onToggle;
  final void Function(T) onSelect;

  const DropdownField({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.value,
    required this.isOpen,
    required this.onToggle,
    required this.onSelect,
    this.isLoading = false,
    this.emptyText = '',
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value != null;
    final isEnabled = onToggle != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),

        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.grey.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSelected ? labelOf(value as T) : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isEnabled ? Colors.black : Colors.grey,
                  ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isOpen
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  // Tall enough for a few rows, short enough that the field it
                  // belongs to stays on screen above it.
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            child: Text(
                              emptyText,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isCurrent = item == value;

                              return InkWell(
                                onTap: () => onSelect(item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(labelOf(item))),
                                      if (isCurrent)
                                        const Icon(Icons.check, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
