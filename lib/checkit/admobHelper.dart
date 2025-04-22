import 'dart:io';

class AdHelper {
  static String get getInterstatitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2282149611905342/4286974188';
    } else {
      throw UnsupportedError('Unsupported Platfor');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2282149611905342/7158757522';
    } else {
      throw UnsupportedError('Unsupported Platfor');
    }
  }
}
