import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A Voi-inspired confirmation dialog with NO/YES button pair
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? highlightText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.highlightText,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'YES',
    this.cancelText = 'NO',
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? highlightText,
    String confirmText = 'YES',
    String cancelText = 'NO',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        highlightText: highlightText,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.textMain,
                    ),
              ),
              GestureDetector(
                onTap: onCancel ?? () => Navigator.of(context).pop(false),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSub,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSub,
                ),
          ),
          // Highlight text (e.g., phone number)
          if (highlightText != null) ...[
            const SizedBox(height: 4),
            Text(
              highlightText!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
          const SizedBox(height: 32),
          // Button row
          Row(
            children: [
              // NO button (outline)
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
              ),
              const SizedBox(width: 16),
              // YES button (filled dark)
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
