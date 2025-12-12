import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';

/// Global banner that informs the user when the ESP32 device is not connected.
class BluetoothConnectionBanner extends StatelessWidget {
  const BluetoothConnectionBanner({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final BluetoothController controller = Get.find<BluetoothController>();

    return Obx(
      () {
        final bool showBanner =
            !controller.isConnected.value && controller.isConnectionBannerVisible.value;
        final String message = controller.connectionMessage.value;
        final bool isBusy =
            controller.isScanning.value || controller.isConnecting.value;

        return Stack(
          children: [
            if (child != null) child!,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                ignoring: !showBanner,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  offset: showBanner ? Offset.zero : const Offset(0, -1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showBanner ? 1 : 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFC1C1),
                              ),
                              color: const Color(0xFFFFF2F2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bluetooth_disabled,
                                      color: Color(0xFFD32F2F),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        message,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFD32F2F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: isBusy
                                          ? null
                                          : controller.retryConnection,
                                      icon: isBusy
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.refresh),
                                      label: Text(
                                        isBusy
                                            ? 'Menghubungkan...'
                                            : 'Coba lagi',
                                      ),
                                    ),
                                  ],
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
          ],
        );
      },
    );
  }
}
