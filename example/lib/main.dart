import 'package:blur_matrix/blur_matrix.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Blur Matrix Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<List<Color>> colors;

  @override
  void initState() {
    // colors = [
    //   [Colors.red,            Colors.blue,             Colors.yellowAccent],
    //   [Colors.green,          Colors.black,            Colors.cyanAccent],
    //   [Colors.yellowAccent,   Colors.deepPurpleAccent, Colors.white],
    //   [Colors.red,            Colors.blue,             Colors.yellowAccent],
    // ];
    colors = [
      [Colors.green.withOpacity(0.6), Colors.white.withOpacity(0.8)],
      [Colors.black.withOpacity(0.8), Colors.blue.withOpacity(0.6)],
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/lago-blu-cervino.webp', fit: BoxFit.fill),
          ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: BlurMatrixAnimate(
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}
