import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'baseUrl': Platform.environment['APP_BASE_URL'],
    'credentials': Platform.environment['APP_CREDENTIALS'],
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
}