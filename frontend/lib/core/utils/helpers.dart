class Helpers 
{
  static T iF<T>(bool condition, T valueIfTrue, T valueIfFalse) 
  {
    return condition ? valueIfTrue : valueIfFalse;
  }

  static T iFNot<T>(bool condition, T valueIfTrue, T valueIfFalse) 
  {
    return condition ? valueIfTrue : valueIfFalse;
  }

  static T iFNull<T>(T? value, T defaultValue) 
  {
    return value ?? defaultValue;
  }

  static T? iFOrNull<T>(bool condition, T value) 
  {
    return condition ? value : null;
  }

  static T? iFNotOrNull<T>(bool condition, T value) 
  {
    return condition ? null : value;
  }

}

