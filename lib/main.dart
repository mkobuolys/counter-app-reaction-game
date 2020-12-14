import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:confetti/confetti.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

const int maxCount = 20;
const double defaultButtonX = 16.0;
const double defaultButtonY = 16.0;
const double defaultButtonScale = 1.0;
const IconData defaultButtonIcon = Icons.add;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: CounterPage(
        title: '#FlutterCounterChallenge2020',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({
    this.title,
  });

  final String title;

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final Random random = Random();

  int _counter = 0;
  double _x = defaultButtonX;
  double _y = defaultButtonY;
  double _buttonScale = defaultButtonScale;
  IconData _icon = defaultButtonIcon;

  void _onPressed() {
    setState(() {
      _counter < maxCount ? _incrementCounter() : _reset();
    });
  }

  void _incrementCounter() {
    if (_counter == 0) {
      _start();
    }

    _recalculateButtonProperties();

    if (++_counter == maxCount) {
      _stop();
    }
  }

  void _start() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  void _stop() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    _icon = Icons.refresh;
    _resetButtonProperties();
    _confettiController.play();
  }

  void _reset() {
    _counter = 0;
    _icon = defaultButtonIcon;
    _resetButtonProperties();
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  void _resetButtonProperties() {
    _x = defaultButtonX;
    _y = defaultButtonY;
    _buttonScale = defaultButtonScale;
  }

  void _recalculateButtonProperties() {
    _x = 16 + random.nextDouble() * (MediaQuery.of(context).size.width - 88);
    _y = 16 + random.nextDouble() * (MediaQuery.of(context).size.height - 216);
    _buttonScale = 0.4 + 0.6 * (maxCount - _counter) / maxCount;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (_, snapshot) => Text(
                      StopWatchTimer.getDisplayTime(snapshot.data),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  if (_counter == 0)
                    Text(
                      'I am ready when you are...',
                    ),
                  if (_counter == maxCount)
                    Text(
                      'One more time?',
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              shouldLoop: false,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
          Positioned(
            right: _x,
            bottom: _y,
            child: SizedBox(
              height: 56.0 * _buttonScale,
              width: 56.0 * _buttonScale,
              child: FloatingActionButton(
                elevation: 12,
                onPressed: _onPressed,
                tooltip: 'Increment',
                child: Icon(
                  _icon,
                  size: 24.0 * _buttonScale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
