import 'dart:async';

import 'package:flutter/material.dart';

class ScrollManager {
  final ScrollController controller;
  final VoidCallback onScrollToBottom;
  final ValueChanged<bool> onScrollButtonVisibilityChanged;

  Timer? _debounce;

  ScrollManager({
    required this.controller,
    required this.onScrollToBottom,
    required this.onScrollButtonVisibilityChanged,
  });

  void initialize() {
    controller.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 300),
      _updateScrollButtonVisibility,
    );

    if (_isScrollAtBottom()) {
      debugPrint('Scroll End');
      onScrollToBottom();
    }
  }

  void _updateScrollButtonVisibility() {
    final double offset = controller.offset;
    final bool shouldShow = offset >= 60.0;
    onScrollButtonVisibilityChanged(shouldShow);
  }

  bool _isScrollAtBottom() {
    return controller.position.pixels >= controller.position.maxScrollExtent;
  }

  void scrollToTop() {
    controller.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  void dispose() {
    _debounce?.cancel();
    controller.removeListener(_handleScroll);
  }
}
