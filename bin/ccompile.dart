library ccompile_tool;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:async/async.dart';
import 'package:ccompile/ccompile.dart';

main() {
  new CcompileTool()
  .run()
  .then((result) {
    exit(result);
  });
}

class CcompileTool {
  bool clean = true;

  bool compile = true;

  bool link = true;

  String format;

  String projectArgument;

  String projectDirectory;

  String projectFileName;

  String projectFullPath;

  ArgParser _parser;

  Async<int> run() {
    return new Async(() {
      var current = Async.current;
      if(_parse()) {
        if(_prepare()) {
          _buildAsync()
          .then((result) {
            current.result = result;
          });
        }
      }

      return -1;
    });
  }

  bool _parse() {
    _parser = new ArgParser();
    _parser.addFlag('compile', abbr: 'c', defaultsTo: true,
      help: 'Compile project');
    _parser.addFlag('clean', abbr: 'n', defaultsTo: true, help: 'Clean project');
    _parser.addFlag('link', abbr: 'l', defaultsTo: true, help: 'Link project');
    _parser.addOption('format', abbr: 'f', allowed: ['json', 'yaml'],
      help: 'Project file format. Specify format other than project filename extension',
      allowedHelp: {
        'json': 'The project format is JSON',
        'yaml': 'The project format is YAML',
      });

    var options = new Options();
    if(options.arguments.length == 0) {
      _printUsage();
      return false;
    }

    var arguments = options.arguments;
    projectArgument = arguments[0];
    arguments.removeRange(0, 1);
    var argResults;
    try {
      argResults = _parser.parse(arguments);
    } on FormatException catch (fe) {
      SystemUtils.writeStderr(fe.message);
      _printUsage();
      return false;
    } catch(e) {
      throw(e);
    }

    if(argResults.rest.length != 0) {
      SystemUtils.writeStderr('Illegal arguments:');
      argResults.rest.forEach((arg) => SystemUtils.writeStderr(arg));
      _printUsage();
      return false;
    }

    clean = argResults['clean'];
    compile = argResults['compile'];
    link = argResults['link'];
    format = argResults['format'];
    return true;
  }

  bool _prepare() {
    projectDirectory = _getDirectoryPath(projectArgument);
    if(projectDirectory == null) {
      SystemUtils.writeStderr('Project file "$projectArgument" not found.');
      return false;
    }

    projectFileName = new Path(projectArgument).filename;
    projectFullPath = new Path(projectDirectory).append(projectFileName)
      .toNativePath();
    return true;
  }

  Async<int> _buildAsync() {
    return new Async<int>(() {
      Async<int> current = Async.current;
      var builder = new ProjectBuilder();
      builder.loadProject(projectFullPath, format)
      .then((project) {
        builder.customBuild(project, projectDirectory, compile, link, clean)
        .then((ProcessResult result) {
          if(result.exitCode != 0) {
            SystemUtils.writeStdout(result.stdout);
            SystemUtils.writeStderr(result.stderr);
            current.result = -1;
          } else {
            current.result = 0;
          }
        });
      });
    });
  }

  String _getDirectoryPath(String filename) {
    var path = new Path(filename);
    if(!path.isAbsolute) {
      var curDir = Directory.current;
      var curDirPath = new Path(curDir.path);
      path = curDirPath.join(path);
      filename = path.toNativePath();
    }

    var file = new File(filename);
    if(!file.existsSync()) {
      return  null;
    }

    return file.directory.path;
  }

  String _printUsage() {
    SystemUtils.writeStdout('');
    SystemUtils.writeStdout('Usage: ccompile.dart project [options]');
    SystemUtils.writeStdout('Options:');
    SystemUtils.writeStdout(_parser.getUsage());
  }
}
