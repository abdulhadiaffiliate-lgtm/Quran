import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/share_background_painter.dart';

/// Lets the user generate a shareable image of a Quran verse — Arabic
/// text, translation, and reference — over a choice of generated,
/// Islamic-themed backgrounds. No external images are used.
class ShareVerseScreen extends StatefulWidget {
  final String arabicText;
  final String translationText;
  final String reference; // e.g. "Al-Baqarah 2:255"

  const ShareVerseScreen({
    super.key,
    required this.arabicText,
    required this.translationText,
    required this.reference,
  });

  @override
  State<ShareVerseScreen> createState() => _ShareVerseScreenState();
}

class _ShareVerseScreenState extends State<ShareVerseScreen> {
  ShareBackground _background = ShareBackground.nightSky;
  final GlobalKey _cardKey = GlobalKey();
  bool _busy = false;

  Future<Uint8List?> _renderImage() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final bytes = await _renderImage();
      if (bytes == null) throw Exception('Could not render image');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/salahsync_verse.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Shared from SalahSync',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);
    try {
      final bytes = await _renderImage();
      if (bytes == null) throw Exception('Could not render image');
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        throw Exception('Gallery access not granted');
      }
      await Gal.putImageBytes(bytes, name: 'salahsync_verse');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to your gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share verse')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          painter: ShareBackgroundPainter(_background),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.arabicText,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: AppTheme.arabicStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.9,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  width: 40,
                                  height: 1.5,
                                  color:
                                      AppColors.goldLight.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  widget.translationText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  widget.reference,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'SalahSync',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Background picker
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ShareBackground.values.map((bg) {
                  final selected = bg == _background;
                  return GestureDetector(
                    onTap: () => setState(() => _background = bg),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.gold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: ShareBackgroundPainter(bg),
                              size: const Size(70, 64),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Text(
                                bg.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _saveToGallery,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.share_rounded),
                      label: const Text('Share'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.darkBg,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
