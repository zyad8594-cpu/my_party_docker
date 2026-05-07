class MapTools 
{
  static Map<MK, MV> tryParse<MK, MV, K>(
    dynamic value, {
    Map<MK, MV> defaultV = const {}, 
    K? keys
  }) {
    if((value is Map || value is List) && keys != null)
    {
      for(var key in ((keys is Iterable))? keys : [keys])
      {
        try{ 
          // if(value is Map)
          // {
          //   return value[switch(keys){
          //     Iterable()=> keys,
          //     _=> [keys]
          //   }.firstWhere((k)=> value.containsKey(k))];
          // }
          final val = value[key];
          return val as Map<MK, MV>;
        }catch(e){null;}
      }
    }
    
    try{ return value as Map<MK, MV>;}catch(e){null;}
    return defaultV;
  }

  static Map<MK, MV> parse<MK, MV, K>(dynamic value, {Map<MK, MV>? defaultV, K? keys})
  {
    if((value is Map || value is List) && keys != null)
    {
      for(var key in ((keys is Iterable))? keys : [keys])
      {
        try{ 
          final val = value[key];
          return val as Map<MK, MV>;
        }catch(e){null;}
      }
    }
    
    try{ return value as Map<MK, MV>;}catch(e){null;}
    if(defaultV != null) return defaultV;
    throw Exception('Invalid value: $value');
  }

}