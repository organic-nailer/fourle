import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fourle/front_page.dart';
import 'package:fourle/game_page.dart';
import 'package:fourle/util.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage(
      {Key? key,
      required this.win,
      required this.row,
      required this.cells,
      required this.answer,
      required this.seed})
      : super(key: key);
  final bool win;
  final int row;
  final List<List<CellData?>> cells;
  final String answer;
  final int seed;

  @override
  _GameOverPageState createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: DefaultTextStyle(
          style: GoogleFonts.kosugi(),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("四字熟語le(${widget.seed})",
                        style: TextStyle(fontSize: 30, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("正解: ${widget.answer}",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade200)),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        final tiles = createCellStr(widget.cells);
                        print(Uri.encodeQueryComponent(tiles));
                        final link =
                            "https://twitter.com/intent/tweet?text=%E5%9B%9B%E5%AD%97%E7%86%9F%E8%AA%9Ele(${widget.seed})%0A%0A${Uri.encodeComponent(tiles)}%0A%0Ahttps%3A%2F%2Ffourle.fastriver.dev%2F%3Fs%3D${widget.seed}";
                        openUrl(link);
                      },
                      child: Text("共有")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => GamePage(
                                  seed: Random().nextInt(10000),
                                  isEasy: true,
                                )));
                      },
                      child: Text("もう一度遊ぶ")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(createCellStr(widget.cells),
                        style: TextStyle(fontSize: 25)),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const FrontPage()));
                      },
                      child: Text("トップへ"))
                ],
              ),
            ),
          ),
        ));
  }

  String createCellStr(List<List<CellData?>> cells) {
    final StringBuffer sb = StringBuffer();
    for (final List<CellData?> row in cells) {
      for (final CellData? cell in row) {
        if (cell == null) {
          return sb.toString();
        } else {
          sb.write(state2Cell(cell.state));
        }
      }
      sb.write("\n");
    }
    return sb.toString();
  }

  String state2Cell(CellState state) {
    switch (state) {
      case CellState.correct:
        return "🟩";
      case CellState.include:
        return "🟨";
      case CellState.wrong:
        return "⬛";
      default:
        return "";
    }
  }
}
