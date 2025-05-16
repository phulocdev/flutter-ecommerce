import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  final String description;
  final int maxLines;
  final String expandButtonText;

  const ExpandableDescription({
    Key? key,
    required this.description,
    this.maxLines = 3,
    this.expandButtonText = 'Xem thêm',
  }) : super(key: key);

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Thu gọn' : widget.expandButtonText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
