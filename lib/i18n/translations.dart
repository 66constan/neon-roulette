/// Multi-language translation keys (ZH / EN / VI / JA).
class I18n {
  final String locale;

  const I18n(this.locale);

  static const List<String> locales = ['zh', 'en', 'vi', 'ja'];

  String nextLocale() {
    final idx = locales.indexOf(locale);
    return locales[(idx + 1) % locales.length];
  }

  // ===========================================================================
  // UI strings
  // ===========================================================================
  String get title {
    switch (locale) {
      case 'en': return 'PartyRoulette';
      case 'vi': return 'PartyRoulette';
      case 'ja': return 'PartyRoulette';
      default:   return 'PartyRoulette';
    }
  }

  String get subtitle {
    switch (locale) {
      case 'en': return 'DRINK & DARE';
      case 'vi': return 'NEON CLIMAX';
      case 'ja': return 'DRINK & DARE';
      default:   return 'TRUTH OR DARE';
    }
  }

  String get startBtn {
    switch (locale) {
      case 'en': return 'START';
      case 'vi': return 'START';
      case 'ja': return 'START';
      default:   return 'START';
    }
  }

  String get spinning {
    switch (locale) {
      case 'en': return 'SPINNING...';
      case 'vi': return 'ĐANG QUAY...';
      case 'ja': return '回転中...';
      default:   return '旋转中...';
    }
  }

  String get rules {
    switch (locale) {
      case 'en': return 'The ultimate party icebreaker and drinking game.';
      case 'vi': return 'Trò chơi phá băng bữa tiệc tối thượng.';
      case 'ja': return 'パーティーのアイスブレイクに最適な飲み会ゲーム。';
      default:   return '聚会破冰、疯狂酒令必备神器。';
    }
  }

  String get settingsTitle {
    switch (locale) {
      case 'en': return 'Console Center';
      case 'vi': return 'Trung Tâm Điều Khiển';
      case 'ja': return 'コントロールセンター';
      default:   return '派对包厢中控后台';
    }
  }

  String get customizePenalties {
    switch (locale) {
      case 'en': return 'Customize Seductions';
      case 'vi': return 'Chỉnh Sửa Nhãn Sân Khấu';
      case 'ja': return '罰ゲームのカスタマイズ';
      default:   return '格项高度微调';
    }
  }

  String get saveBtn {
    switch (locale) {
      case 'en': return 'Save Settings';
      case 'vi': return 'Lưu Cài Đặt';
      case 'ja': return '保存';
      default:   return '加载微调';
    }
  }

  String get resetBtn {
    switch (locale) {
      case 'en': return 'Restore Originals';
      case 'vi': return 'Khôi Phục Gốc';
      case 'ja': return 'リセット';
      default:   return '恢复配置';
    }
  }

  String get langLabel {
    switch (locale) {
      case 'en': return 'Language';
      case 'vi': return 'Ngôn Ngữ';
      case 'ja': return '言語';
      default:   return '语言 / Lang';
    }
  }

  String get soundLabel {
    switch (locale) {
      case 'en': return 'Sound Effects';
      case 'vi': return 'Âm Thanh';
      case 'ja': return 'サウンド';
      default:   return '狂欢声效';
    }
  }

  String get directionLeft {
    switch (locale) {
      case 'en': return 'Left-side';
      case 'vi': return 'Bên trái';
      case 'ja': return '左側';
      default:   return '左边';
    }
  }

  String get directionRight {
    switch (locale) {
      case 'en': return 'Right-side';
      case 'vi': return 'Bên phải';
      case 'ja': return '右側';
      default:   return '右边';
    }
  }

  String get personSuffix {
    switch (locale) {
      case 'en': return 'guest';
      case 'vi': return 'ghế';
      case 'ja': return '番目';
      default:   return '号位';
    }
  }

  String get actionRequired {
    switch (locale) {
      case 'en': return '🔥 EXECUTE IMMEDIATELY 🔥';
      case 'vi': return '🔥 THỰC HIỆN NGAY 🔥';
      case 'ja': return '🔥 今すぐ実行せよ 🔥';
      default:   return '🔥 现场即刻执行 🔥';
    }
  }

