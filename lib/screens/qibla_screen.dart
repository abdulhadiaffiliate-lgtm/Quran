import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../theme/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection; // bearing to Mecca from true north
  double _heading = 0; // device heading from compass
  String? _error;
  bool _loading = true;
  StreamSubscription? _compassSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      double lat, lng;
      try {
        final pos = await LocationService.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      } on LocationException {
        final cached = await LocationService.getCachedLocation();
        if (cached == null) rethrow;
        lat = cached.lat;
        lng = cached.lng;
      }
      final direction =
          await PrayerService.getQiblaDirection(latitude: lat, longitude: lng);
      if (!mounted) return;
      setState(() {
        _qiblaDirection = direction;
        _loading = false;
      });

      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading != null && mounted) {
          setState(() => _heading = event.heading!);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildCompass(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded,
                size: 56, color: AppColors.gold.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Could not determine Qibla.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _init, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    // Angle (in radians) to rotate the Qibla pointer relative to device heading.
    final qibla = _qiblaDirection ?? 0;
    final angle = (qibla - _heading) * (math.pi / 180);
    final aligned = ((qibla - _heading) % 360).abs() < 5 ||
        ((qibla - _heading) % 360).abs() > 355;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Qibla is ${qibla.toStringAsFixed(0)}° from North',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          aligned ? 'You are facing the Qibla' : 'Turn until the arrow is up',
          style: TextStyle(
            color: aligned ? AppColors.success : AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass dial rotates opposite to heading so N points north.
              Transform.rotate(
                angle: -_heading * (math.pi / 180),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.tealPrimaryLight,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Align(
                      alignment: Alignment(0, -0.85),
                      child: Text(
                        'N',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Qibla pointer (Kaaba direction).
              Transform.rotate(
                angle: angle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.navigation_rounded,
                      size: 80,
                      color: aligned ? AppColors.success : AppColors.gold,
                    ),
                    const SizedBox(height: 130),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Hold your phone flat and away from metal or magnets for the best accuracy. Calibrate by moving it in a figure-8 if the reading drifts.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
