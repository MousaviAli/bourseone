import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Lightweight shimmer/skeleton effect built with plain Flutter animation
/// APIs (no external package - avoids repeating the dependency-conflict
/// problems earlier packages like speech_to_text caused in CI builds).
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.cardElevated;
    final highlightColor = AppColors.isDark ? AppColors.divider : AppColors.card;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, 0),
              end: Alignment(0 + _controller.value * 3, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// A ready-made skeleton matching StockListTile's layout - swap in while
/// a list is loading instead of a bare spinner.
class StockListTileSkeleton extends StatelessWidget {
  const StockListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 70, height: 12, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 6),
                ShimmerBox(width: 120, height: 10, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 50, height: 12, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 6),
              ShimmerBox(width: 40, height: 16, borderRadius: BorderRadius.circular(8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A short vertical list of skeleton rows - drop in wherever a list is
/// still loading.
class ListSkeleton extends StatelessWidget {
  final int count;
  const ListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const StockListTileSkeleton()),
    );
  }
}
