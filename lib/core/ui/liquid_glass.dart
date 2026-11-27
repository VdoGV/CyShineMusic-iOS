import 'dart:ui';

import 'package:flutter/material.dart';

/// 「液态玻璃」表面：背景实时模糊 + 半透明染色 + 高光渐变 + 发丝描边。
///
/// 刻意做成一个可复用的壳，而不是把模糊写进各处装饰 —— 只有真正需要
/// 悬浮在内容之上的层（底部胶囊、播放条、浮层）才应该用，列表卡片一律
/// 不用：每一块都开 BackdropFilter 会把滚动帧率吃掉。
///
/// 视觉参数说明：
/// - 模糊半径 22~26 之间最像玻璃；低于 16 会变成"半透明磨砂"，高于 34
///   在浅色背景上几乎看不出内容，反而像纯色块。
/// - 染色走「白色高光 + 主题表面色」两段渐变，比单色更像有厚度的材质。
/// - 描边用 1px 白色半透明，是玻璃"边缘反光"的来源，去掉就会发扁。
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.scheme,
    required this.child,
    this.borderRadius,
    this.blurSigma = 24,
    this.tint,
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
    this.shadowOpacity,
  });

  final ColorScheme scheme;
  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;

  /// 玻璃的底色。默认取主题表面色，需要更"实"一点时传更不透明的颜色。
  final Color? tint;
  final EdgeInsets? padding;
  final bool showBorder;
  final bool showShadow;
  final double? shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(22);
    final isDark = scheme.brightness == Brightness.dark;
    final base = tint ?? scheme.surface.withValues(alpha: isDark ? 0.34 : 0.62);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(
                    alpha: shadowOpacity ?? (isDark ? 0.30 : 0.14),
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          // mirror 让模糊在边缘也连续，避免圆角处出现一圈"没糊到"的亮边。
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
            tileMode: TileMode.mirror,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // 左上角高光：玻璃的"受光面"。
                  Colors.white.withValues(alpha: isDark ? 0.18 : 0.58),
                  base,
                  // 右下角略微压暗，做出厚度。
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: isDark ? 0.10 : 0.04),
                    base,
                  ),
                ],
                stops: const [0, 0.52, 1],
              ),
              border: showBorder
                  ? Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.55),
                    )
                  : null,
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 未开模糊时的兜底底色（低端机 / 某些被裁剪的浮层）。
Color liquidGlassFallbackColor(ColorScheme scheme) => Color.alphaBlend(
  scheme.primary.withValues(
    alpha: scheme.brightness == Brightness.dark ? 0.06 : 0.03,
  ),
  scheme.surfaceContainerHigh.withValues(
    alpha: scheme.brightness == Brightness.dark ? 0.72 : 0.82,
  ),
);
