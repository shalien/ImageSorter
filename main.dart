import 'dart:core';
import 'dart:io';
import 'package:image/image.dart';

Future<int> main() async {

  var homePath = Platform.environment['HOMEPATH'];
  var homePathUri = Uri.directory(homePath);

  var onedriveDirectory;

  try {
    onedriveDirectory = await findOnedriveDirectory(homePathUri);
  } catch(ex) {
    print(ex);
    return 2;
  }

  if(onedriveDirectory is !Directory) {
    print("Missing Onedrive Directory");
    return 0;
  }

  var wallpaperDirectory;

  try {
    wallpaperDirectory = await findWallpaperDirectory(onedriveDirectory.uri);
  } catch (ex) {
    print(ex);
    return 2;
  }

  if(wallpaperDirectory is !Directory) {
    print("Missing Onedrive Directory");
    return 0;
  }

  var wallpaperFiles = await getAllImagesInWallpaperDirectory((wallpaperDirectory as FileSystemEntity).uri);

  for(var file in wallpaperFiles) {

    var image;

    try {
      image = decodeImage(File.fromUri(file.uri).readAsBytesSync());
    } catch (ex) {
      print("Unable to load file ${filename(file.path)}");
      File.fromUri(file.uri).deleteSync();
      continue;
    }

    print("${filename(file.path)} ${is16by9(image)}");
  }

}


Future<FileSystemEntity> findOnedriveDirectory(Uri uri) async {

  var onedriveDirectory = await Directory.fromUri(uri)
      .list()
      .firstWhere((fse) =>
  fse.path
      .split(Platform.pathSeparator)
      .last
      .toLowerCase() == 'onedrive');

  return onedriveDirectory;

}

Future<FileSystemEntity> findWallpaperDirectory(Uri uri) async {

  var wallpaperDirectory = await Directory.fromUri(uri)
      .list()
      .firstWhere((fse) =>
  fse.path
      .split(Platform.pathSeparator)
      .last
      .toLowerCase() == 'wallpaper');

  return wallpaperDirectory;

}

Future<List<FileSystemEntity>> getAllImagesInWallpaperDirectory(Uri uri) async {

  var wallpaperList = await Directory.fromUri(uri)
      .list()
      .where((fse) => fse.statSync().type == FileSystemEntityType.file)
      .toList();

  return wallpaperList;
}


bool is16by9(Image image) {
  return image.width % 16 == 0 && image.height % 9 == 0;
}

String filename(String path) => path.split(Platform.pathSeparator).last;
