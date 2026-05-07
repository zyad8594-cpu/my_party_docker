class BoolTools 
{
  static bool tryParse<K>(dynamic value, {bool defaultV = false, K? keys})
  {
    try{ return value as bool;}catch(e){null;}
    if(value is Map || value is List)
    {
      for(var key in ((keys is Iterable))? keys : [keys]){
        try{
          final val = value[key];
          return val as bool;
        }catch(e){null;}
      }
    }
    
    return defaultV;
  }

  static bool parse<K>(dynamic value, {bool? defaultV, K? keys}) 
  {
    try{ return value as bool;}catch(e){null;}
    if(value is Map || value is List)
    {
      for(var key in (keys is Iterable)? keys : [keys]){
        try{
          final val = value[key];
          return val as bool;
        }catch(e){null;}
      }      
    }
    if(defaultV != null) return defaultV;
    throw Exception('Invalid value: $value');
  }
}