  String get noHistory {
    switch (locale) {
      case 'en': return 'No logs yet. Ignite the night!';
      case 'vi': return 'Chưa có lượt vui nào. Hãy thổi bùng đêm nay!';
      case 'ja': return 'まだ記録がありません。夜を燃やそう！';
      default:   return '暂无记录，快来点燃夜场吧！';
    }
  }

  // ===========================================================================
  // Penalty titles & descriptions
  // ===========================================================================
  String penaltyTitle(int index) {
    switch (index) {
      case 0: // All Cheers
        switch (locale) {
          case 'en': return 'ALL CHEERS';
          case 'vi': return 'CẠN LY';
          case 'ja': return 'みんなで乾杯';
          default:   return '全场干杯';
        }
      case 1: // Tease Sip
        switch (locale) {
          case 'en': return 'TEASE SIP';
          case 'vi': return 'UỐNG NHẤP MÔI';
          case 'ja': return '半分飲む';
          default:   return '养鱼半杯';
        }
      case 2: // Bottoms Up
        switch (locale) {
          case 'en': return 'BOTTOMS UP';
          case 'vi': return 'CẠN CHÉN';
          case 'ja': return '一気飲み';
          default:   return '深水炸弹';
        }
      case 3: // Lap Dance
        switch (locale) {
          case 'en': return 'LAP DANCE';
          case 'vi': return 'MÚA ĐÙI';
          case 'ja': return 'ラップダンス';
          default:   return '贴身热舞';
        }
      case 4: // Free Pass
        switch (locale) {
          case 'en': return 'FREE PASS';
          case 'vi': return 'THOÁT HIỂM';
          case 'ja': return 'フリーパス';
          default:   return '免死金牌';
        }
      case 5: // French Kiss
        switch (locale) {
          case 'en': return 'FRENCH KISS';
          case 'vi': return 'HÔN SÂU';
          case 'ja': return 'ディープキス';
          default:   return '法式湿吻';
        }
      case 6: // Dominator
        switch (locale) {
          case 'en': return 'DOMINATOR';
          case 'vi': return 'QUYỀN LỰC';
          case 'ja': return '絶対支配';
          default:   return '绝对支配';
        }
      case 7: // Body Sway
        switch (locale) {
          case 'en': return 'BODY SWAY';
          case 'vi': return 'ĐU ĐƯA';
          case 'ja': return '密着スウェイ';
          default:   return '欲擒故纵';
        }
      default: return '';
    }
  }

  String penaltySubtitle(int index) {
    switch (index) {
      case 0:
        switch (locale) {
          case 'en': return 'Cheers Together';
          case 'vi': return '100% Dzô!';
          case 'ja': return '乾杯！';
          default:   return '全场举杯';
        }
      case 1:
        switch (locale) {
          case 'en': return 'Seductive Sip';
          case 'vi': return 'Hớp Nhấp Gợi Cảm';
          case 'ja': return 'Seductive Sip';
          default:   return '浅尝热身';
        }
      case 2:
        switch (locale) {
          case 'en': return 'Climax Shot';
          case 'vi': return 'Đỉnh Cao Cuồng Nhiệt';
          case 'ja': return 'Climax Shot';
          default:   return '一饮而尽';
        }
      case 3:
        switch (locale) {
          case 'en': return 'Lap Sit';
          case 'vi': return 'Tiếp Xúc Thể Xác';
          case 'ja': return 'Lap Sit';
          default:   return '面对面坐腿上15秒';
        }
      case 4:
        switch (locale) {
          case 'en': return 'Safe! Assign someone';
          case 'vi': return 'Thoát! Chỉ định người khác';
          case 'ja': return 'セーフ！他の人に指名';
          default:   return '免罚！指定一人代罚';
        }
      case 5:
        switch (locale) {
          case 'en': return 'Deep Kiss 5s';
          case 'vi': return 'Hôn Sâu 5 Giây';
          case 'ja': return 'ディープキス5秒';
          default:   return '嘴对嘴5秒';
        }
      case 6:
        switch (locale) {
          case 'en': return 'Golden Pass + Double';
          case 'vi': return 'Vàng Miễn + Gấp Đôi';
          case 'ja': return '完全免除 + 誰か2倍';
          default:   return '免罚 + 指定一人加倍';
        }
      case 7:
        switch (locale) {
          case 'en': return 'Sensual Sway 30s';
          case 'vi': return 'Đu Đưa 30 Giây';
          case 'ja': return '密着スウェイ30秒';
          default:   return '跨坐摇晃30秒';
        }
      default: return '';
    }
  }

