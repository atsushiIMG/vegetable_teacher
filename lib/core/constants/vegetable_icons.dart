/// 野菜アイコンの画像パス定数
class VegetableIcons {
  VegetableIcons._();

  static const String _basePath = 'assets/images/vegetables/';

  // 12種類の野菜アイコンパス
  // TODO 作成した野菜アイコンを追加する
  static const String tomato = '${_basePath}tomato.png';
  static const String cucumber = '${_basePath}cucumber.png';
  static const String eggplant = '${_basePath}eggplant.png';
  static const String okra = '${_basePath}okra.png';
  static const String basil = '${_basePath}basil.png';
  static const String sunnyLettuce = '${_basePath}sunny_lettuce.png';
  static const String radish = '${_basePath}radish.png';
  static const String spinach = '${_basePath}spinach.png';
  static const String turnip = '${_basePath}turnip.png';
  static const String bellPepper = '${_basePath}bell_pepper.png';
  static const String shiso = '${_basePath}shiso.png';
  static const String moroheiya = '${_basePath}moroheiya.png';

  // デフォルトアイコン
  static const String defaultVegetable = '${_basePath}default_vegetable.png';

  /// 野菜名から画像パスを取得
  static String getIconPath(String vegetableName) {
    return availableIcons[vegetableName] ?? defaultVegetable;
  }

  /// 利用可能な野菜アイコンのリスト
  static const Map<String, String> availableIcons = {
    'トマト': tomato,
    'きゅうり': cucumber,
    'ナス': eggplant,
    'オクラ': okra,
    'バジル': basil,
    'サニーレタス': sunnyLettuce,
    '二十日大根': radish,
    'ほうれん草': spinach,
    '小カブ': turnip,
    'ピーマン': bellPepper,
    'しそ': shiso,
    'モロヘイヤ': moroheiya,
  };
}
