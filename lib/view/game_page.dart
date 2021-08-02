import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_button/animated_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//audio
import 'dart:async';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart' as ap;

import 'package:words/const/images_name.dart';
import 'package:words/const/screen_size.dart';
import 'package:words/model/score_model.dart';
import 'package:words/view/finish_page.dart';
import 'package:words/view/main_page.dart';
import 'package:words/const/game_setting.dart';

class GamePage extends StatefulWidget {
  final selectedPlayers;
  // final void Function(String path) onStop;

  GamePage({Key? key, @required this.selectedPlayers}) : super(key: key);
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List selectedPlayers = [];
  List<ScoreModel> scorelist = [];
  int current_round = 1;
  int current_palyer_index = 0;
  bool is_Started = false;
  bool is_paused = false;
  int challenger_index = 0;

  // audio record
  final _audioRecorder = Record();
  ap.AudioSource? audioSource;
  // audio play
  final _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  static const double _controlSize = 56;

  CountDownController _controller = CountDownController();

  @override
  void initState() {
    selectedPlayers = widget.selectedPlayers;
    for (var i = 0; i < selectedPlayers.length; i++) {
      ScoreModel thisScore = ScoreModel(
        userId: selectedPlayers[i].id,
        userName: selectedPlayers[i].name,
        score: 0,
      );

      scorelist.add(thisScore);
    }

    //audio play
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription =
        _audioPlayer.positionStream.listen((position) => setState(() {}));
    _durationChangedSubscription =
        _audioPlayer.durationStream.listen((duration) => setState(() {}));
    _init();
    //audio play

    super.initState();
  }

  // audio play
  Future<void> _init() async {
    await _audioPlayer.setAudioSource(audioSource!);
  }

