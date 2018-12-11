import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/Forecast.dart';
import 'package:weather_app/ForecastPage.dart';
import 'package:weather_app/WeatherPainter.dart';
import 'package:weather_app/icons.dart';

import 'api.dart';

void main() => runApp(MyApp());

enum DialogAction {
  disagree,
  agree,
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WeatherApp',
      theme: new ThemeData(accentColor: Colors.white),
      home: new WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp>
    with SingleTickerProviderStateMixin {
  Api api = Api();
  Map<String, dynamic> _weather;
  Map<String, dynamic> _forecast;
  double circlesWidth = 65.0;
  Animation<double> animation;
  AnimationController controller;
  WeatherIcons weatherIcons = new WeatherIcons();
  String error;

  @override
  void initState() {
    super.initState();
    weatherIcons.init().then((value) => start());
    controller = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    animation = Tween(begin: 55.0, end: 85.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
  }

  void start() async {
    Position position;
    try {
      position = await Geolocator().getCurrentPosition();
    } catch (e) {
      await new Future.delayed(const Duration(seconds: 1));
      setState(() {
        error = "Location unavailable";
      });
      return;
    }
    api
        .getWeather(position.latitude, position.longitude)
        .then((weather) => setState(() {
              _weather = weather;
            }))
        .then((value) => api.getForecast(position.latitude, position.longitude))
        .then((forecast) => setState(() {
              _forecast = forecast;
            }));
  }

  Widget _buildIcon(var resp) {
    Widget icon = weatherIcons.getIcon(resp, background(), 90, 90);
    Widget circle = CustomPaint(
        foregroundPainter:
            new WeatherPainter(color: textColor(), width: animation.value));

    return Container(
        margin: EdgeInsets.fromLTRB(0, 16, 16, 0),
        alignment: AlignmentDirectional.topEnd,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[circle, icon],
        ));
  }

  Widget _buildTitle(String title) {
    return Row(children: <Widget>[
      Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16, 0, 16),
          child: Icon(
            Icons.location_on,
            color: textColor(),
          )),
      Container(
        margin: const EdgeInsets.all(16.0),
        child: Text(title, style: TextStyle(fontSize: 20, color: textColor())),
      )
    ]);
  }

  Widget _buildDescSection(var temp, String label) {
    num currentTemp = temp["temp"];
    num minTemp = temp["temp_min"];
    num maxTemp = temp["temp_max"];
    return Container(
        margin: EdgeInsets.only(left: 16, bottom: 30),
        alignment: AlignmentDirectional.bottomStart,
        child: Column(
          children: <Widget>[
            _buildTempSection(currentTemp.round(), minTemp, maxTemp),
            Container(
              child: Text(
                _formatLabel(label),
                style: TextStyle(color: textColor(), fontSize: 15),
              ),
              alignment: AlignmentDirectional.bottomStart,
            )
          ],
        ));
  }

  String _formatLabel(String label) {
    var words = label.split(" ");
    String l = "";
    for (var word in words) {
      l = l + "${word[0].toUpperCase()}${word.substring(1)} ";
    }
    return l;
  }

  Widget _buildTempSection(num current, num min, num max) {
    return Row(
      children: <Widget>[
        Text("$current°", style: TextStyle(fontSize: 80, color: textColor())),
        Column(
          children: <Widget>[
            _buildTempMinMaxSection(Icons.arrow_drop_up, max),
            _buildTempMinMaxSection(Icons.arrow_drop_down, min)
          ],
        )
      ],
    );
  }

  Widget _buildTempMinMaxSection(IconData icon, num value) {
    return Row(children: <Widget>[
      Padding(
          padding: EdgeInsets.all(3),
          child: Icon(
            icon,
            color: textColor(),
          )),
      Text("${value.round()}°",
          style: TextStyle(fontSize: 15, color: textColor()))
    ]);
  }

  Widget _buildForecastSection(BuildContext context) {
    var forecasts = _forecast["list"];
    Set<Forecast> days = Set();
    for (var forecast in forecasts) {
      days.add(Forecast.from(forecast));
    }
    List<Widget> childs = [];
    for (Forecast forecast in days) {
      childs.add(_buildForecastItem(context, forecast));
    }

    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 30),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: childs));
  }

  Widget _buildForecastItem(BuildContext context, Forecast forecast) {
    return GestureDetector(
      child: Column(children: <Widget>[
        Text(forecast.name(), style: TextStyle(color: textColor())),
        weatherIcons.getIcon(forecast.response, textColor(), 35, 35),
        Text(
            (forecast.response["main"]["temp"] as num).round().toString() + "°",
            style: TextStyle(color: textColor()))
      ]),
      onTap: () {
        onClickForecast(context, forecast);
      },
    );
  }

  onClickForecast(BuildContext context, Forecast forecast) {
    Navigator.push(
        context,
        FadeRoute(
            builder: (context) => ForecastWidget(
                weather: _weather,
                forecast: _forecast,
                clickedForecast: forecast)));
  }

  _showDialog(String error) {
    showDialog<DialogAction>(
        context: context,
        child: AlertDialog(
            content: Text(error, style: TextStyle(color: textColor())),
            actions: <Widget>[
              FlatButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context, DialogAction.agree);
                  })
            ]));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (error != null) {
      body = Container(
        alignment: Alignment(0.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error,
              color: Colors.white,
              size: animation.value * 2,
            ),
            Text(error, style: TextStyle(fontSize: 19, color: textColor())),
            FlatButton(
              child: Text("Try again",
                  style: TextStyle(fontSize: 16, color: textColor())),
              onPressed: () {
                setState(() {
                  error = null;
                  start();
                });
              },
            )
          ],
        ),
      );
    } else if (_weather != null && _forecast != null) {
      var name = _weather["name"];
      var temp = _weather["main"];
      var widgets = <Widget>[];
      widgets.add(Padding(
          padding: EdgeInsets.only(bottom: 0), child: _buildIcon(_weather)));

      widgets.add(Container(
          margin: EdgeInsets.only(
            left: 16,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Now",
            style: TextStyle(fontSize: 20, color: textColor()),
          )));
      widgets.add(_buildDescSection(temp, weatherIcons.getLabel(_weather)));
      widgets.add(_buildForecastSection(context));
      body = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildTitle(name == null ? "Unknown" : name),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              verticalDirection: VerticalDirection.down,
              children: widgets)
        ],
      );
    } else {
      body = Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      );
    }

    Scaffold scaffold = new Scaffold(
        backgroundColor: background(),
        body: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: SafeArea(child: body)));
    return scaffold;
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  Color background() {
    return Colors.deepOrange;
  }

  Color textColor() {
    return Colors.white;
  }
}

class FadeRoute<T> extends MaterialPageRoute<T> {
  FadeRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(opacity: animation, child: child);
  }
}
