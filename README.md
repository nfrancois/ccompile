#CCompile is a Tools for compiling C/C++ Dart language native extensions.

This tools is a library written in Dart programming language.
It based on [ccompilers][ccompilers] package and intended to compile C/C++ source files from Dart scripts.

To test how it works run [example_build.dart][example_build_dart].
This will compile simple project called [sample_extension.yaml][sample_extension_yaml].

This project is a dart native C/C++ extension project.

After compile run [example_use_sample_extension.dart][example_use_sample_extension_dart].
This is a script that import [sample_extension.dart][sample_extension_dart] that have a native function calls to Dart VM.
And [sample_extension.dart][sample_extension_dart] uses compiled by [ccompile][ccompile] binary libraries to work.

If it works then your project will be succesful compiled.

You can compile projects stored in **json** and **yaml** formats.
Also you can create project via dart language class and compile it.

Here is an example of [sample_extension.yaml][sample_extension_yaml].

```yaml
bits: 0 # 0 means the bits of Dart SDK
compiler:
  includes: ['{DART_SDK}/bin', '{DART_SDK}/include']
  input_files:
  - 'sample_extension.cc'
clean: [ '*.exp', '*.lib', '*.o', '*.obj']
linker:
  input_files:
  - 'sample_extension'
platforms:
  linux:
    compiler:
      arguments: ['-fPIC', '-Wall']
    linker:
      arguments: ['-shared']
      output_file: 'libsample_extension.so'
  macos:
    compiler:
      arguments: ['-fPIC', '-Wall']
    linker:
      arguments: ['-dynamiclib', '-undefined', 'dynamic_lookup']
      output_file: 'libsample_extension.dylib'
  windows:
    compiler:
      defines: {'DART_SHARED_LIB':}
      input_files:
      - 'sample_extension_dllmain_win.cc'
    linker:
      arguments: ['/DLL']
      input_files:
      - 'dart.lib'
      - 'sample_extension_dllmain_win'
      libpaths: ['{DART_SDK}/bin']
      output_file: 'sample_extension.dll'
```

If you want to be more powerful then I can recommend you trying to use [ccompilers][ccompilers] instead of this.

[ccompile]: http://pub.dartlang.org/packages/ccompile
[ccompilers]: http://pub.dartlang.org/packages/ccompilers
[example_build_dart]: https://github.com/mezoni/ccompile/blob/master/example/example_build.dart
[example_use_sample_extension_dart]: https://github.com/mezoni/ccompile/blob/master/example/example_use_sample_extension.dart
[sample_extension_dart]: https://github.com/mezoni/ccompile/blob/master/example/sample_extension.dart
[sample_extension_yaml]: https://github.com/mezoni/ccompile/blob/master/example/sample_extension.yaml
