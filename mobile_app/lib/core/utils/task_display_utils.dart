/// Helpers for showing human-readable task labels instead of raw IDs.
class TaskDisplayUtils {
  static String fileNameFromObjectKey(String? objectKey) {
    if (objectKey == null || objectKey.trim().isEmpty) return '';
    final normalized = objectKey.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  static String taskTitle({
    String? objectKey,
    String? datasetName,
    String? projectName,
    String? fallbackId,
  }) {
    final fileName = fileNameFromObjectKey(objectKey);
    if (fileName.isNotEmpty) return fileName;
    if (datasetName != null && datasetName.trim().isNotEmpty) {
      return datasetName.trim();
    }
    if (projectName != null && projectName.trim().isNotEmpty) {
      return projectName.trim();
    }
    if (fallbackId != null && fallbackId.length >= 8) {
      return 'Task ${fallbackId.substring(0, 8)}';
    }
    return 'Task';
  }

  static String taskSubtitle({
    String? projectName,
    String? datasetName,
    String? annotatorEmail,
    String? status,
  }) {
    final parts = <String>[];
    if (projectName != null && projectName.trim().isNotEmpty) {
      parts.add(projectName.trim());
    }
    if (datasetName != null && datasetName.trim().isNotEmpty) {
      parts.add(datasetName.trim());
    }
    if (annotatorEmail != null && annotatorEmail.trim().isNotEmpty) {
      parts.add(annotatorEmail.trim());
    }
    if (status != null && status.trim().isNotEmpty) {
      parts.add(status.trim());
    }
    return parts.join(' • ');
  }
}
