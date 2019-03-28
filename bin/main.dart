import 'package:crypto/crypto.dart';
import 'package:image/image.dart';


import 'dart:core';
import 'dart:io';

Future<int> main() async {

  var homePath = Platform.environment['HOMEPATH'];
  var homePathUri = Uri.directory(homePath);

  var onedriveDirectory;

  try {
    onedriveDirectory = await findOnedriveDirectory(homePathUri);
  } catch(ex) {
    print(ex);
    exitCode = 2;
  }

  if(onedriveDirectory is !Directory) {
    print("Missing Onedrive Directory");
    exitCode = 0;
  }

  var wallpaperDirectory;

  try {
    wallpaperDirectory = await findWallpaperDirectory(onedriveDirectory.uri);
  } catch (ex) {
    print(ex);
    exitCode = 2;
  }

  if(wallpaperDirectory is !Directory) {
    print("Missing Onedrive Directory");
    exitCode = 0;
  }

  var wallpaperFiles = await getAllImagesInWallpaperDirectory((wallpaperDirectory as FileSystemEntity).uri);

  for(var file in wallpaperFiles) {

    var image;
    var bytes = await (file as File).readAsBytes();

    try {
      image = decodeImage(bytes);
    } catch (ex) {
      print("Unable to load file ${filename(file.path)}");
      File.fromUri(file.uri).deleteSync();
      continue;
    }

    if(!is16by9(image)) {
      await file.delete();
      continue;
    }

    var disgest = sha256.convert(bytes);

    await new File(wallpaperDirectory.path + Platform.pathSeparator + disgest.toString() + ".jpg")
        .writeAsBytes(encodeJpg(image));

    await (file as File).delete();
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
  return image.width % 16 == 0 && image.height % 9 == 0 && image.width >= 1600 && image.height >= 900;
}

String filename(String path) => path.split(Platform.pathSeparator).last;
