import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final imageProvider = StateNotifierProvider<ImageRepository, AsyncValue<File?>>(
    (ref) => ImageRepository());

class ImageRepository extends StateNotifier<AsyncValue<File?>> {
  ImageRepository() : super(AsyncData(File('')));

  final String? _url =
      'https://www.kindacode.com/wp-content/uploads/2022/02/orange.jpeg';

  Future<void> downloadImage() async {
    state = const AsyncLoading();
    try {
      final response = await http.get(Uri.parse(_url!));
      File? imageFile = await getImage();
      await imageFile!.writeAsBytes(response.bodyBytes);
      if (response.statusCode == 200) {
        state = AsyncData(imageFile);
      } else {
        state = AsyncError(response.reasonPhrase!);
      }
    } on Exception catch (exception) {
      state = AsyncError(exception);
    }
  }

  Future<void> deleteImage() async {
    state = const AsyncLoading();
    try {
      File? imageFile = await getImage();
      await imageFile!.delete();

      state = AsyncData(File(''));
    } catch (e) {
      state = AsyncError(e);
    }
  }

  Future<File?> getImage() async {
    final imageName = path.basename(_url!);
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    final localPath = path.join(appDir.path, imageName);
    final imageFile = File(localPath);
    return imageFile;
  }

  getState() => state;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageDownloaded = ref.watch(imageProvider);
    AsyncValue<File?> imageState = ref.watch(imageProvider.notifier).getState();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hook Riverpod Task'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              imageDownloaded.hasValue && imageDownloaded.value!.path != ""
                  ? ElevatedButton(
                      onPressed: () {
                        ref.watch(imageProvider.notifier).deleteImage();
                      },
                      child: const Text('Delete Image'))
                  : ElevatedButton(
                      onPressed: () {
                        ref.watch(imageProvider.notifier).downloadImage();
                      },
                      child: const Text('Download Image')),
              const SizedBox(height: 25),
              imageState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
                data: (imageDownloaded) {
                  return imageDownloaded!.path.isNotEmpty
                      ? Image.file(imageDownloaded)
                      : Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
