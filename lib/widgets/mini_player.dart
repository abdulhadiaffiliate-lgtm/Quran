import 'package:flutter/material.dart';
import '../services/quran_player_service.dart';
import '../theme/app_colors.dart';

/// A persistent mini-player that slides up above the bottom nav bar when
/// a surah is playing. Stays visible across all tabs so the user can
/// control playback without returning to the Quran reader.
class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap; // e.g. navigate back to the reader

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: QuranPlayerService.instance,
      builder: (context, _) {
        final state = QuranPlayerService.instance.state;

        // Only render when there's an active track
        if (!state.hasTrack) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.tealPrimary, AppColors.tealPrimaryLight],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealPrimary.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                children: [
                  // Quran icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.surahName ?? 'Quran',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.isPlaying
                              ? _ayahLabel(state)
                              : 'Paused',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Play / Pause
                      _ControlButton(
                        icon: (state.isPlaying)
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: () =>
                            QuranPlayerService.instance.togglePlayPause(),
                      ),
                      const SizedBox(width: 4),
                      // Stop
                      _ControlButton(
                        icon: Icons.stop_rounded,
                        onTap: () => QuranPlayerService.instance.stop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _ayahLabel(state) {
    final idx = state.ayahIndex;
    final total = state.totalAyahs;
    if (idx == null || total == null) return 'Playing…';
    return 'Ayah ${idx + 1} of $total';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
