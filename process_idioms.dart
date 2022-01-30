import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final File idiomsFile = File("./data/idioms.txt");
  final List<String> idioms = idiomsFile.readAsLinesSync();
  final kanjiMap = Map<String, int>();
  for (String idiom in idioms) {
    for (int i = 0; i < idiom.length; i++) {
      final String kanji = idiom[i];
      kanjiMap[kanji] = kanjiMap[kanji] == null ? 1 : kanjiMap[kanji]! + 1;
    }
  }

  // var entries = kanjiMap.entries.toList();
  // entries.sort((a, b) => b.value.compareTo(a.value));

  // var limited = entries.take(100);

  // var limitedMap = Map.fromEntries(limited);

  // for(int i = 1; i < 100; i++) {
  //   var limitedMap = kanjiMap..removeWhere((key, value) => value < i);

  //   List<String> result = [];
  //   for (String idiom in idioms) {
  //     if(idiom.split("").every((k) => limitedMap.containsKey(k))) {
  //       result.add(idiom);
  //     }
  //   }

  //   print("$i: ${limitedMap.length}words, ${result.length} ${result.length / limitedMap.length}");
  // }

  // for(var d in entries) {
  //   if(d.value >= 10) {
  //     print("${d.key} ${d.value}");
  //   }
  // }

  //var limitedMap = kanjiMap..removeWhere((key, value) => value < 11);
  var limitedMap = kanjiMap..removeWhere((key, value) => value < 1);

  List<String> result = [];
  for (String idiom in idioms) {
    if (idiom.split("").every((k) => limitedMap.containsKey(k))) {
      result.add(idiom);
    }
  }

  // final File outputFile = File("./data/out_idioms.txt");
  // final outputSink = outputFile.openWrite();
  // for (int i = 0; i < result.length; i++) {
  //   outputSink.writeln(result[i]);
  // }
  // outputSink.close();

  final File outputKFile = File("./data/out_kanjis_all.txt");
  final outputKSink = outputKFile.openWrite();
  final entries = limitedMap.entries.toList();
  entries.sort((a, b) => b.value.compareTo(a.value));
  for (int i = 0; i < entries.length; i++) {
    outputKSink.writeln(entries[i].key);
  }
  outputKSink.close();
}

class IdiomData {
  final String idiom;
  final int strokes;
  final double center;
  const IdiomData(this.idiom, this.strokes, this.center);

  String toCSV() => "$idiom, $strokes, ${center.toStringAsFixed(4)}";
}
