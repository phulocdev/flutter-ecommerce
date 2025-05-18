// Add this class to your file
import 'package:flutter/material.dart';

class StickyContainer extends StatefulWidget {
  final Widget child;

  const StickyContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<StickyContainer> createState() => _StickyContainerState();
}

class _StickyContainerState extends State<StickyContainer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) =>
          true, // Prevents scroll notifications from propagating
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
