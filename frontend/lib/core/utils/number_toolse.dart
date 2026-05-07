class NumberTools 
{
  static num tryParse<K>(dynamic value, {num defaultV = 0, K? keys})
  {
    if(value is num) return value;
    if(value is String) {
      final ret = num.tryParse(value);
      if(ret != null) return ret;
    }
    if(value is Map || value is List)
    {
      for(var key in ((keys is Iterable))? keys : [keys]){
        try{
          final val = value[key];
          if(val is num) return val;
          if(val is String) return num.parse(val);
          return val as num;
        }catch(e){null;}
      }
    }
    
    return defaultV;
  }

  static num parse<K>(dynamic value, {num? defaultV, K? keys}) 
  {
    if(value is num) return value;
    if(value is String){
      final ret = num.tryParse(value);
      if(ret != null) return ret;
    }
    if(value is Map || value is List)
    {
      for(var key in (keys is Iterable)? keys : [keys]){
        try{
          final val = value[key];
          if(val is num) return val;
          if(val is String) return num.parse(val);
          return val as num;
        }catch(e){null;}
      }      
    }
    if(defaultV != null) return defaultV;
    throw Exception('Invalid value: $value');
  }

  static double parseDouble<K>(dynamic value, {double? defaultV, K? keys}) => parse(value, defaultV: defaultV, keys: keys).toDouble();
  static int parseInt<K>(dynamic value, {int? defaultV, K? keys}) => parse(value, defaultV: defaultV, keys: keys).toInt();

  static double tryParseDouble<K>(dynamic value, {double defaultV = 0.0, K? keys}) => tryParse(value, defaultV: defaultV, keys: keys).toDouble();
  static int tryParseInt<K>(dynamic value, {int defaultV = 0, K? keys}) => tryParse(value, defaultV: defaultV, keys: keys).toInt();
}