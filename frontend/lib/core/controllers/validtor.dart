import 'package:get/get_rx/src/rx_types/rx_types.dart';

enum MyPValidOptios{
  required, onlyCapetal, onlySmall, email, password, phone, name
}

class MyPValidator {

  static String? _extractString(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    try {
      final inner = val.value;
      if (inner == null) return null;
      if (inner is String) return inner;
      return inner.toString();
    } catch (_) {
      return val.toString();
    }
  }

  // 1. التحقق من البريد الإلكتروني
  static String? email([dynamic val]) 
  {
    final value = _extractString(val);
    for (var error = notEmptyWithTrim(value, 'البريد الإلكتروني'); error != null;) 
    {
      return error;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) 
    {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null; 
  }

  // 2. التحقق من كلمة المرور (قوية: حروف وأرقام و8 رموز)
  static String? password(dynamic val, [int len = 8]) 
  {
    final value = _extractString(val);
    for (var error = notEmpty(value, 'كلمة المرور'); error != null;) 
    {
      return error;
    }
    if (value!.length < len) 
    {
      return 'كلمة المرور يجب أن تكون $len أحرف على الأقل';
    }
    return null;
  }

  // 3. التحقق من رقم الهاتف (بفرض التنسيق الدولي أو المحلي 10 أرقام)
  static String? phone([dynamic val]) 
  {
    final value = _extractString(val);
    for (var error = notEmpty(value, 'رقم الهاتف'); error != null;) 
    {
      return error;
    }
    if (!RegExp(r'^[0-9]{7,9}$').hasMatch(value!)) 
    {
      return 'رقم الهاتف غير صحيح';
    }
    if(!value.startsWith('77') && !value.startsWith('71') && !value.startsWith('73') && !value.startsWith('70') && !value.startsWith('78'))
    {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  // 4. التحقق من اسم المستخدم (حروف فقط، بدون أرقام أو رموز)
  static String? name([dynamic val]) 
  {
    final value = _extractString(val);
    for (var error = notEmptyWithTrim(value, 'الاسم'); error != null; ) 
    {
      return error;
    }
    
    // يدعم العربية والإنجليزية
    if (!RegExp(r"^[a-zA-Z\s\u0600-\u06FF]+$").hasMatch(value!)) 
    {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }
    
    if (value.length < 2) 
    {
      return 'الاسم يجب أن يحتوي على حرفين على الأقل';
    }
    return null;
  }

  // 5. التحقق من الحقول الفارغة العامة
  static String? notEmpty([dynamic val, String fieldName = '']) 
  {
    final value = _extractString(val);
    return (value == null || value.isEmpty)?
      'حقل $fieldName لا يمكن أن يكون فارغاً' :
    null;
  }



  static String? notEmptyWithTrimL([dynamic val, String fieldName = '']) 
  {
    final value = _extractString(val);
    return notEmpty(value?.trimLeft(), fieldName);
  }

  static String? notEmptyWithTrimR([dynamic val, String fieldName = '']) 
  {
    final value = _extractString(val);
    return notEmpty(value?.trimRight(), fieldName);
  }

  static String? notEmptyWithTrim([dynamic val, String fieldName = '']) 
  {
    final value = _extractString(val);
    return notEmpty(value?.trim(), fieldName);
  }

  static String? cocatMsg(List msgs, [String sep = '\n'])
  {
    var msgJoin = msgs.where((m)=> 
      (m is String? && m != null && m.trim().isNotEmpty) ||
      (m is Rx<String?>? && m != null && m.value != null && m.value!.trim().isNotEmpty)
  ).map((m)=> (m is Rx<String?>? ? m!.value : m!)).toList();
    if(msgJoin.isEmpty)
    {
      return null;
    }
    return msgJoin.join(sep);
  }
}

class CountryModel {
  final String name;       
  final String code;       
  final String dialCode;   
  final String flag;       

  CountryModel({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class CountryProvider {

  static List<CountryModel> countries = [
    CountryModel(name: "اليمن", code: "YE", dialCode: "+967", flag: "🇾🇪"),
    CountryModel(name: "السعودية", code: "SA", dialCode: "+966", flag: "🇸🇦"),
    CountryModel(name: "الإمارات", code: "AE", dialCode: "+971", flag: "🇦🇪"),
    CountryModel(name: "مصر", code: "EG", dialCode: "+20", flag: "🇪🇬"),
    CountryModel(name: "الأردن", code: "JO", dialCode: "+962", flag: "🇯🇴"),
    CountryModel(name: "الكويت", code: "KW", dialCode: "+965", flag: "🇰🇼"),
    CountryModel(name: "قطر", code: "QA", dialCode: "+974", flag: "🇶🇦"),
    CountryModel(name: "عمان", code: "OM", dialCode: "+968", flag: "🇴🇲"),
    CountryModel(name: "البحرين", code: "BH", dialCode: "+973", flag: "🇧🇭"),
    CountryModel(name: "فلسطين", code: "PS", dialCode: "+970", flag: "🇵🇸"),
    CountryModel(name: "العراق", code: "IQ", dialCode: "+964", flag: "🇮🇶"),
    CountryModel(name: "سوريا", code: "SY", dialCode: "+963", flag: "🇸🇾"),
    CountryModel(name: "لبنان", code: "LB", dialCode: "+961", flag: "🇱🇧"),
    CountryModel(name: "المغرب", code: "MA", dialCode: "+212", flag: "🇲🇦"),
    CountryModel(name: "تونس", code: "TN", dialCode: "+216", flag: "🇹🇳"),
    CountryModel(name: "الجزائر", code: "DZ", dialCode: "+213", flag: "🇩🇿"),
    CountryModel(name: "ليبيا", code: "LY", dialCode: "+218", flag: "🇱🇾"),
    CountryModel(name: "السودان", code: "SD", dialCode: "+249", flag: "🇸🇩"),
  ];
}

