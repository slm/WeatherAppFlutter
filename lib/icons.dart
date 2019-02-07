import "dart:convert";

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherIcons {
  static Map<String, dynamic> _icons;

  dynamic init() {
    return rootBundle
        .loadString("assets/icons.json")
        .then(jsonDecode)
        .then((value) => _icons = value);
  }

  String _getIconName(Map<String, dynamic> resp) {
    var prefix = 'wi-';
    var code = resp["weather"][0]["id"];
    var icon = _icons[code.toString()]["icon"];
    // If we are not in the ranges mentioned above, add a day/night prefix.
    if (!(code > 699 && code < 800) && !(code > 899 && code < 1000)) {
      icon = 'day-' + icon;
    }
    // Finally tack on the prefix.
    icon = prefix + icon;
    return icon;
  }

  String _getIconLabel(Map<String, dynamic> resp) {
    var code = resp["weather"][0]["id"];
    return _icons[code.toString()]["label"];
  }

  Widget getIcon(
      Map<String, dynamic> resp, Color color, double width, double height) {
    assert(_icons != null);
    var iconPath = "assets/svg/${_getIconName(resp)}.svg";
    return SvgPicture.asset(iconPath,
        color: color, width: width, height: height);
  }

  String getLabel(Map<String, dynamic> resp) {
    assert(_icons != null);
    return _getIconLabel(resp);
  }
}
