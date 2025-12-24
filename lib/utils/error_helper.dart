import 'package:flutter/material.dart';

// 🔍 MARKER: ERROR_RECOVERY_HELPER
/// Helper class for user-friendly error messages with solutions
class ErrorHelper {
  
  /// Convert technical errors to user-friendly messages with suggestions
  static ErrorInfo getErrorInfo(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('socketexception') || 
        errorStr.contains('connection') ||
        errorStr.contains('network')) {
      return ErrorInfo(
        icon: Icons.wifi_off,
        title: 'Tidak Ada Koneksi',
        message: 'Periksa koneksi internet Anda',
        suggestion: 'Aktifkan WiFi atau data seluler',
        actionLabel: 'Coba Lagi',
      );
    }
    
    // Timeout errors
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return ErrorInfo(
        icon: Icons.hourglass_empty,
        title: 'Koneksi Lambat',
        message: 'Server tidak merespons',
        suggestion: 'Coba di tempat dengan sinyal lebih baik',
        actionLabel: 'Coba Lagi',
      );
    }
    
    // GPS/Location errors
    if (errorStr.contains('location') || errorStr.contains('gps')) {
      return ErrorInfo(
        icon: Icons.location_off,
        title: 'Lokasi Tidak Tersedia',
        message: 'Tidak dapat mengakses lokasi',
        suggestion: 'Aktifkan GPS di pengaturan',
        actionLabel: 'Buka Pengaturan',
      );
    }
    
    // Permission errors
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return ErrorInfo(
        icon: Icons.block,
        title: 'Akses Ditolak',
        message: 'Izin aplikasi diperlukan',
        suggestion: 'Berikan izin di pengaturan aplikasi',
        actionLabel: 'Buka Pengaturan',
      );
    }
    
    // Auth errors
    if (errorStr.contains('auth') || 
        errorStr.contains('login') ||
        errorStr.contains('password')) {
      return ErrorInfo(
        icon: Icons.lock_outline,
        title: 'Gagal Masuk',
        message: 'Email atau password salah',
        suggestion: 'Periksa kembali data login Anda',
        actionLabel: 'Coba Lagi',
      );
    }
    
    // Server errors
    if (errorStr.contains('500') || errorStr.contains('server')) {
      return ErrorInfo(
        icon: Icons.cloud_off,
        title: 'Server Bermasalah',
        message: 'Terjadi kesalahan di server',
        suggestion: 'Coba beberapa saat lagi',
        actionLabel: 'Coba Lagi',
      );
    }
    
    // Default error
    return ErrorInfo(
      icon: Icons.error_outline,
      title: 'Terjadi Kesalahan',
      message: 'Tidak dapat memuat data',
      suggestion: 'Coba muat ulang halaman',
      actionLabel: 'Coba Lagi',
    );
  }
}

/// Error information with icon, messages and action
class ErrorInfo {
  final IconData icon;
  final String title;
  final String message;
  final String suggestion;
  final String actionLabel;
  
  const ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
    required this.suggestion,
    required this.actionLabel,
  });
}

/// Reusable Error Widget with retry button
class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool compact;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final errorInfo = ErrorHelper.getErrorInfo(errorMessage);
    
    if (compact) {
      return _buildCompact(context, colorScheme, textTheme, errorInfo);
    }
    return _buildFull(context, colorScheme, textTheme, errorInfo);
  }

  Widget _buildCompact(BuildContext context, ColorScheme colorScheme, 
      TextTheme textTheme, ErrorInfo info) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(info.icon, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${info.message}. ${info.suggestion}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(info.actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context, ColorScheme colorScheme, 
      TextTheme textTheme, ErrorInfo info) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                info.icon,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              info.title,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              info.message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
            // Suggestion
            Text(
              info.suggestion,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Retry button
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(info.actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
