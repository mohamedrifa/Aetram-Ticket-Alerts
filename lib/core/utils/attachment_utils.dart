String? buildAttachmentUrl(String? path, String baseUrl) {
  if (path == null || path.trim().isEmpty) return null;
  final value = path.trim().replaceAll('\\', '/');
  final direct = Uri.tryParse(value);
  if (direct != null && (direct.scheme == 'http' || direct.scheme == 'https')) {
    return direct.toString();
  }
  var cleaned = value.startsWith('file:') ? value.substring(5) : value;
  final uploadedFilesIndex = cleaned.toLowerCase().indexOf('/uploadedfiles/');
  if (uploadedFilesIndex >= 0) {
    cleaned = cleaned.substring(uploadedFilesIndex);
  }
  if (!cleaned.startsWith('/')) cleaned = '/$cleaned';
  final base = Uri.tryParse(baseUrl);
  if (base == null || !base.hasScheme) return null;
  return base.resolve(cleaned).toString();
}

bool isImageUrl(String value) => RegExp(
  r'\.(png|jpe?g|gif|webp|bmp)(\?.*)?$',
  caseSensitive: false,
).hasMatch(value);
