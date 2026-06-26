import 'package:flutter/material.dart';

import '../models/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onRemove;
  final bool small;

  const TagChip({super.key, required this.tag, this.onRemove, this.small = false});

  @override
  Widget build(BuildContext context) {
    final bg = tag.color.withOpacity(0.18);
    final fg = tag.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 7,
            height: small ? 6 : 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          SizedBox(width: small ? 4 : 5),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 12, color: fg.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }
}