  @override
  void dispose() {
    //audio record
    _audioRecorder.dispose();
    // audio play
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () => Get.offAll(() => MainPage()),
          tooltip: 'Close app',
          child: new Icon(Icons.home),
        ),
        body: (Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green, Colors.blue])),
          child: _gameBody(context, constraints),
        )),
      );
    });
  }

  Widget _gameBody(context, constraints) {
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          _headerSection(context),
          _bodySection(context, constraints),
        ],
      ),
    );
  }

  Widget _headerSection(context) {
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                height: hp(10),
                width: wp(10),
                child: Lottie.asset(
                    'assets/lotte/rounded-square-spin-loading.json'),
              ),
              Text(
                ' Round $current_round',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          selectedPlayers[current_palyer_index].name,
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _bodySection(context, constraints) {
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;
    if (is_Started) {
      return SafeArea(
        child: Center(
          child: Column(
            children: [
              CircularCountDownTimer(
                // Countdown duration in Seconds.
                duration: GameSetting.round_duration,

                // Countdown initial elapsed Duration in Seconds.
                initialDuration: 0,

                // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                controller: _controller,

                // Width of the Countdown Widget.
                width: wp(40),

                // Height of the Countdown Widget.
                height: hp(30),

                // Ring Color for Countdown Widget.
                ringColor: Colors.grey[300]!,

                // Ring Gradient for Countdown Widget.
                ringGradient: null,

                // Filling Color for Countdown Widget.
                fillColor: Colors.purpleAccent[100]!,

                // Filling Gradient for Countdown Widget.
                fillGradient: null,

                // Background Color for Countdown Widget.
                backgroundColor: Colors.purple[500],

                // Background Gradient for Countdown Widget.
                backgroundGradient: null,

                // Border Thickness of the Countdown Ring.
                strokeWidth: 20.0,

                // Begin and end contours with a flat edge and no extension.
                strokeCap: StrokeCap.round,

                // Text Style for Countdown Text.
                textStyle: TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),

                // Format for the Countdown Text.
                textFormat: CountdownTextFormat.S,

                // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                isReverse: true,

                // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                isReverseAnimation: false,

                // Handles visibility of the Countdown Text.
                isTimerTextShown: true,

                // Handles the timer start.
                autoStart: true,

                // This Callback will execute when the Countdown Starts.
                onStart: () {
                  // Here, do whatever you want
                  print('Countdown Started');
                  _startRecording();
                },

                // This Callback will execute when the Countdown Ends.
                onComplete: () {
                  // Here, do whatever you want
                  print('Countdown Ended');
                  _stop();
                  // onStop:
                  // (path) {
                  //   setState(() {
                  //     audioSource = ap.AudioSource.uri(Uri.parse(path));
                  //   });
                  // };
                  _markScoreModal(context, constraints);
                },
              ),
              Container(
                height: hp(15),
                width: wp(80),
                child: Lottie.asset('assets/lotte/speak-wave.json'),
              ),
              is_paused == false
                  ? AnimatedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            SizedBox(width: 3),
                            Icon(
                              Icons.star_outline,
                              color: Colors.white,
                              size: 45,
                            ),
                            Text(
                              'Challenge',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 3),
                          ],
                        ),
                      ),
                      onPressed: () {
                        _pause();
                      },
                      shadowDegree: ShadowDegree.light,
                      color: Colors.red,
                      width: 200,
                      height: 50,
                    )
                  : AnimatedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            SizedBox(width: 3),
                            Icon(
                              Icons.star_outline,
                              color: Colors.white,
                              size: 45,
                            ),
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 3),
                          ],
                        ),
                      ),
                      onPressed: () {
                        _resume();
                      },
                      shadowDegree: ShadowDegree.light,
                      color: Colors.green,
                      width: 200,
                      height: 50,
                    ),
            ],
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                height: hp(50),
                width: wp(80),
                child: Lottie.asset('assets/lotte/ready.json'),
              ),
              AnimatedButton(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(width: 3),
                      Icon(
                        Icons.star_outline,
                        color: Colors.white,
                        size: 45,
                      ),
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 3),
                    ],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    is_Started = true;
                    // audio record start
                  });
                },
                shadowDegree: ShadowDegree.light,
                color: Colors.green,
                width: 200,
                height: 50,
              ),
            ],
          ),
        ),
      );
    }
  }

  _markScoreModal(context, constraints) {
    final scoreTextControllor = TextEditingController();
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;
    showGeneralDialog(
      context: context,
      barrierDismissible:
          false, // should dialog be dismissed when tapped outside
      barrierLabel: "Modal", // label for barrier
      transitionDuration: Duration(
          milliseconds:
              500), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Scaffold(
          backgroundColor: Colors.white.withOpacity(0.90),
          body: Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [Colors.deepOrangeAccent, Colors.green]),
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        SizedBox(height: hp(3)),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                height: hp(10),
                                width: wp(10),
                                child: Lottie.asset(
                                    'assets/lotte/rounded-square-spin-loading.json'),
                              ),
                              Text(
                                ' Round $current_round',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: AnimatedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(width: 3),
                                  Text(
                                    'Fact',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                ],
                              ),
                            ),
                            onPressed: () {
                              Alert(
                                context: context,
                                type: AlertType.success,
                                title: "Fact",
                                desc: "New name of player/team is added.",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "COOL",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    width: 120,
                                    color: Colors.green,
                                  )
                                ],
                              ).show();
                            },
                            shadowDegree: ShadowDegree.light,
                            color: Colors.red,
                            width: 200,
                            height: 50,
                          ),
                        ),
                        SizedBox(height: hp(1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildControl(),
                            _buildSlider(context),
                          ],
                        ),
                        SizedBox(height: hp(3)),
                        Center(
                          child: Text(
                            "Enter the score of " +
                                selectedPlayers[current_palyer_index].name,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Overpass',
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        SizedBox(height: hp(1)),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: wp(50),
                                child: TextField(
                                  controller: scoreTextControllor,
                                  keyboardType: TextInputType.number,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    labelText: 'Enter Score',
                                    fillColor: Colors.white,
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              AnimatedButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        'Mark',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    int new_score =
                                        int.parse(scoreTextControllor.text);
                                    new_score = new_score +
                                        scorelist[current_palyer_index].score;
                                    ScoreModel newScore = ScoreModel(
                                      userId:
                                          selectedPlayers[current_palyer_index]
                                              .id,
                                      userName:
                                          selectedPlayers[current_palyer_index]
                                              .name,
                                      score: new_score,
                                    );
                                    scorelist[current_palyer_index] = newScore;
                                    scoreTextControllor.clear();
                                  });
                                },
                                shadowDegree: ShadowDegree.light,
                                color: Colors.green,
                                width: 80,
                                height: 60,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: hp(3)),
                        SizedBox(
                          width: wp(80),
                          height: hp(40),
                          child: Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Score',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  scorelist.length,
                                  (index) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(
                                        Center(
                                          child: Text(
                                            scorelist[index].userName,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            scorelist[index].score.toString(),
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).toList(),
                              ),
                            ),
                            color: Colors.blue,
                          ),
                        ),
                        Center(
                          child: AnimatedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(width: 3),
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                ],
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (current_round < GameSetting.max_round) {
                                  if (current_palyer_index <
                                      selectedPlayers.length - 1) {
                                    current_palyer_index++;
                                    is_Started = false;
                                    Navigator.pop(context);
                                  } else {
                                    current_round++;
                                    current_palyer_index = 0;
                                    is_Started = false;
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (current_palyer_index <
                                      selectedPlayers.length - 1) {
                                    current_palyer_index++;
                                    is_Started = false;
                                    Navigator.pop(context);
                                  } else {
                                    //end
                                    Get.to(
                                      () => FinishPage(
                                        scorelist: scorelist,
                                      ),
                                      transition: Transition.fade,
                                    );
                                    //Get.offAll(() => MainPage());
                                  }
                                }
                              });
                            },
                            shadowDegree: ShadowDegree.light,
                            color: Colors.purple,
                            width: 200,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//record
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    // widget.onStop(path!);

    audioSource = ap.AudioSource.uri(Uri.parse(path!));

    print(path);
  }

  Future<void> _pause() async {
    await _audioRecorder.pause();
    _controller.pause();

    setState(() => is_paused = true);
    //  List challenger_list = selectedPlayers;

    // Alert(
    //   context: context,
    //   type: AlertType.none,
    //   title: "Who is Challenger?",
    //   // desc: "Who is Challenger?",
    //   content: Column(
    //     children: <Widget>[
    //       for (int i = 0; i <= selectedPlayers.length; i++)
    //         ListTile(
    //           title: Text(
    //             'selectedPlayers[i].name',
    //             // style: Theme.of(context).textTheme.subtitle1.copyWith(color: i == 5 ? Colors.black38 : shrineBrown900),
    //           ),
    //           leading: Radio(
    //             value: i,
    //             groupValue: challenger_index,
    //             onChanged: (int? value) {
    //               setState(() {
    //                 print(value);
    //                 challenger_index = i;
    //               });
    //             },
    //           ),
    //         ),
    //     ],
    //   ),
    //   buttons: [
    //     DialogButton(
    //       child: Text(
    //         "Go",
    //         style: TextStyle(color: Colors.white, fontSize: 20),
    //       ),
    //       onPressed: () => Navigator.pop(context),
    //       width: 120,
    //       color: Colors.green,
    //     )
    //   ],
    // ).show();
  }

  Future<void> _resume() async {
    await _audioRecorder.resume();
    _controller.resume();

    setState(() => is_paused = false);
  }

//play
  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.playerState.playing) {
      icon = Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
              SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.playerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(context) {
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;

    final position = _audioPlayer.position;
    final duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    double width = wp(90) - _controlSize;

    return SizedBox(
      width: width,
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).accentColor,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }
}
