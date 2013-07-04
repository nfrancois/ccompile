part of ccompile;

class CompilerSettings {
  List<String> arguments = [];

  String compileAs;

  Map<String, String> defines = {};

  String executable;

  List<String> includes = [];

  List<String> inputFiles = [];

  String getLanguage() {
    if(compileAs == null) {
      return 'C++';
    }
  }

  String getExecutable([String defaultValue]) {
    if(executable == null) {
      return defaultValue;
    }

    return executable;
  }
}
