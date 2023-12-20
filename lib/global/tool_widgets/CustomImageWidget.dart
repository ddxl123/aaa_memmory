import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';

const String unknownUrl = "https://img2.baidu.com/it/u=824807255,173743980&fm=253&fmt=auto&app=120&f=JPEG?w=200&h=200";

/// 先加载本地，如果本地加载失败，则获取云端，若云端获取失败，则 errorWidget
///
/// [cloudPath] 需要相对路径。会自动转换成 [FilePathWrapper.toAvailablePath]
///
/// [localPath] 需要绝对路径。
class LocalThenCloudImageWidget extends StatelessWidget {
  const LocalThenCloudImageWidget({
    super.key,
    required this.size,
    required this.localPath,
    required this.cloudPath,
  });

  final Size size;
  final String? localPath;
  final String? cloudPath;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(localPath ?? unknownUrl),
      width: size.width,
      height: size.height,
      errorBuilder: (ctx, e, st) {
        return CachedNetworkImage(
          width: size.width,
          height: size.height,
          imageUrl: FilePathWrapper.toAvailablePath(cloudPath: cloudPath) ?? unknownUrl,
          placeholder: (ctx, url) {
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.black12,
              child: Center(child: Text("无图片")),
            );
          },
          errorWidget: (ctx, url, e) {
            logger.outError(error: e, stackTrace: st);
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.black12,
              child: Center(child: Text("加载异常！")),
            );
          },
        );
      },
    );
  }
}

/// 先获取云端，如果云端获取失败，则加载本地，若本地加载失败，则 errorWidget
///
/// [cloudPath] 需要相对路径。会自动转换成 [FilePathWrapper.toAvailablePath]
///
/// [localPath] 需要绝对路径。
class CloudThenLocalImageWidget extends StatelessWidget {
  const CloudThenLocalImageWidget({
    super.key,
    required this.size,
    required this.localPath,
    required this.cloudPath,
  });

  final Size size;
  final String? localPath;
  final String? cloudPath;

  @override
  Widget build(BuildContext context) {
    print(cloudPath);
    return CachedNetworkImage(
      width: size.width,
      height: size.height,
      imageUrl: FilePathWrapper.toAvailablePath(cloudPath: cloudPath) ?? unknownUrl,
      placeholder: (ctx, url) {
        return Container(
          width: size.width,
          height: size.height,
          color: Colors.black12,
          child: Center(child: Text("无图片")),
        );
      },
      errorWidget: (ctx, url, e) {
        return Image.file(
          File(localPath ?? unknownUrl),
          width: size.width,
          height: size.height,
          errorBuilder: (ctx, e, st) {
            logger.outError(error: e, stackTrace: st);
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.black12,
              child: Center(child: Text("加载异常！")),
            );
          },
        );
      },
    );
  }
}

/// 先加载本地，如果本地加载失败，则获取云端，若云端获取失败，则 errorWidget
///
/// [cloudPath] 会自动转换成 [FilePathWrapper.toAvailablePath]
class ForceCloudImageWidget extends StatelessWidget {
  const ForceCloudImageWidget({
    super.key,
    required this.size,
    required this.cloudPath,
  });

  final Size? size;
  final String? cloudPath;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: size?.width,
      height: size?.height,
      imageUrl: FilePathWrapper.toAvailablePath(cloudPath: cloudPath) ?? unknownUrl,
      errorWidget: (ctx, url, e) {
        logger.outError(error: e);
        return Container(
          width: size?.width,
          height: size?.height,
          color: Colors.black12,
          child: Center(child: Text("加载异常！")),
        );
      },
    );
  }
}
