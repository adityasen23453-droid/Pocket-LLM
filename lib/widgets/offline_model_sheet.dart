import 'package:flutter/material.dart';
import '../services/offline_ai_service.dart';

/// Interactive 3-Tier Offline AI Model Hub for Arka Jain University students.
/// Supports switching between 0.5B, 1.5B, and 3B models tailored for 4GB to 8GB phones.
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

  ModelTierId? _downloadingTierId;
  double _downloadProgress = 0.0;
  String _downloadStatus = 'Connecting...';
  String? _errorMessage;
  bool _isSwitching = false;

  Map<ModelTierId, bool> _installedStatus = {
    ModelTierId.nano: false,
    ModelTierId.balanced: false,
    ModelTierId.pro: false,
  };

  @override
  void initState() {
    super.initState();
    _checkInstalledModels();
  }

  Future<void> _checkInstalledModels() async {
    final nanoOk = await _offlineService.isModelDownloaded(ModelTierId.nano);
    final balOk = await _offlineService.isModelDownloaded(ModelTierId.balanced);
    final proOk = await _offlineService.isModelDownloaded(ModelTierId.pro);

    if (mounted) {
      setState(() {
        _installedStatus = {
          ModelTierId.nano: nanoOk,
          ModelTierId.balanced: balOk,
          ModelTierId.pro: proOk,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161917) : const Color(0xFFFAF7F0);
    final textPrimary = isDark ? const Color(0xFFF7F4EE) : const Color(0xFF14261A);
    final textSecondary = isDark ? const Color(0xFFACAFAB) : const Color(0xFF555955);
    final emeraldAccent = isDark ? const Color(0xFF8BB596) : const Color(0xFF2E6B41);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x35DFCDBC);

    final activeTierId = _offlineService.activeTierId;
    final isLoaded = _offlineService.isModelLoaded;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
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
          const SizedBox(height: 14),

          // Header: AJU Logo + Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/aju_pocketllm_logo.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
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
                        'PocketLLM · AI Model Hub',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Arka Jain University • On-Device Models',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: emeraldAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: textSecondary, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Scrollable Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              shrinkWrap: true,
              children: [
                // Hardware Recommendation Guide Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2420) : const Color(0xFFEBF3ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: emeraldAccent.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.memory_rounded, color: emeraldAccent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Choose the model tailored for your phone\'s RAM. 4GB phones run Nano, 6GB run Balanced, and 8GB phones run Pro smoothly with 0% thermal throttling.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.35,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Error message banner if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // 3 Model Cards
                ...OfflineAiService.tiers.map((tier) {
                  final isCurrentActive = isLoaded && activeTierId == tier.id;
                  final isInstalled = _installedStatus[tier.id] ?? false;
                  final isThisDownloading = _downloadingTierId == tier.id;

                  return _buildModelCard(
                    tier: tier,
                    isActive: isCurrentActive,
                    isInstalled: isInstalled,
                    isDownloading: isThisDownloading,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    emeraldAccent: emeraldAccent,
                    borderColor: borderColor,
                  );
                }),

                const SizedBox(height: 12),

                // Custom GGUF picker
                OutlinedButton.icon(
                  onPressed: _isSwitching || _downloadingTierId != null ? null : _pickExistingFile,
                  icon: Icon(Icons.folder_open_rounded, size: 18, color: textPrimary),
                  label: Text(
                    'Select Custom .gguf Model from Storage',
                    style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard({
    required ModelTierInfo tier,
    required bool isActive,
    required bool isInstalled,
    required bool isDownloading,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color emeraldAccent,
    required Color borderColor,
  }) {
    final cardBg = isActive
        ? (isDark ? const Color(0xFF1E2D23) : const Color(0xFFEDF5EF))
        : (isDark ? const Color(0xFF1F2220) : const Color(0xFFF3EFE6));

    final cardBorder = isActive
        ? emeraldAccent.withValues(alpha: 0.6)
        : borderColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: isActive ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black38 : Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  tier.badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: emeraldAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Specs Badges: RAM requirement + Speed + Size
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildSpecPill(
                icon: Icons.speed_rounded,
                label: tier.speedRating,
                isDark: isDark,
                textPrimary: textPrimary,
              ),
              _buildSpecPill(
                icon: Icons.memory_rounded,
                label: 'Min: ${tier.minRam}',
                isDark: isDark,
                textPrimary: textPrimary,
              ),
              _buildSpecPill(
                icon: Icons.sd_storage_rounded,
                label: tier.fileSizeDisplay,
                isDark: isDark,
                textPrimary: textPrimary,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            tier.description,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Download Progress Bar (if downloading)
          if (isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                minHeight: 8,
                backgroundColor: isDark ? Colors.black26 : Colors.white60,
                valueColor: AlwaysStoppedAnimation<Color>(emeraldAccent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _downloadStatus,
              style: TextStyle(fontSize: 11.5, color: textSecondary),
            ),
          ] else ...[
            // Action Button
            Row(
              children: [
                if (isActive) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Loaded & Ready in RAM',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (isInstalled) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSwitching || _downloadingTierId != null
                          ? null
                          : () => _handleSwitchModel(tier.id),
                      icon: _isSwitching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        _isSwitching ? 'Switching...' : 'Switch to this Model',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSwitching || _downloadingTierId != null
                        ? null
                        : () => _handleDeleteAndRedownload(tier.id),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Re-download Model',
                    style: IconButton.styleFrom(
                      foregroundColor: textSecondary,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSwitching || _downloadingTierId != null
                          ? null
                          : () => _handleDownloadModel(tier.id),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        '1-Tap Download (${tier.fileSizeDisplay})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2D4D36) : const Color(0xFF172C1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textPrimary.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownloadModel(ModelTierId tierId) async {
    setState(() {
      _downloadingTierId = tierId;
      _downloadProgress = 0.0;
      _downloadStatus = 'Connecting to high-speed CDN...';
      _errorMessage = null;
    });

    final success = await _offlineService.downloadModel(
      tierId: tierId,
      onProgress: (progress, status) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
            _downloadStatus = status;
          });
        }
      },
    );

    await _checkInstalledModels();

    if (mounted) {
      setState(() {
        _downloadingTierId = null;
        if (!success) {
          _errorMessage = 'Download failed. Please check internet connection and try again.';
        }
      });

      if (success) {
        widget.onModelReady?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${_offlineService.activeTier?.displayName ?? "Offline AI"} activated successfully!'),
            backgroundColor: const Color(0xFF2E6B41),
          ),
        );
      }
    }
  }

  Future<void> _handleSwitchModel(ModelTierId tierId) async {
    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    final success = await _offlineService.switchModel(tierId);
    await _checkInstalledModels();

    if (mounted) {
      setState(() {
        _isSwitching = false;
        if (!success) {
          _errorMessage = 'Failed to load model. The file may be incomplete or corrupted. Tap the refresh button to re-download.';
        }
      });

      if (success) {
        widget.onModelReady?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Switched to ${_offlineService.activeTier?.displayName}! Ready completely offline.'),
            backgroundColor: const Color(0xFF2E6B41),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAndRedownload(ModelTierId tierId) async {
    await _offlineService.deleteModel(tierId);
    await _checkInstalledModels();
    if (mounted) {
      _handleDownloadModel(tierId);
    }
  }

  Future<void> _pickExistingFile() async {
    final success = await _offlineService.pickLocalModel();
    await _checkInstalledModels();
    if (mounted) {
      if (success) {
        widget.onModelReady?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Custom .gguf model loaded successfully!'),
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
