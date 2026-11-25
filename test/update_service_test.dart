import 'package:flutter_test/flutter_test.dart';
import 'package:qlcskb/services/update_service.dart';

void main() {
  group('UpdateService SemVer Comparison Tests', () {
    test('isNewerVersion compares versions correctly', () {
      // Bản mới hơn
      expect(UpdateService.isNewerVersion('1.0.0', '1.0.1'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '1.1.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '2.0.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.9', '1.10.0'), isTrue);
      expect(UpdateService.isNewerVersion('v1.0.0', 'v1.0.1'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0+1', '1.0.1+2'), isTrue);

      // Bản cũ hơn hoặc bằng
      expect(UpdateService.isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('1.0.1', '1.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('2.0.0', '1.9.9'), isFalse);
      expect(UpdateService.isNewerVersion('1.1.0', '1.0.9'), isFalse);
      expect(UpdateService.isNewerVersion('v1.0.5', '1.0.5'), isFalse);
    });

    test('parseReleaseJson parses GitHub release correctly', () {
      final mockJson = {
        'tag_name': 'v1.1.0',
        'name': 'Phiên bản 1.1.0 - Thêm Máy Dò & Báo Cáo',
        'body': '- Thêm tính năng xuất dùng cá nhân\n- Tối ưu giao diện',
        'html_url': 'https://github.com/vuanhpham25/QLCSKB/releases/tag/v1.1.0',
        'published_at': '2026-11-25T10:00:00Z',
        'assets': [
          {
            'name': 'QLCSKB_Windows_x64.zip',
            'browser_download_url': 'https://github.com/vuanhpham25/QLCSKB/releases/download/v1.1.0/QLCSKB_Windows_x64.zip',
            'size': 25000000,
          },
          {
            'name': 'QLCSKB_macOS.zip',
            'browser_download_url': 'https://github.com/vuanhpham25/QLCSKB/releases/download/v1.1.0/QLCSKB_macOS.zip',
            'size': 28000000,
          }
        ]
      };

      final info = UpdateService.parseReleaseJson(mockJson, '1.0.0');

      expect(info.latestVersion, '1.1.0');
      expect(info.currentVersion, '1.0.0');
      expect(info.hasUpdate, isTrue);
      expect(info.releaseName, 'Phiên bản 1.1.0 - Thêm Máy Dò & Báo Cáo');
      expect(info.windowsDownloadUrl, 'https://github.com/vuanhpham25/QLCSKB/releases/download/v1.1.0/QLCSKB_Windows_x64.zip');
      expect(info.windowsFileSize, 25000000);
      expect(info.macosDownloadUrl, 'https://github.com/vuanhpham25/QLCSKB/releases/download/v1.1.0/QLCSKB_macOS.zip');
      expect(info.macosFileSize, 28000000);

      // Khi phiên bản hiện tại đã là 1.1.0
      final infoSame = UpdateService.parseReleaseJson(mockJson, '1.1.0');
      expect(infoSame.hasUpdate, isFalse);
    });
  });
}
