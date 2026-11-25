import 'dart:io';
import 'package:flutter/foundation.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final bool hasUpdate;
  final String releaseName;
  final String releaseNotes;
  final DateTime? publishedAt;
  final String htmlUrl;
  final String? windowsDownloadUrl;
  final String? macosDownloadUrl;
  final int? windowsFileSize;
  final int? macosFileSize;

  AppUpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.hasUpdate,
    required this.releaseName,
    required this.releaseNotes,
    this.publishedAt,
    required this.htmlUrl,
    this.windowsDownloadUrl,
    this.macosDownloadUrl,
    this.windowsFileSize,
    this.macosFileSize,
  });

  /// Link tải tương ứng với hệ điều hành đang chạy
  String? get downloadUrlForCurrentPlatform {
    if (kIsWeb) return htmlUrl;
    if (Platform.isWindows) return windowsDownloadUrl ?? htmlUrl;
    if (Platform.isMacOS) return macosDownloadUrl ?? htmlUrl;
    return htmlUrl;
  }

  /// Dung lượng file cài đặt tương ứng với hệ điều hành
  int? get fileSizeForCurrentPlatform {
    if (kIsWeb) return null;
    if (Platform.isWindows) return windowsFileSize;
    if (Platform.isMacOS) return macosFileSize;
    return null;
  }
}
