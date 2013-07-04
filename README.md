#CCompile is a Tools for compiling C/C++ Dart language native extensions.

This tools is a library written in Dart programming language.
It is intended to compile C/C++ source files from Dart scripts.

To test how it works run **example/example_build.dart**.
This will compile simple project called **sample_extension.yaml**.

This project is a dart native C/C++ extension project.

After compile run **example/example_use_sample_extension.dart**.
This is a script that import **sample_extension.dart** that have a native function calls to Dart VM.
And **sample_extension.dart** uses compiled by **ccompile tools** binary libraries to work.

If it works then your project will be succesful compiled.

You can compile projects stored in **json** and **yaml** formats.
Also you can create project via dart language class and compile it.

**Requirements.**

- Windows - MS Visual C++ Compiler installed.
- Linux - GNU C++ Compiler installed (g++).

**Mac OS is not tested at this moment.**