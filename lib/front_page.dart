import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fourle/game_page.dart';
import 'package:fourle/main.dart';
import 'package:fourle/util.dart';
import 'package:google_fonts/google_fonts.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({Key? key, this.initialSeed}) : super(key: key);
  final int? initialSeed;

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  String seed = Random().nextInt(10000).toString();

  TextEditingController seedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    seedController.text = widget.initialSeed?.toString() ?? seed;
  }

  @override
  void dispose() {
    seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: DefaultTextStyle.merge(
          style: GoogleFonts.kosugi(),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 72),
                      child: Text("四字熟語le",
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("シード値(空欄ならランダムに開始)"),
                    ),
                    TextFormField(
                      controller: seedController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("簡単(熟語として成立していなくてもOK)"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => GamePage(
                                        seed:
                                            int.tryParse(seedController.text) ??
                                                Random().nextInt(10000),
                                        isEasy: true,
                                      )));
                        },
                        child: const Text("START EASY")),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("通常(熟語のみ受け付ける)"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => GamePage(
                                        seed:
                                            int.tryParse(seedController.text) ??
                                                Random().nextInt(10000),
                                        isEasy: false,
                                      )));
                        },
                        child: const Text("START NORMAL")),
                    SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          openUrl("https://www.powerlanguage.co.uk/wordle/");
                        },
                        child: const Text("wordle")),
                    ElevatedButton(
                        onPressed: () {
                          openUrl("https://twitter.com/Fastriver_org");
                        },
                        child: const Text("2022 fastriver_org(fastriver.dev)")),
                    ElevatedButton(
                        onPressed: () {
                          showLicensePage(context: context);
                        },
                        child: const Text("license")),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
