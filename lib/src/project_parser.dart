part of ccompile;

class ProjectParser {
  MezoniParser _parser;

  bool hasErrors = false;

  List<String> errors = [];

  Project parse(Map map) {
    if(map == null || map is! Map) {
      throw new ArgumentError('map: $map');
    }

    errors = [];
    hasErrors = false;
    var project = new Project();
    _parser = new MezoniParser(_getFormat());
    _parser.parse(map, project);
    if(_parser.errors.length > 0) {
      hasErrors = true;
      _parser.errors.forEach((error) {
        var msg = 'Invalid section ${error} in data.';
        errors.add(msg);
      });

      return null;
    }

    return project;
  }

  Map<String, ParserCallback> _getFormat() {
    Map<String, ParserCallback> format =
      {'"bits"': bits,
       '[clean]': clean,
       '[clean]:"*"': list_item,
       '{compiler}': compiler,
       '{compiler}:[arguments]': compiler_arguments,
       '{compiler}:[arguments]:"*"': list_item,
       '{compiler}:{defines}': compiler_defines,
       '{compiler}:{defines}:"*"': list_item,
       '{compiler}:"executable"': compiler_executable,
       '{compiler}:[includes]': compiler_includes,
       '{compiler}:[includes]:"*"': list_item,
       '{compiler}:[input_files]': compiler_input_files,
       '{compiler}:[input_files]:"*"': list_item,
       '{linker}': linker,
       '{linker}:[arguments]': linker_arguments,
       '{linker}:[arguments]:"*"': list_item,
       '{linker}:[input_files]': linker_input_files,
       '{linker}:[input_files]:"*"': list_item,
       '{linker}:[libpaths]': linker_libpaths,
       '{linker}:[libpaths]:"*"': list_item,
       '{linker}:"output_file"': linker_output_file,
       '{platforms}': platforms,
       '{platforms}:{*}': platform,

       '{platforms}:{*}:"bits"': bits,
       '{platforms}:{*}:[clean]': clean,
       '{platforms}:{*}:[clean]:"*"': list_item,
       '{platforms}:{*}:{compiler}': compiler,
       '{platforms}:{*}:{compiler}:[arguments]': compiler_arguments,
       '{platforms}:{*}:{compiler}:[arguments]:"*"': list_item,
       '{platforms}:{*}:{compiler}:{defines}': compiler_defines,
       '{platforms}:{*}:{compiler}:{defines}:"*"': map_item,
       '{platforms}:{*}:{compiler}:"executable"': compiler_executable,
       '{platforms}:{*}:{compiler}:[includes]': compiler_includes,
       '{platforms}:{*}:{compiler}:[includes]:"*"': list_item,
       '{platforms}:{*}:{compiler}:[input_files]': compiler_input_files,
       '{platforms}:{*}:{compiler}:[input_files]:"*"': list_item,
       '{platforms}:{*}:{linker}': linker,
       '{platforms}:{*}:{linker}:[arguments]': linker_arguments,
       '{platforms}:{*}:{linker}:[arguments]:"*"': list_item,
       '{platforms}:{*}:{linker}:[input_files]': linker_input_files,
       '{platforms}:{*}:{linker}:[input_files]:"*"': list_item,
       '{platforms}:{*}:{linker}:[libpaths]': linker_libpaths,
       '{platforms}:{*}:{linker}:[libpaths]:"*"': list_item,
       '{platforms}:{*}:{linker}:"output_file"': linker_output_file,
       };

    return format;
  }

  int bits(String key, dynamic value, Project parent) {
    var error = false;
    if(value != null) {
      try {
        parent.bits = int.parse(value);
      } catch(e) {
        error = true;
      }
    }

    if(!error && parent.bits != null) {
      var validValues = [0, 32, 64];
      if(!validValues.any((e) => e == parent.bits)) {
        error = true;
      }
    }

    if(error) {
      _errorIllegalValue(key, value, ['0', '32', '64']);
    }

    return parent.bits;
  }

  List clean(String key, dynamic value, Project parent) {
    if(parent.clean == null) {
      parent.clean = [];
    }

    return parent.clean;
  }

  CompilerSettings compiler(String key, dynamic value, Project parent) {
    return parent.compilerSettings;
  }

  List compiler_arguments(String key, dynamic value, CompilerSettings parent) {
    return parent.arguments;
  }

  List compiler_includes(String key, dynamic value, CompilerSettings parent) {
    return parent.includes;
  }

  List compiler_input_files(String key, dynamic value, CompilerSettings parent) {
    return parent.inputFiles;
  }

  Map compiler_defines(String key, dynamic value, CompilerSettings parent) {
    return parent.defines;
  }

  dynamic compiler_executable(String key, dynamic value, CompilerSettings parent) {
    parent.executable = value;
    return value;
  }

  LinkerSettings linker(String key, dynamic value, Project parent) {
    return parent.linkerSettings;
  }

  List linker_input_files(String key, dynamic value, LinkerSettings parent) {
    return parent.inputFiles;
  }

  List linker_arguments(String key, dynamic value, LinkerSettings parent) {
    return parent.arguments;
  }

  dynamic linker_output_file(String key, dynamic value, LinkerSettings parent) {
    parent.outputFile = value;
    return value;
  }

  List linker_libpaths(String key, dynamic value, LinkerSettings parent) {
    return parent.libpaths;
  }

  Project platforms(String key, dynamic value, Project parent) {
    return parent;
  }

  Project platform(String key, dynamic value, Project parent) {
    if(key != Platform.operatingSystem) {
      return new Project();
    }

    return parent;
  }

  dynamic list_item(String key, dynamic value, List parent) {
    parent.add(value);
    return value;
  }

  dynamic map_item(String key, dynamic value, Map parent) {
    parent[key] = value;
    return value;
  }

  void _errorIllegalValue(String name, value, List<String> validValues) {
    var message = 'Project parser error: Illegal "$name" value "$value"';
    if(validValues.length > 0) {
      message = '$message. Valid values are ${validValues.join(', ')}';
    }

    throw(message);
  }
}
