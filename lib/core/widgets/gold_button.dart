import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
      ),
    ),
    child: FilledButton.icon(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(50),
      ),
      icon: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : Icon(icon ?? Icons.arrow_forward),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
