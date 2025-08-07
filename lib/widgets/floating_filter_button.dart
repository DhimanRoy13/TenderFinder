// lib/widgets/floating_filter_button.dart
import 'package:flutter/material.dart';

class FloatingFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPositioned;

  const FloatingFilterButton({
    super.key,
    required this.onPressed,
    this.isPositioned = true,
  });

  Widget _buildButton() {
    return SizedBox(
      height: 48,
      width: 100,
      child: FloatingActionButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF222222),
        foregroundColor: Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.filter_list, size: 22, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Filter',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPositioned) {
      return Positioned(right: 16, bottom: 16, child: _buildButton());
    }
    return _buildButton();
  }
}
