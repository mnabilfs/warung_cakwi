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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Tracker - Warung Cakwi',
          style: TextStyle(fontSize: 18, color: colorScheme.onPrimaryContainer),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.primary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: controller.refreshPosition,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.primary),
            onPressed: controller.openAppSettings,
            tooltip: 'Open Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Mendapatkan lokasi...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
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
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.requestPermission,
                    icon: Icon(
                      Icons.location_on,
                      color: colorScheme.onSecondary,
                    ),
                    label: Text(
                      'Request Permission',
                      style: TextStyle(color: colorScheme.onSecondary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
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
                  _buildNavigationInfo(controller, colorScheme, textTheme),
                Expanded(child: _buildOpenStreetMap(controller, colorScheme)),
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
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.primary,
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
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.primary,
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
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.primary,
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

  Widget _buildNavigationInfo(
    LocationController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final navInfo = NavigationHelper.getNavigationInfo(
      controller.currentPosition!,
    );

    // PERBAIKAN 1: Warna berubah sesuai GPS/Network mode DAN tema
    final primaryColor = controller.isGpsEnabled
        ? colorScheme.primary
        : colorScheme.secondary;

    final secondaryColor = controller.isGpsEnabled
        ? colorScheme.primaryContainer
        : colorScheme.secondaryContainer;

    // Warna untuk teks pada gradient (kontras dengan primaryColor)
    final onPrimaryColor = controller.isGpsEnabled
        ? colorScheme.onPrimary
        : colorScheme.onSecondary;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
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
                  color: onPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant, color: onPrimaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warung Cakwi',
                      style: textTheme.titleLarge?.copyWith(
                        color: onPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Arah: ${navInfo['direction']}',
                      style: TextStyle(
                        color: onPrimaryColor.withOpacity(0.9),
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
                      color: onPrimaryColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      controller.isGpsEnabled ? 'GPS' : 'Net',
                      style: TextStyle(
                        fontSize: 10,
                        color: onPrimaryColor,
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
                          activeColor: onPrimaryColor,
                          activeTrackColor: onPrimaryColor.withOpacity(0.3),
                          inactiveThumbColor: onPrimaryColor,
                          inactiveTrackColor: onPrimaryColor.withOpacity(0.3),
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
                    color: onPrimaryColor,
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
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCardWhite(
                  icon: Icons.directions_walk,
                  label: 'Jalan Kaki',
                  value: navInfo['walkingTime'],
                  color: primaryColor,
                  colorScheme: colorScheme,
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
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: onPrimaryColor,
            collapsedIconColor: onPrimaryColor,
            title: Text(
              'Detail Koordinat',
              style: TextStyle(
                color: onPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: onPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildCoordinateRow(
                      'Lat',
                      controller.latitude?.toStringAsFixed(6) ?? 'N/A',
                      Icons.north,
                      onPrimaryColor,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildCoordinateRow(
                      'Lng',
                      controller.longitude?.toStringAsFixed(6) ?? 'N/A',
                      Icons.east,
                      onPrimaryColor,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildCoordinateRow(
                      'Akurasi',
                      '${controller.accuracy?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.my_location,
                      onPrimaryColor,
                      colorScheme,
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
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: iconColor.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, size: 16, color: iconColor),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar(
              'Copied',
              '$label: $value',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              backgroundColor: colorScheme.surfaceContainerHighest,
              colorText: colorScheme.onSurface,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpenStreetMap(
    LocationController controller,
    ColorScheme colorScheme,
  ) {
    if (controller.currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Menunggu data lokasi...',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.getCurrentPosition,
              icon: Icon(
                Icons.location_searching,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                'Dapatkan Lokasi',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      try {
        if (controller.routePoints.isEmpty &&
            controller.currentPosition != null &&
            !controller.isFetchingRoute.value) {
          controller.fetchRoute();
        }

        final routeLine = controller.routePoints;

        // PERBAIKAN 2: Warna marker berubah sesuai GPS/Network mode DAN tema
        final markerColor = controller.isGpsEnabled
            ? colorScheme.primary
            : colorScheme.secondary;

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
                  color: markerColor,
                  borderColor: colorScheme.surface,
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
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: colorScheme.onPrimary,
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
                        color: colorScheme.tertiary ?? Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.restaurant,
                        color: colorScheme.onTertiary ?? Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

            SimpleAttributionWidget(
              source: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
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
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error loading map',
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  controller.resetMapController();
                  controller.refreshPosition();
                },
                icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
                label: Text(
                  'Retry',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}