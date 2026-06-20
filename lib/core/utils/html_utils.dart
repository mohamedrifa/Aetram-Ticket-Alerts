String stripHtml(String html) => html
    .replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
      '',
    )
    .replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true),
      '',
    )
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
