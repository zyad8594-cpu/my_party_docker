
extension StringToDate on String?
{
  int toYear()=> DateTime.parse(this ?? '').year;
  int toMonth()=> DateTime.parse(this ?? '').month;
  int toDay()=> DateTime.parse(this ?? '').day;
  int toHour()=> DateTime.parse(this ?? '').hour;
  int toMinute()=> DateTime.parse(this ?? '').minute;
  int toSecond()=> DateTime.parse(this ?? '').second;
  int toMillisecond()=> DateTime.parse(this ?? '').millisecond;
  int toMicrosecond()=> DateTime.parse(this ?? '').microsecond;

  DateTime toDate([bool month = true, bool day = true]){
    final dateTime = DateTime.parse(this ?? '');
    return DateTime(
      dateTime.year, 
      month ? dateTime.month : 1, 
      day ? dateTime.day : 1
    );
  }

  DateTime toDateTime([
    bool month = true, 
    bool day = true,
    bool hour = true,
    bool minute = true,
    bool second = true,
    bool millisecond = true,
    bool microsecond = true,  
  ]){
    final dateTime = DateTime.parse(this ?? '');
    return DateTime(
      dateTime.year, 
      month ? dateTime.month : 1, 
      day ? dateTime.day : 1, 
      hour ? dateTime.hour : 0, 
      minute ? dateTime.minute : 0, 
      second ? dateTime.second : 0, 
      millisecond ? dateTime.millisecond : 0,
      microsecond ? dateTime.microsecond : 0,
    );
  }

  List<String> splitWithSeparators(dynamic separators) 
  {
    String str = this ?? '';
    if(separators is List<String>)
    {
      if (separators.isEmpty) return [str];

      final validSeparators = separators.where((s) => s.isNotEmpty).toList();
      if (validSeparators.isEmpty) return [str];

      return str.split(RegExp(validSeparators.map(RegExp.escape).join('|')));
    }
    else if(separators is String)
    {
      return str.split(separators);
    }
    else
    {
      throw Exception('Invalid separators: $separators');
    }
  }
}

class StrTools 
{
  static String take(String? value, int len, {String prefix = '', String suffix = '...'}){
    if(value == null) return '';
    if(value.length > len) return '$prefix${value.substring(0, len)}$suffix';
    return value;
  }

  static String takeLines(String? value, int lines, {int? width, String prefix = '', String suffix = '...'}){
    if(value == null) return '';
    final textLines = value.split('\n');
    if(textLines.length > lines) return '$prefix${textLines.map((line)=> take(line, (width ?? line.length), suffix: "")).join("\n")}$suffix';
    return value;
  }
  static String tryParse<K>(dynamic value, {String defaultV = '', K? keys})
  {
    try{ return value as String;}catch(e){null;}
    if(value is Map<String, dynamic>)
    {
      for(String key in ((keys is Iterable<String>))? keys : (keys is String ? [keys] : [])){
        try{
          final val = value[key];
          return val as String;
        }catch(e){null;}
      }
    }
    else if(value is List<dynamic>)
    {
      for(int key in ((keys is Iterable<int>))? keys : (keys is int ? [keys] : [])){
        try{
          final val = value[key];
          return val as String;
        }catch(e){null;}
      }
    }
    
    return defaultV;
  }

  static String parse<K>(dynamic value, {String? defaultV, K? keys}) 
  {
    try{ return value as String;}catch(e){null;}
    if(value is Map || value is List)
    {
      for(var key in (keys is Iterable)? keys : [keys]){
        try{
          final val = value[key];
          return val as String;
        }catch(e){null;}
      }      
    }
    if(defaultV != null) return defaultV;
    throw Exception('Invalid value: $value');
  }

}