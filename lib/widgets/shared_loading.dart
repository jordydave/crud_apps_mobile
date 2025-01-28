import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SharedLoading extends StatelessWidget {
  const SharedLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: SizedBox(
          width: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulse,
            colors: [Colors.white],
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
