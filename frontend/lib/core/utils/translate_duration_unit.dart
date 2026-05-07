
String translateDurationUnit(String unit, int value) {
  return switch (unit.toLowerCase()) {
     'day' => value <= 1 ? '$value يوم' : '$value أيام',
    'week' => value <= 1 ? '$value أسبوع' : '$value أسابيع',
    'month' => value <= 1 ? '$value شهر' : '$value أشهر',
    'year' => value <= 1 ? '$value سنة' : '$value سنوات',
    _=> unit
  };
}