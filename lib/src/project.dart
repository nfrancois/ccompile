part of ccompile.ccompile;

class Project {
  int bits;

  CompilerSettings compilerSettings;

  LinkerSettings linkerSettings;

  List<String> clean = [];

  Project() {
    compilerSettings = new CompilerSettings();
    linkerSettings = new LinkerSettings();
  }

  int getBits([int defaultValue]) {
    if(bits == 0) {
      return DartUtils.getVmBits();
    }

    if(bits == null) {
      return defaultValue;
    }

    return bits;
  }
}
