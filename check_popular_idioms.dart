import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final File idiomsFile = File("./data/idioms.txt");
  final List<String> idioms = idiomsFile.readAsLinesSync();

  final File popularFile = File("./data/idioms_popular.txt");
  final List<String> popular = popularFile.readAsLinesSync();

  final processed = <String>[];

  popular.forEach((element) {
    if (idioms.contains(element)) {
      processed.add(element);
    } else {
      print(element);
    }
  });

  final File outputFile = File("./data/out_popular.txt");
  final outputSink = outputFile.openWrite();
  for (int i = 0; i < processed.length; i++) {
    outputSink.writeln(processed[i]);
  }
  outputSink.close();
}
