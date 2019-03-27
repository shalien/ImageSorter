import 'dart:io' show Platform, File, Directory;
import 'dart:core';
import 'package:image/image.dart';

void main() {

  Map<String, String> envVars = Platform.environment;

  final String HOME_PATH = envVars['HOMEPATH'];

  print(HOME_PATH);

}
