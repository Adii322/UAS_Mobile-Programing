import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:young_care/app/modules/pedometer/controllers/pedometer_run_controller.dart';
import 'package:young_care/app/modules/pedometer/widgets/run_card.dart';

class PedometerRunView extends GetView<PedometerRunController> {
  const PedometerRunView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Get.height, minWidth: Get.width),
        child: Column(
          children: [
            Obx(() {
              if (controller.isLoadingPosition.value) {
                return Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(width: Get.width, color: Colors.grey[300]),
                  ),
                );
              }

              final initial =
                  controller.initialPosition ??
                  controller.currentPosition.value;
              final current = controller.currentPosition.value;

              if (initial == null) {
                return const Expanded(
                  child: Center(child: Text('Lokasi tidak tersedia')),
                );
              }

              return Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(initial.latitude, initial.longitude),
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.singgidev.young_care',
                    ),
                    if (controller.recordedPositions.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: controller.recordedPositions.toList(),
                            color: const Color(0xFF03624C),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    if (current != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point:LatLng(
                              current.latitude,
                              current.longitude,
                            ),
                            width: 12,
                            height: 12,
                            child: const RouteMarker(color: Colors.green),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.zero,
                  top: Radius.circular(12),
                ),
                border: Border.all(color: Color(0xFFBAD0D0)),
              ),
              child: Column(
                children: [
                  Text(
                    "Pedometer",
                    style: GoogleFonts.lexendDeca(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff787470),
                    ),
                  ),
                  SizedBox(height: 14),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              controller.formattedElapsed,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 24,
                                color: Color(0xff202226),
                              ),
                            ),
                            Text(
                              "Time",
                              style: GoogleFonts.figtree(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff787470),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              controller.distanceInKilometers,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 24,
                                color: Color(0xff202226),
                              ),
                            ),
                            Text(
                              "Distance",
                              style: GoogleFonts.figtree(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff787470),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              controller.paceLabel,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 24,
                                color: Color(0xff202226),
                              ),
                            ),
                            Text(
                              "Pace",
                              style: GoogleFonts.figtree(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff787470),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Obx(() {
                    final status = controller.runStatus.value;
                    final isSaving = controller.isSavingRun.value;
                    if (status == RunStatus.idle) {
                      return IconButton.filled(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Color(0XFF03624C),
                          ),
                        ),
                        onPressed: isSaving ? null : controller.startRun,
                        icon: isSaving
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded, size: 50),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Color(0XFF03624C),
                                ),
                              ),
                              onPressed: status == RunStatus.running
                                  ? controller.pauseRun
                                  : controller.resumeRun,
                              icon: Icon(
                                status == RunStatus.running
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                status == RunStatus.running
                                    ? 'Pause'
                                    : 'Resume',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Color(0xFFBA2D0B),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final shouldFinish =
                                          await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                    'Selesaikan Lari?',
                                                  ),
                                                  content: const Text(
                                                    'Apakah kamu yakin ingin mengakhiri rekaman lari?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                        dialogContext,
                                                      ).pop(false),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                        dialogContext,
                                                      ).pop(true),
                                                      child:
                                                          const Text('Selesai'),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;

                                      if (!shouldFinish) {
                                        return;
                                      }

                                      try {
                                        final summary = await controller
                                            .finishRunAndPersist();
                                        Get.snackbar(
                                          'Lari Disimpan',
                                          'Waktu ${controller.formatDuration(summary.elapsed)}, jarak ${controller.formatDistanceMeters(summary.distanceMeters)} km',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      } catch (error) {
                                        final String message =
                                            error.toString().startsWith(
                                                  'Exception: ',
                                                )
                                                ? error
                                                    .toString()
                                                    .substring(11)
                                                : error.toString();
                                        Get.snackbar(
                                          'Gagal Menyimpan',
                                          message,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      }
                                    },
                              icon: isSaving
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.flag_rounded),
                              label: Text(isSaving ? 'Saving...' : 'Finish'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
