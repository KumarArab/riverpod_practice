import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const names = [
  'Alice',
  'Bob',
  'Charlie',
  'David',
  'Eve',
  'Fred',
  'Ginny',
  'Harriet',
  'Illeana',
  'Josep',
  'Kincaid',
  'Larry'
];

final rangeProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (int? i) {
    if (i == null) {
      return 0;
    } else if (i > names.length - 1) {
      return names.length - 1;
    } else {
      return i + 1;
    }
  });
});

// final namesProvider = StreamProvider((ref) {
//   return ref
//       .watch(rangeProvider.stream)
//       .map((event) => names.getRange(0, event));
// });

class StreamProviderExample extends ConsumerWidget {
  const StreamProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final range =;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Streamprovider"),
      ),
      body: ref.watch(rangeProvider).when(
            data: (data) => ListView.builder(
              itemCount: min(names.getRange(0, data).length, names.length),
              itemBuilder: (context, index) => ListTile(
                title: Text(names.elementAt(index)),
              ),
            ),
            error: (_, __) => const Text("End of the List"),
            loading: () => const CircularProgressIndicator(),
          ),
    );
  }
}
