import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/utils.dart';
import '../controller/status_controller.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = '/confirmStatusScreen';
  final File file;

  const ConfirmStatusScreen({
    super.key,
    required this.file,
  });

  void addStatus(
    WidgetRef ref,
    BuildContext context,
  ) {
    ref.read(statusControllerProvider).addStatus(
          file,
          context,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addStatus(
          ref,
          context,
        ),
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
