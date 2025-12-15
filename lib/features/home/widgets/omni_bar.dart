import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';

/// Prominent glass pill input bar for the home screen
///
/// Accepts URL, text description, or voice input.
/// Features:
/// - Collapsed state: Shows placeholder text, tap to expand
/// - Expanded state: Shows TextField for input with submit/close buttons
/// - Voice input via microphone button
class OmniBar extends StatefulWidget {
  /// Callback when the bar is tapped (in collapsed state)
  final VoidCallback? onTap;

  /// Callback when the microphone icon is tapped
  final VoidCallback? onMicTap;

  /// Callback when text is submitted (URL or task description)
  final void Function(String)? onSubmit;

  const OmniBar({
    super.key,
    this.onTap,
    this.onMicTap,
    this.onSubmit,
  });

  @override
  State<OmniBar> createState() => _OmniBarState();
}

class _OmniBarState extends State<OmniBar> {
  bool _isExpanded = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
    });
    // Request focus after state update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
      _textController.clear();
    });
    _focusNode.unfocus();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit?.call(text);
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: TrueStepSpacing.animationState),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: TrueStepSpacing.md,
        vertical: TrueStepSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: TrueStepColors.glassSurface,
        borderRadius: BorderRadius.circular(TrueStepSpacing.radiusXl),
        border: Border.all(
          color: _isExpanded
              ? TrueStepColors.accentBlue.withValues(alpha: 0.5)
              : TrueStepColors.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: TrueStepColors.accentBlue.withValues(alpha: _isExpanded ? 0.2 : 0.1),
            blurRadius: _isExpanded ? 24 : 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
    );
  }

  Widget _buildCollapsedContent() {
    return GestureDetector(
      onTap: _expand,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Search icon
          const Icon(
            Icons.search,
            color: TrueStepColors.textTertiary,
            size: 24,
          ),
          const SizedBox(width: TrueStepSpacing.sm),

          // Placeholder text
          Expanded(
            child: Text(
              "Paste URL, describe task, or say 'Hey TrueStep'...",
              style: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: TrueStepSpacing.sm),

          // Microphone button
          GestureDetector(
            onTap: widget.onMicTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mic,
                color: TrueStepColors.accentBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Row(
      children: [
        // Close button
        GestureDetector(
          onTap: _collapse,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TrueStepColors.bgSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.close,
              color: TrueStepColors.textSecondary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: TrueStepSpacing.sm),

        // Text input
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            style: TrueStepTypography.body.copyWith(
              color: TrueStepColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter URL or describe your task...',
              hintStyle: TrueStepTypography.body.copyWith(
                color: TrueStepColors.textTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: TrueStepSpacing.sm),

        // Microphone button
        GestureDetector(
          onTap: widget.onMicTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TrueStepColors.accentBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.mic,
              color: TrueStepColors.accentBlue,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: TrueStepSpacing.xs),

        // Submit button
        GestureDetector(
          onTap: _submit,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TrueStepColors.accentBlue,
                  TrueStepColors.accentPurple,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: TrueStepColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
