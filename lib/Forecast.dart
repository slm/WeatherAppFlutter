import 'package:intl/intl.dart';

class Forecast{
  DateTime day;
  Map<String, dynamic> response;
  String temp;

  @override
  int get hashCode => ("${day.year}-${day.month}-${day.day}") .hashCode;

  @override
  bool operator ==(other) {
    return other.hashCode == hashCode;
  }

  String name(){
    var now =DateTime.now();
    if(now.year == day.year && now.month == day.month && now.day == day.day){
      return "Today";
    }
    return new DateFormat('EEEE').format(day);
  }

  Forecast.from(Map<String, dynamic> response){
      day = DateTime.parse(response["dt_txt"]);
      this.response = response;
  }

}