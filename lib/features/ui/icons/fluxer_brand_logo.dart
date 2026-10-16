import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxer_app/core/constants/assets.dart';
import 'package:fluxer_app/core/theme/color_utils.dart';

class FluxerBrandLogo extends StatelessWidget {
  const FluxerBrandLogo({
    required this.size,
    this.backgroundColor,
    this.symbolColor,
    super.key,
  });

  final double size;
  final Color? backgroundColor;
  final Color? symbolColor;

  @override
  Widget build(BuildContext context) {
    // pirichat: by default the logo itself, white and red on its dark tile.
    final Color fill = backgroundColor ?? const Color(0xFF0A0A10);
    final Color? mark = symbolColor ??
        (backgroundColor == null
            ? null
            : ColorUtils.bestContrastColor(fill.toARGB32()));
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
            ),
            SvgPicture.asset(
              Assets.fluxerSymbol,
              width: size,
              height: size,
              colorFilter: mark == null
                  ? null
                  : ColorFilter.mode(mark, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
