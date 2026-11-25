import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_update_info.dart';
import '../../../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final UpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required UpdateService updateService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDialog(
        updateInfo: updateInfo,
        updateService: updateService,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  File? _downloadedFile;
  String? _errorMessage;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _startDownload() async {
    final downloadUrl = widget.updateInfo.downloadUrlForCurrentPlatform;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      // Nếu không có link asset trực tiếp, mở trang GitHub
      await UpdateService.openReleasePage(widget.updateInfo.htmlUrl);
      return;
    }

    // Tên file lưu trên máy
    final uri = Uri.parse(downloadUrl);
    final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'QLCSKB_Update.zip';

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = widget.updateInfo.fileSizeForCurrentPlatform ?? 0;
      _errorMessage = null;
    });

    final file = await widget.updateService.downloadUpdateFile(
      downloadUrl: downloadUrl,
      fileName: fileName,
      onProgress: (received, total) {
        if (mounted) {
          setState(() {
            _receivedBytes = received;
            if (total > 0) {
              _totalBytes = total;
              _progress = received / total;
            }
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        if (file != null) {
          _downloadedFile = file;
          _progress = 1.0;
        } else {
          _errorMessage = 'Tải bản cập nhật thất bại. Vui lòng thử lại hoặc tải trực tiếp từ GitHub!';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;
    final platformName = kIsWeb ? 'Web' : (Platform.isWindows ? 'Windows' : (Platform.isMacOS ? 'macOS' : 'Hệ điều hành'));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppTheme.cardDark,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rocket_launch, color: AppTheme.primaryOrange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Phiên bản mới: v${info.latestVersion}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Bạn đang ở v${info.currentVersion} • Nền tảng $platformName',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên bản phát hành
              if (info.releaseName.isNotEmpty) ...[
                Text(
                  info.releaseName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                const SizedBox(height: 8),
              ],

              // Nội dung cập nhật (Changelog)
              const Text('Nội dung cập nhật & sửa lỗi:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    info.releaseNotes.trim().isNotEmpty
                        ? info.releaseNotes
                        : 'Bản cập nhật tối ưu hóa hiệu năng và sửa lỗi.',
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Báo lỗi (nếu có)
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dangerRed.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppTheme.dangerRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.dangerRed, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Trạng thái Đang Tải (Progress Bar)
              if (_isDownloading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Đang tải bản cập nhật...', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        Text(
                          '${(_progress * 100).toInt()}% (${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.kiCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        minHeight: 8,
                        backgroundColor: AppTheme.borderDark,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.kiCyan),
                      ),
                    ),
                  ],
                ),
              ],

              // Trạng thái Tải Thành Công
              if (_downloadedFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.successGreen.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tải về thành công!',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'File lưu tại: ${_downloadedFile!.path}',
                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '💡 Lưu ý: Khi cài đè bản mới, toàn bộ dữ liệu SQLite hiện tại sẽ được bảo toàn nguyên vẹn 100%.',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Để Sau', style: TextStyle(color: Colors.grey)),
          ),
        TextButton.icon(
          onPressed: () => UpdateService.openReleasePage(info.htmlUrl),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Xem Trên GitHub'),
        ),
        if (_downloadedFile != null) ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              UpdateService.openDownloadedFile(_downloadedFile!);
            },
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Mở Thư Mục Chứa File'),
          ),
        ] else if (!_isDownloading) ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.black,
            ),
            onPressed: _startDownload,
            icon: const Icon(Icons.download, size: 18),
            label: Text(
              info.fileSizeForCurrentPlatform != null
                  ? 'Tải Bản Mới (${_formatBytes(info.fileSizeForCurrentPlatform!)})'
                  : 'Tải Bản Cập Nhật Mới',
            ),
          ),
        ],
      ],
    );
  }
}
