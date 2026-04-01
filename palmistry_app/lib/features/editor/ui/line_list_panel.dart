import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../bloc/editor_bloc.dart';
import 'line_painter.dart';

String _lineLabel(LineType type) {
  return switch (type) {
    LineType.heart => 'Сердца',
    LineType.head => 'Головы',
    LineType.life => 'Жизни',
    LineType.fate => 'Судьбы',
  };
}

String _lineEmoji(LineType type) {
  return switch (type) {
    LineType.heart => '❤',
    LineType.head => '🧠',
    LineType.life => '🌿',
    LineType.fate => '⭐',
  };
}

/// Horizontal chip list showing detected lines with delete buttons,
/// plus an "Add" button.
class LineListPanel extends StatelessWidget {
  final List<EditableLine> lines;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onDelete;
  final VoidCallback onAdd;

  const LineListPanel({
    super.key,
    required this.lines,
    required this.selectedIndex,
    required this.onSelect,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final line = lines[i];
                final selected = i == selectedIndex;
                final color = lineColor(line.type);

                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withAlpha(40)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? color : Colors.white24,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${_lineEmoji(line.type)} ${_lineLabel(line.type)}',
                          style: TextStyle(
                            color: selected ? color : Colors.white70,
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onDelete(i),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF7C3AED)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF7C3AED), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Добавить',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for picking a line type to add.
class AddLineSheet extends StatelessWidget {
  final ValueChanged<LineType> onSelect;

  const AddLineSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавить линию',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: LineType.values.map((type) {
              final color = lineColor(type);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelect(type);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    '${_lineEmoji(type)} Линия ${_lineLabel(type)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
