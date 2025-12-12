import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:young_care/app/modules/pedometer/controllers/pedometer_controller.dart';

class RunCard extends GetView<PedometerController> {
  const RunCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.dailyResults.value;
      final result = controller.selectedResult.value;

      final bool showStats =
          !state.isLoading && !state.hasError && result != null;

      final String subtitle;
      if (state.isLoading) {
        subtitle = 'Loading session...';
      } else if (state.hasError) {
        subtitle = controller.errorMessage ?? 'Failed to load sessions.';
      } else if (result == null) {
        subtitle =
            'No session recorded on ${controller.selectedDateLabel}.';
      } else {
        subtitle = controller.sessionDetailLabel(result);
      }

      final String distanceText =
          showStats ? controller.selectedDistanceLabel : '--';
      final String paceText =
          showStats ? controller.selectedPaceLabel : '--';
      final String durationText =
          showStats ? controller.selectedDurationLabel : '--';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Session',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff24211E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: const Color(0xff787470),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RunStat(
                        label: 'Distance',
                        value: distanceText,
                      ),
                      _RunStat(
                        label: 'Pace',
                        value: paceText,
                      ),
                      _RunStat(
                        label: 'Time',
                        value: durationText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              color: const Color(0xFFBAD0D0),
            ),
            _RunMapSection(
              isLoading: state.isLoading,
              hasError: state.hasError,
              errorMessage: controller.errorMessage,
              selectedRoute: controller.selectedRoute,
              dateLabel: controller.selectedDateLabel,
            ),
          ],
        ),
      );
    });
  }
}

class _RunStat extends StatelessWidget {
  const _RunStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.bebasNeue(
            fontSize: 20,
            color: const Color(0xff202226),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 12,
            color: const Color(0xff787470),
          ),
        ),
      ],
    );
  }
}

class _RunMapSection extends StatelessWidget {
  const _RunMapSection({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.selectedRoute,
    required this.dateLabel,
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<LatLng> selectedRoute;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
        ),
      );
    }

    if (hasError) {
      return _RunMessage(
        message: errorMessage ?? 'Failed to load session map.',
      );
    }

    if (selectedRoute.length < 2) {
      return _RunMessage(
        message: 'No route recorded for $dateLabel.',
      );
    }

    final bounds = LatLngBounds.fromPoints(selectedRoute);

    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(32),
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.singgidev.young_care',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: selectedRoute,
                strokeWidth: 4,
                color: const Color(0xff2CC295),
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedRoute.first,
                width: 12,
                height: 12,
                child: const RouteMarker(color: Colors.green),
              ),
              Marker(
                point: selectedRoute.last,
                width: 12,
                height: 12,
                child: const RouteMarker(color: Colors.red),
              ),
            ],
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}

class RouteMarker extends StatelessWidget {
  const RouteMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _RunMessage extends StatelessWidget {
  const _RunMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.lexendDeca(
          fontSize: 12,
          color: const Color(0xff787470),
        ),
      ),
    );
  }
}
