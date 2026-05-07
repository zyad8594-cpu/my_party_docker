import 'package:flutter/material.dart' show Color, Brightness;

import '../themes/app_colors.dart';


enum Status { PENDING, IN_PROGRESS, UNDER_REVIEW, COMPLETED, CANCELLED, REJECTED, APPROVED, OTHER }

class _StatusSelection {
  final Status? status;
  final String? value;
  final String? text;
  final AppColorSet<Color>? color;

  const _StatusSelection({
    this.status,
    this.value,
    this.text,
    this.color,
  });

  factory _StatusSelection.proccess([dynamic defaultV, dynamic isNullble = false]) 
  {
    if(defaultV is _StatusSelection) return defaultV;
    defaultV = (defaultV is String)? defaultV.toUpperCase() : defaultV;
    if(['APPROVED', 'معتمدة', Status.APPROVED, AppColors.success].contains(defaultV)) {
      return _StatusSelection(
        status: Status.APPROVED,
        value: 'APPROVED',
        text: 'معتمدة',
        color: AppColors.success,
      );
    }
    if(['PENDING', 'قيد الانتظار', Status.PENDING, AppColors.info].contains(defaultV)) {
      return _StatusSelection(
        status: Status.PENDING,
        value: 'PENDING',
        text: 'قيد الانتظار',
        color: AppColors.info,
      );
    }
    if(['IN_PROGRESS', 'قيد التنفيذ', Status.IN_PROGRESS, AppColors.warning].contains(defaultV)) {
      return _StatusSelection(
        status: Status.IN_PROGRESS,
        value: 'IN_PROGRESS',
        text: 'قيد التنفيذ',
        color: AppColors.warning,
      );
    }
    if(['UNDER_REVIEW', 'قيد المراجعة', Status.UNDER_REVIEW, AppColors.secondary].contains(defaultV)) {
      return _StatusSelection(
        status: Status.UNDER_REVIEW,
        value: 'UNDER_REVIEW',
        text: 'قيد المراجعة',
        color: AppColors.secondary,
      );
    }
    if(['COMPLETED', 'مكتملة', Status.COMPLETED, AppColors.success].contains(defaultV)) {
      return _StatusSelection(
        status: Status.COMPLETED,
        value: 'COMPLETED',
        text: 'مكتملة',
        color: AppColors.success,
      );
    }
    if(['CANCELLED', 'ملغاة', Status.CANCELLED, AppColors.accent].contains(defaultV)) {
      return _StatusSelection(
        status: Status.CANCELLED,
        value: 'CANCELLED',
        text: 'ملغاة',
        color: AppColors.accent,
      );
    }
    if(['REJECTED', 'مرفوضة', Status.REJECTED, AppColors.rejected].contains(defaultV)) {
      return _StatusSelection(
        status: Status.REJECTED,
        value: 'REJECTED',
        text: 'مرفوضة',
        color: AppColors.rejected,
      );
    }

    if(isNullble is _StatusSelection) return isNullble;

    return _StatusSelection(
      status: isNullble == true? null : Status.OTHER,
      value: isNullble == true? null : 'OTHER' ,
      text: isNullble == true? null : 'أخرى',
      color: isNullble == true? null : AppColors.primary,
    );


  }

}

extension StringStatusExtension on String? 
{
  Status status([dynamic defaultV]) {
    final self = _StatusSelection.proccess(this, _StatusSelection.proccess(defaultV, true));
    if(self.status != null) return self.status!;
    throw Exception('Invalid status: $this');
  }

  Status tryStatus([dynamic defaultV = Status.OTHER]) 
  {
    return _StatusSelection.proccess(
      this, _StatusSelection.proccess(
        defaultV, _StatusSelection(
          status: Status.OTHER
        )
      )
    ).status!;

  }

}

extension StatusExtension on Status? 
{
  String value([dynamic defaultV]) 
  {
    final self = _StatusSelection.proccess(this, _StatusSelection.proccess(defaultV, true));
    if(self.value != null) return self.value!;
    throw Exception('Invalid status: $this'); 
  }

  String tryValue([dynamic defaultV ='PENDING' ]) 
  {
    return _StatusSelection.proccess(
      this, _StatusSelection.proccess(
        defaultV, _StatusSelection(
          value: 'PENDING'
        )
      )
    ).value!;

  }


