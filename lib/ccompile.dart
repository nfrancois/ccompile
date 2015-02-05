library ccompile.ccompile;

import 'dart:convert';
import 'dart:io';

import 'package:ccompilers/ccompilers.dart' as lib_ccompilers;
import 'package:ccompilers/ccompilers.dart';
import 'package:file_utils/file_utils.dart' as lib_file_utils;
import 'package:logging/logging.dart';
import 'package:map_parser/map_parser.dart';
import 'package:path/path.dart' as lib_path;
import 'package:system_info/system_info.dart';
import 'package:yaml/yaml.dart';

part 'src/cleaner.dart';
part 'src/compiler_settings.dart';
part 'src/dart_utils.dart';
part 'src/file_utils.dart';
part 'src/gnu_compiler.dart';
part 'src/gnu_linker.dart';
part 'src/linker_settings.dart';
part 'src/msvc_compiler.dart';
part 'src/msvc_linker.dart';
part 'src/project.dart';
part 'src/project_builder.dart';
part 'src/project_parser.dart';
part 'src/project_tool.dart';
part 'src/project_tool_result.dart';
part 'src/project_utils.dart';
part 'src/system_utils.dart';
