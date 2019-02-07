import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Forecast.dart';
import 'package:weather_app/WeatherPainter.dart';
import 'package:weather_app/icons.dart';

class ForecastWidget extends StatefulWidget {
  final Map<String, dynamic> weather;
  final Map<String, dynamic> forecast;
  final Forecast clickedForecast;

  ForecastWidget({@required this.weather,
    @required this.forecast,
    @required this.clickedForecast});

  @override
  State<StatefulWidget> createState() =>
      _ForecastWidgetState(
          weathers: weather,
          forecasts: forecast,
          clickedForecast: clickedForecast);
}

class _ForecastWidgetState extends State<ForecastWidget>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> weathers;
  Map<String, dynamic> forecasts;
  Forecast clickedForecast;
  int sliderValue = 0;

  _ForecastWidgetState({this.weathers, this.forecasts, this.clickedForecast});

  double circlesWidth = 65.0;
  Animation<double> animation;
  AnimationController controller;

  WeatherIcons weatherIcons = new WeatherIcons();

  @override
  void initState() {
    super.initState();
    findSliderValue(clickedForecast);
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

  void start() async {}

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
      GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16, 0, 16),
            child: Icon(
              Icons.arrow_back_ios,
              color: textColor(),
            ),
          )),
      Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16, 0, 16),
          child: Icon(
            Icons.location_on,
            color: textColor(),
          )),
      Container(
        margin: const EdgeInsets.all(16.0),
        child:
        Text(title, style: TextStyle(fontSize: 20, color: textColor())),
      )
    ]);
  }

  String _formatLabel(String label) {
    var words = label.split(" ");
    String l = "";
    for (var word in words) {
      l = l + "${word[0].toUpperCase()}${word.substring(1)} ";
    }
    return l;
  }

  Widget _buildForecastSection() {
    var fors = forecasts["list"];
    Set<Forecast> days = Set();
    for (var forecast in fors) {
      days.add(Forecast.from(forecast));
    }
    List<Widget> childs = [];
    for (Forecast forecast in days) {
      childs.add(_buildForecastItem(forecast));
    }

    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: childs));
  }

  Widget _buildForecastItem(Forecast forecast) {
    bool selected = clickedForecast == forecast;
    return GestureDetector(
        onTap: () {
          clickedForecast = forecast;
          findSliderValue(forecast);
        },
        child: Column(children: <Widget>[
          Text(forecast.name(),
              style: TextStyle(
                  color: selected ? textColor() : textColor().withAlpha(122))),
          weatherIcons.getIcon(forecast.response,
              selected ? textColor() : textColor().withAlpha(122), 35, 35),
          Text(
              (forecast.response["main"]["temp"] as num).round().toString() +
                  "°",
              style: TextStyle(
                  color: selected ? textColor() : textColor().withAlpha(122)))
        ]));
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

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (weathers != null && forecasts != null) {
      var name = weathers["name"];
      var temp = weathers["main"];
      var widgets = <Widget>[];
      widgets.add(Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: _buildIcon(clickedForecast.response)));

      widgets.add(Container(
          margin: EdgeInsets.only(
            left: 16,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            DateFormat("HH:mm").format(clickedForecast.day),
            style: TextStyle(fontSize: 20, color: textColor()),
          )));

      widgets.add(_buildDescSection(clickedForecast.response["main"],
          weatherIcons.getLabel(clickedForecast.response)));

      widgets.add(Slider(
          inactiveColor: textColor().withAlpha(124),
          activeColor: textColor(),
          value: sliderValue * 1.0,
          max: forecasts["list"].length - 1 * 1.0,
          min: 0.0,
          onChanged: (value) {
            sliderValue = value.round();
            findAndChangeSelectedForecast(sliderValue);
          }));

      widgets.add(_buildForecastSection());

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
      body = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[CircularProgressIndicator()],
      );
    }
    Scaffold scaffold = new Scaffold(
        backgroundColor: background(), body: SafeArea(child: body));
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

  void findAndChangeSelectedForecast(int sliderValue) {
    var fors = forecasts["list"];
    clickedForecast = Forecast.from(fors[sliderValue]);
    setState(() {
      this.clickedForecast = clickedForecast;
    });
  }

  void findSliderValue(Forecast forecast) {
    var fors = forecasts["list"];
    for (int i = 0; i < fors.length; i++) {
      if (fors[i]["dt"] == forecast.response["dt"]) {
        sliderValue = i;
        break;
      }
    }
    setState(() {
      clickedForecast = clickedForecast;
      sliderValue = sliderValue;
    });
  }
}
