import 'package:flutter/material.dart';

class TextSelectionMenu extends StatelessWidget {
  final String selectedText;
  final VoidCallback onDictionary;
  final Function(Color) onHighlight;
  final VoidCallback onUnderline;
  final VoidCallback onStrikethrough;
  final VoidCallback onSquiggly;
  final VoidCallback onCopy;

  const TextSelectionMenu({
    super.key,
    required this.selectedText,
    required this.onDictionary,
    required this.onHighlight,
    required this.onUnderline,
    required this.onStrikethrough,
    required this.onSquiggly,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Row: Dictionary and Copy
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.book,
                label: 'Dictionary',
                onTap: onDictionary,
              ),
              _buildMenuItem(
                context,
                icon: Icons.copy,
                label: 'Copy',
                onTap: onCopy,
              ),
            ],
          ),
          const Divider(height: 1),
          // Second Row: Highlight Colors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorOption(Colors.yellow, () => onHighlight(Colors.yellow)),
                _buildColorOption(Colors.green, () => onHighlight(Colors.green)),
                _buildColorOption(Colors.blue, () => onHighlight(Colors.blue)),
                _buildColorOption(Colors.pink, () => onHighlight(Colors.pink)),
                _buildColorOption(Colors.orange, () => onHighlight(Colors.orange)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Third Row: Text Decorations
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.format_underlined,
                label: 'Underline',
                onTap: onUnderline,
              ),
              _buildMenuItem(
                context,
                icon: Icons.strikethrough_s,
                label: 'Strike',
                onTap: onStrikethrough,
              ),
              _buildMenuItem(
                context,
                icon: Icons.gesture,
                label: 'Squiggly',
                onTap: onSquiggly,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}