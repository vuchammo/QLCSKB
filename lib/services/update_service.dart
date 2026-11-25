import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';
import '../models/app_update_info.dart';

class UpdateService {
  final http.Client _client;

  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Lấy phiên bản ứng dụng đang chạy hiện tại
  static Future<String> getCurrentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version.isNotEmpty ? info.version : AppConstants.version;
    } catch (_) {
      return AppConstants.version;
    }
  }

  /// So sánh hai chuỗi phiên bản chuẩn SemVer (Ví dụ: "1.1.0" > "1.0.0")
  /// Trả về true nếu latestVersion mới hơn currentVersion
  static bool isNewerVersion(String currentVersion, String latestVersion) {
    final curParts = _normalizeVersion(currentVersion);
    final latParts = _normalizeVersion(latestVersion);

    final maxLen = curParts.length > latParts.length ? curParts.length : latParts.length;

    for (int i = 0; i < maxLen; i++) {
      final cur = i < curParts.length ? curParts[i] : 0;
      final lat = i < latParts.length ? latParts[i] : 0;

      if (lat > cur) return true;
      if (lat < cur) return false;
    }
    return false;
  }

  static List<int> _normalizeVersion(String v) {
    // Loại bỏ tiền tố 'v', 'V' và phần build metadata sau dấu '+'
    var clean = v.trim().toLowerCase();
    if (clean.startsWith('v')) clean = clean.substring(1);
    if (clean.contains('+')) clean = clean.split('+').first;

    final parts = clean.split('.');
    final result = <int>[];
    for (final p in parts) {
      final numVal = int.tryParse(p) ?? 0;
      result.add(numVal);
    }
    return result;
  }

  /// Kiểm tra phiên bản mới từ GitHub Releases API
  Future<AppUpdateInfo?> checkForUpdate({
    String? currentVersion,
    String? repo,
  }) async {
    final curVer = currentVersion ?? await getCurrentAppVersion();
    final targetRepo = (repo != null && repo.trim().isNotEmpty)
        ? repo.trim()
        : AppConstants.defaultGithubRepo;

    final url = Uri.parse('https://api.github.com/repos/$targetRepo/releases/latest');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'QLCSKB-App-Updater',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('Không thể kiểm tra cập nhật (HTTP ${response.statusCode})');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return parseReleaseJson(data, curVer);
    } catch (e) {
      debugPrint('Lỗi kết nối kiểm tra cập nhật: $e');
      return null;
    }
  }

  /// Phân tích dữ liệu JSON GitHub Release thành AppUpdateInfo
  static AppUpdateInfo parseReleaseJson(Map<String, dynamic> json, String currentVersion) {
    final rawTag = (json['tag_name'] as String?) ?? '';
    final releaseName = (json['name'] as String?) ?? rawTag;
    final releaseNotes = (json['body'] as String?) ?? 'Bản cập nhật mới với các cải tiến và sửa lỗi.';
    final htmlUrl = (json['html_url'] as String?) ?? 'https://github.com';
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null ? DateTime.tryParse(publishedStr) : null;

    var latestVersion = rawTag;
    if (latestVersion.startsWith('v') || latestVersion.startsWith('V')) {
      latestVersion = latestVersion.substring(1);
    }

    final hasUpdate = isNewerVersion(currentVersion, latestVersion);

    String? winUrl;
    int? winSize;
    String? macUrl;
    int? macSize;

    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final a in assets) {
      if (a is Map<String, dynamic>) {
        final name = (a['name'] as String? ?? '').toLowerCase();
        final downloadUrl = a['browser_download_url'] as String?;
        final size = a['size'] as int?;

        // Tìm asset cho Windows: .exe hoặc zip có chứa 'win'
        if (name.endsWith('.exe') || (name.endsWith('.zip') && (name.contains('win') || name.contains('windows')))) {
          winUrl = downloadUrl;
          winSize = size;
        }

        // Tìm asset cho macOS: .dmg hoặc zip có chứa 'mac'
        if (name.endsWith('.dmg') || (name.endsWith('.zip') && (name.contains('mac') || name.contains('macos') || name.contains('darwin')))) {
          macUrl = downloadUrl;
          macSize = size;
        }
      }
    }

    return AppUpdateInfo(
      latestVersion: latestVersion,
      currentVersion: currentVersion,
      hasUpdate: hasUpdate,
      releaseName: releaseName,
      releaseNotes: releaseNotes,
      publishedAt: publishedAt,
      htmlUrl: htmlUrl,
      windowsDownloadUrl: winUrl,
      macosDownloadUrl: macUrl,
      windowsFileSize: winSize,
      macosFileSize: macSize,
    );
  }

  /// Tải file cài đặt về máy kèm báo cáo tiến trình (Progress)
  Future<File?> downloadUpdateFile({
    required String downloadUrl,
    required String fileName,
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/updates');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final saveFile = File('${downloadDir.path}/$fileName');
      if (await saveFile.exists()) {
        await saveFile.delete();
      }

      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'QLCSKB-App-Updater';
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        debugPrint('Tải file thất bại (HTTP ${response.statusCode})');
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      final sink = saveFile.openWrite();

      await response.stream.listen((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (onProgress != null) {
          onProgress(receivedBytes, totalBytes);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();

      return saveFile;
    } catch (e) {
      debugPrint('Lỗi tải file cài đặt: $e');
      return null;
    }
  }

  /// Mở file hoặc thư mục chứa file đã tải
  static Future<void> openDownloadedFile(File file) async {
    try {
      if (Platform.isWindows) {
        // Mở file installer hoặc mở Explorer trỏ đến file
        await Process.run('explorer.exe', ['/select,', file.path]);
      } else if (Platform.isMacOS) {
        // Mở Finder trỏ đến file
        await Process.run('open', ['-R', file.path]);
      }
    } catch (e) {
      debugPrint('Lỗi mở file: $e');
    }
  }

  /// Mở link trình duyệt
  static Future<bool> openReleasePage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
