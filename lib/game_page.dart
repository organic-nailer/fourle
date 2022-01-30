import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fourle/data.dart';
import 'package:fourle/game_over_page.dart';
import 'package:google_fonts/google_fonts.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.seed, required this.isEasy})
      : super(key: key);
  final int seed;
  final bool isEasy;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late String answerIdiom;

  int currentRow = 0;
  int currentColumn = 0;

  final List<List<CellData?>> cells =
      List.generate(10, (_) => List.generate(4, (_) => null));

  final kanjiInfoMap = <String, CellState>{};

  final TextEditingController searchController = TextEditingController();
  final List<String> searchTargets = [];

  List<String> keyboardCards = [];

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast()..init(context);
    answerIdiom = IdiomDataStore.getRandomIdiom(widget.seed);
    keyboardCards = IdiomDataStore.getKanjis(searchTargets);
    print("(${widget.seed})");
    print("isEasy: ${widget.isEasy}");
  }

  void onInput(String kanji) {
    if (currentColumn >= 4) return;

    setState(() {
      cells[currentRow][currentColumn] = CellData(kanji);
      currentColumn++;
    });
  }

  void onBackspace() {
    if (currentColumn == 0) return;
    setState(() {
      currentColumn--;
      cells[currentRow][currentColumn] = null;
    });
  }

  void onEnter() {
    if (currentColumn < 4) return;
    if (!widget.isEasy) {
      final input = cells[currentRow].map((cell) => cell!.kanji).join();
      if (!IdiomDataStore.isInIdioms(input)) {
        fToast.showToast(
          child: Text("存在しない単語です"),
          toastDuration: Duration(seconds: 2),
        );
        return;
      }
    }
    bool isCorrect = true;
    for (int c = 0; c < 4; c++) {
      final cell = cells[currentRow][c]!;
      if (cell.kanji == answerIdiom[c]) {
        cell.state = CellState.correct;
        kanjiInfoMap[cell.kanji] = cell.state;
      } else if (answerIdiom.contains(cell.kanji)) {
        cell.state = CellState.include;
        if (kanjiInfoMap[cell.kanji] != CellState.correct) {
          kanjiInfoMap[cell.kanji] = cell.state;
        }
        isCorrect = false;
      } else {
        cell.state = CellState.wrong;
        kanjiInfoMap[cell.kanji] = cell.state;
        isCorrect = false;
      }
    }
    setState(() {});
    if (isCorrect) {
      // 勝ち
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => GameOverPage(
              win: true,
              row: currentRow,
              cells: cells,
              answer: answerIdiom,
              seed: widget.seed)));
      return;
    }
    currentRow++;
    currentColumn = 0;
    if (currentRow == cells.length) {
      // 負け
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => GameOverPage(
              win: false,
              row: currentRow,
              cells: cells,
              answer: answerIdiom,
              seed: widget.seed)));
      return;
    }
  }

  void onSearch() {
    final s = searchController.text;
    if (s.isEmpty) {
      searchTargets.clear();
      keyboardCards = IdiomDataStore.getKanjis(searchTargets);
      setState(() {});
      return;
    }
    searchTargets.clear();
    searchTargets.addAll(s.characters.map((c) => c.toString()));
    keyboardCards = IdiomDataStore.getKanjis(searchTargets);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final keyboardArea = GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: keyboardCards.length,
        itemBuilder: (context, index) {
          return keyboardCard(keyboardCards[index]);
        });
    final cellsArea = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cells.map((row) => InputRow(row)).toList());
    final searchArea = Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: onEnter,
            child: Text("決定"),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: searchController,
            decoration: const InputDecoration(hintText: "文字を検索"),
            onChanged: (_) {
              onSearch();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: onBackspace, child: Text("削除")),
        )
      ],
    );
    return Scaffold(
      body: DefaultTextStyle(
        style: GoogleFonts.kosugi(),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("四字熟語le(${widget.seed})",
                    style: const TextStyle(fontSize: 30, color: Colors.white)),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.biggest.width;
                  final height = constraints.biggest.height;
                  if (width >= 900) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 500, child: keyboardArea),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 370,
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: cellsArea,
                                  primary: false,
                                ),
                              ),
                              searchArea
                            ],
                          ),
                        )
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: cellsArea,
                          primary: false,
                        ),
                      ),
                      SizedBox(height: height * 0.3, child: keyboardArea),
                      searchArea,
                    ],
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget keyboardCard(String kanji) {
    final info = kanjiInfoMap[kanji];
    return Card(
      color: selectColor(info) ?? Colors.white.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          onInput(kanji);
        },
        child: Center(
            child: Text(
          kanji,
          style: TextStyle(fontSize: 15, color: Colors.white),
        )),
      ),
    );
  }

  Color? selectColor(CellState? info) {
    switch (info) {
      case CellState.correct:
        return wordleGreen;
      case CellState.include:
        return wordleYellow;
      case CellState.wrong:
        return wordleDark;
      case CellState.pending:
        return wordleDark;
      default:
        return null;
    }
  }

  Color wordleGrey = Color(0xFF3A3A3C);
  Color wordleGreen = Color(0xFF538D4E);
  Color wordleYellow = Color(0xFFB59F3B);
  Color wordleDark = Color(0xFF3A3A3C);

  Widget InputRow(List<CellData?> words) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: words.map((e) => InputSquare(e)).toList());
  }

  Widget InputSquare(CellData? cellData) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selectColor(cellData?.state) ?? wordleGrey,
            width: 2,
          ),
        ),
        color: selectColor(cellData?.state) ?? Colors.transparent,
        child: Center(
          child: Text(
            cellData?.kanji ?? "",
            style: const TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class CellData {
  final String kanji;
  CellState state;
  CellData(this.kanji, {this.state = CellState.pending});
}

enum CellState { pending, correct, include, wrong }
