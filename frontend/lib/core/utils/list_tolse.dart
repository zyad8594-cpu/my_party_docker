Map<K, V> _copyMap<K, V>(Map<K, V> map)
{
  final ret = <K, V>{};
  for(var i in map.entries)
  {
    ret[_copy(i.key)] = _copy(i.value);
  }
  return ret ;
}
Iterable<V> _copyIter<V>(Iterable<V> iter)
{
  final ret = <V>[];
  for(var i in iter)
  {
    ret.add(_copy(i));
  }
  return ret as Iterable<V>;
}


T _copy<T>(T item)=>switch(item)
{
  Map() => _copyMap(item),
  Iterable() => _copyIter(item),
  _ => item
} as T;

extension SortedList<T> on Iterable<T> {
  Iterable<T> sorted(Comparator<T> compare) 
  {
    return <T>[...this]..sort(compare);
  }
}

class ListTools 
{
  static List<T> tryParse<T, K>(dynamic value, {List<T> defaultV = const [], K? keys})
  {
    if((value is Map || value is List) && keys != null)
    {
      for(var key in ((keys is Iterable))? keys : [keys])
      {
        try{ 
          final val = value[key];
          return val as List<T>;
        }catch(e){null;}
      }
    }
    
    try{ return value as List<T>;}catch(e){null;}
    return defaultV;
  }

  static List<T> parse<T, K>(dynamic value, {List<T>? defaultV, K? keys})
  {
    if((value is Map || value is List) && keys != null)
    {
      for(var key in ((keys is Iterable))? keys : [keys])
      {
        try{ 
          final val = value[key];
          return val as List<T>;
        }catch(e){null;}
      }
    }
    
    try{ return value as List<T>;}catch(e){null;}
    if(defaultV != null) return defaultV;
    throw Exception('Invalid value: $value');
  }

  static List<T> map<T>(
    T Function(dynamic) toElement,{
    value, 
    List<T>? defaultV,
    keys
  })
  {
    if(keys != null)
    {
      for(var key in ((keys is Iterable)? keys : [keys]))
      {
        try{ 
          final val = value[key];
          return val.map(toElement).toList();
        }catch(e){null;}
      }
    }
    
    try{ return value.map(toElement).toList();}catch(e){null;}
    if(defaultV != null) return defaultV.map(toElement).toList();
    throw Exception('Invalid value: $value');
  }

  static List<T> tryMap<T>(
    T Function(dynamic) toElement,{
    value, 
    List<T> defaultV = const [],
    keys
  })
  {
    if(keys != null)
    {
      for(var key in ((keys is Iterable)? keys : [keys]))
      {
        try{ 
          final val = value[key];
          return val.map(toElement).toList();
        }catch(e){null;}
      }
    }
    
    try{ return value.map(toElement).toList();}catch(e){null;}
    return defaultV.map(toElement).toList();
  }

}