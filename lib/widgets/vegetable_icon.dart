import 'package:flutter/material.dart';
import '../core/constants/vegetable_icons.dart';
import '../core/themes/app_colors.dart';

class VegetableIcon extends StatelessWidget {
  final String vegetableName;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showFallback;

  const VegetableIcon({
    super.key,
    required this.vegetableName,
    this.size = 48,
    this.backgroundColor,
    this.borderColor,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = VegetableIcons.getIconPath(vegetableName);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: borderColor != null 
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: _buildIcon(iconPath),
      ),
    );
  }

  Widget _buildIcon(String iconPath) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (showFallback) {
          return _buildFallbackIcon();
        }
        return Container();
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        _getFallbackIconData(),
        color: AppColors.primary,
        size: size * 0.6,
      ),
    );
  }

  IconData _getFallbackIconData() {
    switch (vegetableName) {
      case 'トマト':
      case 'ナス':
      case 'ピーマン':
        return Icons.circle;
      case 'きゅうり':
      case 'サニーレタス':
      case 'ほうれん草':
      case 'モロヘイヤ':
        return Icons.grass;
      case 'オクラ':
      case '二十日大根':
      case '小カブ':
        return Icons.local_florist;
      case 'バジル':
      case 'しそ':
        return Icons.eco;
      default:
        return Icons.eco;
    }
  }
}

/// 野菜選択カード用の大きなアイコン
class VegetableSelectionIcon extends StatelessWidget {
  final String vegetableName;
  final bool isSelected;
  final double size;

  const VegetableSelectionIcon({
    super.key,
    required this.vegetableName,
    this.isSelected = false,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return VegetableIcon(
      vegetableName: vegetableName,
      size: size,
      backgroundColor: isSelected 
          ? AppColors.primary.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1),
      borderColor: isSelected ? AppColors.primary : null,
    );
  }
}

/// リスト表示用の小さなアイコン
class VegetableListIcon extends StatelessWidget {
  final String vegetableName;
  final double size;

  const VegetableListIcon({
    super.key,
    required this.vegetableName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return VegetableIcon(
      vegetableName: vegetableName,
      size: size,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }
}