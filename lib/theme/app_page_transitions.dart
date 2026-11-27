import 'package:flutter/material.dart';

import 'app_motion.dart';

/// 渐隐渐显的页面转场：进场只做不透明度淡入，退场同样淡出，不位移、不缩放。
///
/// 为什么不用系统默认的转场：iOS 默认是整页横向推入，安卓是上下淡入+位移，
/// 在"液态玻璃"这种大面积模糊的界面上，位移会带着模糊层一起滑动，观感很乱。
/// 纯淡入淡出时，底下的模糊内容始终是静止的，只换前景，层次最干净。
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 全屏页面进出都用同一条曲线：进场先快后慢，退场先快后慢，避免"拖尾"。
    final fade = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasizedDecelerate,
      reverseCurve: AppMotion.emphasizedAccelerate,
    );
    return FadeTransition(opacity: fade, child: child);
  }
}
