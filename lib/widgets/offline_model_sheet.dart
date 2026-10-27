import 'package:flutter/material.dart';
import '../services/offline_ai_service.dart';

/// Clean bottom sheet modal allowing users to download or pick the Qwen 2.5 1.5B
/// offline AI brain with 1 tap, zero USB cables, and real-time download progress.
class OfflineModelSheet extends StatefulWidget {
  final VoidCallback? onModelReady;

  const OfflineModelSheet({super.key, this.onModelReady});

  static Future<void> show(BuildContext context, {VoidCallback? onModelReady}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfflineModelSheet(onModelReady: onModelReady),
    );
  }

  @override
  State<OfflineModelSheet> createState() => _OfflineModelSheetState();
}

class _OfflineModelSheetState extends State<OfflineModelSheet> {
  final OfflineAiService _offlineService = OfflineAiService();

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = 'Preparing download...';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF181B19) : const Color(0xFFFAF7F0);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textSecondary = isDark ? const Color(0xFFACAFAB) : const Color(0xFF555955);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF172C1E);
    final emeraldButton = isDark ? const Color(0xFF2D4D36) : const Color(0xFF172C1E);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);

    final isLoaded = _offlineService.isModelLoaded;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: AJU Logo + Title
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/aju_pocketllm_logo.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: emeraldAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school_rounded, color: emeraldAccent, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PocketLLM · Offline AI Core',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arka Jain University • Qwen 2.5 1.5B',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: emeraldAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),

          if (isLoaded) ...[
            // Status: ALREADY LOADED
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Core is 100% Active & Ready',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You can now chat completely offline with your laptop turned off.',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Chatting', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ] else ...[
            // Status: NOT LOADED
            Text(
              'Run PocketLLM completely offline with 0% internet and zero laptop connection.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            if (_isDownloading) ...[
              // Live Download Progress Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF222623) : const Color(0xFFEDE8DC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Downloading AI Brain...',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: emeraldAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _downloadProgress > 0 ? _downloadProgress : null,
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.black26 : Colors.white60,
                        valueColor: AlwaysStoppedAnimation<Color>(emeraldAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _downloadStatus,
                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              // 1-Tap Download Button
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  '1-Tap Wireless Download (1.04 GB)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Button: Pick Existing File
              OutlinedButton.icon(
                onPressed: _pickExistingFile,
                icon: Icon(Icons.folder_open_rounded, size: 18, color: textPrimary),
                label: Text(
                  'Already have the file? Select .gguf',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Connecting to high-speed CDN...';
      _errorMessage = null;
    });

    final success = await _offlineService.downloadModel(
      onProgress: (progress, status) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
            _downloadStatus = status;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        if (!success) {
          _errorMessage = 'Download failed. Please check internet connection and try again.';
        }
      });

      if (success) {
        widget.onModelReady?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Qwen 2.5 1.5B successfully activated for 100% offline use!'),
            backgroundColor: Color(0xFF2E6B41),
          ),
        );
      }
    }
  }

  Future<void> _pickExistingFile() async {
    final success = await _offlineService.pickLocalModel();
    if (mounted) {
      if (success) {
        widget.onModelReady?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Selected offline model loaded successfully!'),
            backgroundColor: Color(0xFF2E6B41),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Could not load selected file. Please select a valid .gguf model.';
        });
      }
    }
  }
}