  String text([dynamic defaultV]) {
    final self = _StatusSelection.proccess(this, _StatusSelection.proccess(defaultV, true));
    if(self.text != null) return self.text!;
    throw Exception('Invalid status: $this'); 
  }

  String tryText([dynamic defaultV = 'أخرى']) 
  {
    return _StatusSelection.proccess(
      this, _StatusSelection.proccess(
        defaultV, _StatusSelection(
          text: 'أخرى'
        )
      )
    ).text!;
  }

  Color color(Brightness brightness, {dynamic defaultV}) {
    final self = _StatusSelection.proccess(this, _StatusSelection.proccess(defaultV, true));
    if(self.color != null) return self.color!.getByBrightness(brightness);
    throw Exception('Invalid status: $this'); 
  }

  Color tryColor(Brightness brightness, {dynamic defaultV =  AppColors.primary}) {
   return _StatusSelection.proccess(
      this, _StatusSelection.proccess(
        defaultV, _StatusSelection(
          color: AppColors.primary
        )
      )
    ).color!.getByBrightness(brightness);
  }

  // CONFIRMED, PENDING, IN_PROGRESS, UNDER_REVIEW, COMPLETED, CANCELLED
  bool get isPending => this == Status.PENDING;
  bool get isInProgress => this == Status.IN_PROGRESS;
  bool get isUnderReview => this == Status.UNDER_REVIEW;
  bool get isCompleted => this == Status.COMPLETED;
  bool get isCancelled => this == Status.CANCELLED; 
  bool get isRejected => this == Status.REJECTED;
  bool get isApproved => this == Status.APPROVED;

  bool isIn(List statuses){
    for (var status in statuses) {
      if( _StatusSelection.proccess(status, true).status != null) return true;
    }
    return false;
  }

  bool notIn(List statuses){
    return !isIn(statuses);
  }
  
}

class StatusTools
{
  static Status parse<K>(dynamic value, {dynamic defaultV, K? keys}){
    if(value is Map || value is List){
      
      for(var key in (keys is Iterable ? keys : [keys]))
      {
        try {
          final v = _StatusSelection.proccess(value[key], true).status;
          if(v != null) return v;
        } catch (e) {null;}
      }
    }
    final v = _StatusSelection.proccess(value,  _StatusSelection.proccess(defaultV, true)).status;
    if(v != null) return v;
    throw Exception('Invalid status: $value');
  }

  static Status tryParse<K>(dynamic value, {dynamic defaultV = Status.PENDING, K? keys}){
    return parse(value, defaultV: _StatusSelection.proccess(defaultV, _StatusSelection(status: Status.PENDING)).status, keys: keys);
  }

  static List<Status> getAllStatus([bool includeOther = false]) => [
    Status.PENDING, 
    Status.IN_PROGRESS, 
    Status.COMPLETED, 
    Status.CANCELLED,
    Status.REJECTED,
    Status.APPROVED,
    Status.UNDER_REVIEW,
    if(includeOther) Status.OTHER
  ];

  static List<String> getAllStatusText({
    bool includeOther = false,
    List<String> prepend = const [], 
    List<String> append = const [],
    List<String> remove = const [],
  }) => [
    ...prepend,
    Status.PENDING.text(), 
    Status.IN_PROGRESS.text(), 
    Status.COMPLETED.text(), 
    Status.CANCELLED.text(), 
    Status.REJECTED.text(),
    Status.APPROVED.text(),
    Status.UNDER_REVIEW.text(),
    if(includeOther) Status.OTHER.text('أخرى'),
    ...append,
  ].where((status) => !remove.contains(status)).toList();

  static List<String> getAllStatusValue([bool includeOther = false]) => [
    Status.PENDING.value(), 
    Status.IN_PROGRESS.value(), 
    Status.COMPLETED.value(), 
    Status.CANCELLED.value(),
    Status.REJECTED.value(),
    Status.APPROVED.value(),
    Status.UNDER_REVIEW.value(),
    if(includeOther) Status.OTHER.value('OTHER')
  ];
  

  static List<Color> getAllStatusColor(Brightness brightness, {bool includeOther = false}) => [
    Status.PENDING.color(brightness), 
    Status.IN_PROGRESS.color(brightness), 
    Status.COMPLETED.color(brightness), 
    Status.CANCELLED.color(brightness), 
    Status.REJECTED.color(brightness),
    Status.APPROVED.color(brightness),
    Status.UNDER_REVIEW.color(brightness),
    if(includeOther) Status.OTHER.tryColor(brightness)
  ];
}
