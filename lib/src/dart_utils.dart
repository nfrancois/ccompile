part of ccompile.ccompile;

class DartUtils {
  static String getSdkFolder() {
    var path = Platform.environment['DART_SDK'];
    if(path == null) {
      return null;
    }

    if(path.endsWith('\\') || path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  static int getVmBits() => SysInfo.userSpaceBitness;
}