  String penaltyDescription(int index) {
    switch (index) {
      case 0:
        switch (locale) {
          case 'en': return 'Everyone stands up, raises glasses, shouts 1-2-3-Dzô!';
          case 'vi': return 'Tất cả đứng lên, nâng ly và hô 1-2-3-Dzô!';
          case 'ja': return '全員起立、グラスを掲げて1-2-3-Dzô！';
          default:   return '全场起立举杯，高喊1-2-3-Dzô一起干杯！';
        }
      case 1:
        switch (locale) {
          case 'en': return 'Take a warm sip to heat up the mood!';
          case 'vi': return 'Uống nhấp mát rượu, làm đệm bầu không khí!';
          case 'ja': return '一口飲んで雰囲気を盛り上げよう！';
          default:   return '浅尝一口，今夜的微醺派对才刚刚揭幕！';
        }
      case 2:
        switch (locale) {
          case 'en': return 'Drain the whole glass in one go!';
          case 'vi': return 'Cạn sạch chén của bạn hoàn toàn!';
          case 'ja': return 'グラスの酒を一気に飲み干せ！';
          default:   return '仰头一饮而尽！全场最炽热的焦点！';
        }
      case 3:
        switch (locale) {
          case 'en': return 'Face away and perform a hot lap dance on the designated player for 15s!';
          case 'vi': return 'Quay lưng lại múa đùi gợi cảm lên người chỉ định 15 giây!';
          case 'ja': return '相手の膝の上で15秒間のセクシーラップダンス！';
          default:   return '背对指定玩家，坐腿上热舞15秒！';
        }
      case 4:
        switch (locale) {
          case 'en': return 'Free pass! You can designate anyone to take the drink for you.';
          case 'vi': return 'Thoát hiểm! Bạn chỉ định người khác uống thay.';
          case 'ja': return 'フリーパス！誰かに代わりに飲んでもらえます。';
          default:   return '金牌免死！可指定任意一人替你代罚饮酒。';
        }
      case 5:
        switch (locale) {
          case 'en': return 'Lip-to-lip deep kiss with the designated companion for 5 seconds!';
          case 'vi': return 'Hôn chạm môi sâu đậm 5 giây với người chỉ định!';
          case 'ja': return '指名した相手と5秒間のディープキス！';
          default:   return '与指定对象嘴对嘴热吻5秒，全场倒数！';
        }
      case 6:
        switch (locale) {
          case 'en': return 'Ultimate immunity! You pass AND force anyone to drink DOUBLE!';
          case 'vi': return 'Miễn trừ + chỉ định một người uống GẤP ĐÔI!';
          case 'ja': return '完全免除＋誰かに2倍の罰を！';
          default:   return '天选宠儿！免罚且指定一人喝加倍！';
        }
      case 7:
        switch (locale) {
          case 'en': return 'Mount their lap, wrap arms around, and sway rhythmically for 30s!';
          case 'vi': return 'Ngồi lên đùi, ôm cổ, đung đưa say đắm 30 giây!';
          case 'ja': return '相手の膝に乗り、首に腕を回して30秒揺れる！';
          default:   return '跨坐上对方大腿，搂颈缠绵摇晃30秒！';
        }
      default: return '';
    }
  }
}
