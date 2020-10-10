import 'package:flutter/material.dart';
import 'bottom.dart';
import 'box-game.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:flame/animation.dart' as animation; // imports the Animation class under animation.Animation
import 'package:flame/flame.dart'; // imports the Flame helper class
import 'package:flame/position.dart'; // imports the Position class

import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  MyGame game = MyGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 350,
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black,
                      width: 8
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.0, 2.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),

                  child: game.widget,
                ),
              ],
            ),
          )
      ),
    );
  }
}

class MyPedo extends StatefulWidget {
  @override
  _MyPedoState createState() => _MyPedoState();
}

class _MyPedoState extends State<MyPedo> {

  MyPedo pedo = MyPedo();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var timestamp;
  dynamic step;

  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'stopped', _steps = '?';




  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: ThemeData(
            accentColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(splashColor: Colors.white.withOpacity(0.25),
        )),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            firestore.collection('time_step').document("Sunghyun : " + DateTime.now().toString())
                .setData({'time':DateTime.now(), 'step':_steps});
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
        body: new Column(
          children: <Widget>[
            Divider(
              height: 80,
              thickness: 0,
            ),
            Text(
              'Steps taken:',
              style: TextStyle(fontSize: 30,color:Colors.white),

            ),
            Text(
              _steps,
              //(prevstep).toString(),
              style: TextStyle(fontSize: 60,color:Colors.white),
            ),
            Divider(
              height: 100,
              thickness: 0,
            ),
            Text(
              'Pedestrian status:',
              style: TextStyle(fontSize: 30,color:Colors.white),
            ),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'


                  ? Icons.accessibility_new
                  : Icons.error,
              size: 100,color:Colors.white,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 30,color:Colors.white)
                    : TextStyle(fontSize: 20, color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WalkerHolic_Sprite",
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.white,

      ),
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background-2.png"), fit: BoxFit.cover
          ),
        ),
        child:DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: TabBarView(
              //physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                MyHome(),
                MyPedo(),
                Container(child: Center(child: Container(
                  width: 350,
                  height: 530,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(50, 0, 0, 0),
                    borderRadius: BorderRadius.circular(12),
                ),),),)
                //Container(child: Center(child: Text('Additional'),),)
              ],
            ),
            bottomNavigationBar: Bottom(),
          ),
        )
      )
    );
  }

}