class CheckVersion {
  static bool isOlderVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
        return true;
      } else if (currentParts[i] > latestParts[i]) {
        return false;
      }
    }
    return false;
  }
}
