import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final imageProvider =
    StateNotifierProvider<WebImage, String>((_) => WebImage());

class WebImage extends StateNotifier<String> {
  WebImage() : super('');

  void downloadImage() => state = 'http://picsum.photos/seed/picsum/200/300';
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
    final image = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hook Riverpod Task'),
      ),
      body: Center(
        child: Image.network(image, errorBuilder: (context, error, stackTrace) {
          return const Text('Download the image from the web.');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(imageProvider.notifier).downloadImage(),
        child: const Icon(Icons.download),
      ),
    );
  }
}
