
class NotificationModel {
  final int id;
  final int? userId;
  final int? supplierId;
  final int taskId;
  final String? type;
  final String title;
  final String message;
  final String createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    this.userId,
    this.supplierId,
    required this.taskId,
    this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  /// تحويل البيانات المستلمة إلى النوع Map
  /// 
  /// data عادة ما تكون من النوع List أو Map، نفترض هنا أنها Map.
  /// 
  /// إضافة البيانات إلى الـ StreamController
  /// 
  /// procedure: هذا الإجراء هو ما سيبعث الإشعار فوراً إلى جميع الواجهات المستمعة إذا كان نوع البيانات (Map).
  /// 
  ///     إذا كانت البيانات على شكل قائمة (List) نأخذ العنصر الأول (حسب هيكل خادمك)
  /// 
  /// socketError: دالة callback يتم استدعاؤها في حالة حدوث خطأ أو لم يكن نوع البيانات (Map) أو (List)
  static 
  // StreamController<NotificationModel> 
  void addTo(
    // StreamController<NotificationModel> procedure, 
    {
      dynamic data,
      void Function(dynamic, dynamic)? socketError,
      required void Function(NotificationModel) call
  }){
    try{
      return switch(data){
        Map() => call(NotificationModel.fromJson(Map<String, dynamic>.from(data))),
        List() => call(NotificationModel.fromJson(Map<String, dynamic>.from(data.first))),
        _ => call(data)
      };
    }
    catch(e){
      if(socketError != null) { socketError(data, e); }
    }
    // if(data is Map)
    // {
    //   // إضافة البيانات إلى الـ StreamController
    //   // هذا الإجراء هو ما سيبعث الإشعار فوراً إلى جميع الواجهات المستمعة.
    //   procedure.add(NotificationModel.fromJson(Map<String, dynamic>.from(data)));
    // }
    // else if(data is List && data.isNotEmpty)
    // {
    //   // إذا كانت البيانات على شكل قائمة، نأخذ العنصر الأول (حسب هيكل خادمك)
    //   procedure.add(NotificationModel.fromJson(Map<String, dynamic>.from(data.first)));
    // }
    // else if(socketError != null) { socketError(data); }
    // return procedure;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] ?? json['id'] ?? 0,
      userId: json['user_id'],
      supplierId: json['supplier_id'],
      taskId: json['task_id'] ?? 0,
      type: json['type'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    int? supplierId,
    int? taskId,
    String? type,
    String? title,
    String? message,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}