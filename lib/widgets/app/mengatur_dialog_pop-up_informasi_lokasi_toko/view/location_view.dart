import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/location_controller.dart';
import '../../../../data/helpers/navigation_helper.dart';

/// View untuk Live Location Tracker dengan toggle GPS/Network dan navigasi ke Warung Cakwi
class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Tracker - Warung Cakwi',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPosition,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.openAppSettings,
            tooltip: 'Open Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mendapatkan lokasi...'),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.requestPermission,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Request Permission'),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                if (controller.currentPosition != null)
                  _buildNavigationInfo(controller),
                Expanded(child: _buildOpenStreetMap(controller)),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.zoomIn();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error zoom in: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.zoomOut();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error zoom out: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'center',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.moveToCurrentPosition();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error move to position: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavigationInfo(LocationController controller) {
    final navInfo = NavigationHelper.getNavigationInfo(
      controller.currentPosition!,
    );

    // Warna berubah sesuai GPS/Network mode
    final primaryColor = controller.isGpsEnabled ? Colors.green : Colors.blue;
    final secondaryColor = controller.isGpsEnabled
        ? Colors.green.shade400
        : Colors.blue.shade400;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.shade600, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warung Cakwi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Arah: ${navInfo['direction']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // GPS/Network Toggle
              Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.isGpsEnabled
                          ? Icons.gps_fixed
                          : Icons.network_cell,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      controller.isGpsEnabled ? 'GPS' : 'Net',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 40,
                      height: 24,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Switch(
                          value: controller.isGpsEnabled,
                          onChanged: (value) => controller.toggleGps(),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.white.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.3,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isTracking)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInfoCardWhite(
                  icon: Icons.straighten,
                  label: 'Jarak',
                  value: navInfo['distanceFormatted'],
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCardWhite(
                  icon: Icons.directions_walk,
                  label: 'Jalan Kaki',
                  value: navInfo['walkingTime'],
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoCardWhite(
            icon: Icons.directions_car,
            label: 'Kendaraan',
            value: navInfo['drivingTime'],
            color: primaryColor,
          ),

          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            title: const Text(
              'Detail Koordinat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildCoordinateRow(
                      'Lat',
                      controller.latitude?.toStringAsFixed(6) ?? 'N/A',
                      Icons.north,
                    ),
                    const SizedBox(height: 8),
                    _buildCoordinateRow(
                      'Lng',
                      controller.longitude?.toStringAsFixed(6) ?? 'N/A',
                      Icons.east,
                    ),
                    const SizedBox(height: 8),
                    _buildCoordinateRow(
                      'Akurasi',
                      '${controller.accuracy?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.my_location,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardWhite({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16, color: Colors.white),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar(
              'Copied',
              '$label: $value',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.black87,
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpenStreetMap(LocationController controller) {
    if (controller.currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Menunggu data lokasi...',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.getCurrentPosition,
              icon: const Icon(Icons.location_searching),
              label: const Text('Dapatkan Lokasi'),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      try {
        final routeLine = NavigationHelper.generateRouteLine(
          controller.currentPosition!,
        );

        // Warna marker berubah sesuai GPS/Network mode
        final markerColor = controller.isGpsEnabled
            ? Colors.green
            : Colors.blue;

        return FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: controller.mapCenter,
            initialZoom: controller.mapZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            onMapEvent: (MapEvent event) {
              if (event is MapEventMove) {
                try {
                  if (controller.isMapControllerReady) {
                    final camera = controller.mapController.camera;
                    controller.updateMapCenter(camera.center, camera.zoom);
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('Error updating map center: $e');
                  }
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mobile.modul5',
              maxZoom: 19,
              retinaMode: MediaQuery.of(Get.context!).devicePixelRatio > 1.0,
            ),

            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeLine,
                  strokeWidth: 4,
                  color: markerColor.shade600,
                  borderColor: Colors.white,
                  borderStrokeWidth: 2,
                ),
              ],
            ),

            if (controller.currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(controller.latitude!, controller.longitude!),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  Marker(
                    point: NavigationHelper.warungLocation,
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

            SimpleAttributionWidget(
              source: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
              alignment: Alignment.bottomLeft,
            ),
          ],
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error rendering map: $e');
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading map', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  controller.resetMapController();
                  controller.refreshPosition();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    });
  }
}
