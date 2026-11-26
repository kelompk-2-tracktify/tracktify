import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Cincin progress dengan persen di tengah. value: 0.0 sampai 1.0
class ProgressRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;

  const ProgressRing({
    super.key,
    required this.value,
    this.color = AppColors.navy,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFEAF0F5),
              color: color,
            ),
          ),
          Text(
            '${(v * 100).round()}%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}