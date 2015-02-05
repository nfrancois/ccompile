part of ccompile.ccompile;

class CompilerSettings {
  List<String> arguments = [];

  Map<String, String> defines = {};

  String executable;

  List<String> includes = [];

  List<String> inputFiles = [];

  String getExecutable([String defaultValue]) {
    if (executable == null) {
      return defaultValue;
    }

    return executable;
  }
}
