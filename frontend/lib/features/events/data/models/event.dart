import '../../../../core/utils/bool_toolse.dart';
import '../../../../core/utils/number_toolse.dart';
import '../../../../core/utils/status.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/string_toolse.dart';

class Event extends Equatable {
  final int id;
  final int clientId;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String clientImg;
  final String eventName;
  final String imgUrl;
  final String? description;
  final String eventDate;
  final int eventDuration;
  final String eventDurationUnit;
  final String? location;
  final double budget;
  final Status status;
  final String createdAt;
  final int coordinatorId;
  final String coordinatorName;
  final String coordinatorPhone;
  final bool isDeleted;

  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double totalTasks;
  final double completedTasks;
  final double pendingTasks;
  final double cancelledTasks;

  const Event({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.imgUrl,
    required this.clientEmail,
    required this.clientImg,
    required this.coordinatorId,
    required this.eventName,
    required this.eventDate,
    this.eventDuration = 1,
    this.eventDurationUnit = 'يوم',
    required this.coordinatorName,
    required this.coordinatorPhone,
    required this.clientPhone,
    this.description,
    this.location,
    this.budget = 0.0,
    this.status = Status.PENDING,
    this.createdAt = '',
    this.isDeleted = false,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.netProfit = 0.0,
    this.totalTasks = 0.0,
    this.completedTasks = 0.0,
    this.pendingTasks = 0.0,
    this.cancelledTasks = 0.0,
  });

  factory Event.fromJson(dynamic json) 
  {
    json = json is Map<String, dynamic> ? json : {};
    var isDeleted = BoolTools.tryParse(json, keys: ['is_deleted', 'isDeleted']);
    return Event(
      id: NumberTools.tryParseInt(json, keys: ['event_id', 'id']),
      clientId: NumberTools.tryParseInt(json, keys: ['client_id', 'clientId']),
      coordinatorId: NumberTools.tryParseInt(json, keys: ['coordinator_id', 'coordinatorID']),
      eventName:  StrTools.tryParse(json, keys: ['event_name', 'name_event', 'nameEvent', 'eventName', 'name']),
      imgUrl: StrTools.tryParse(json, keys: ['img', 'image', 'img_url', 'imgUrl', 'urlImg', 'url_img', 'image_url', 'imageUrl', 'urlImage', 'url_image']),
      description: StrTools.tryParse(json, keys: ['description', 'desc', 'descEvent', 'descriptionEvent']),
      eventDate: StrTools.tryParse(json, keys: ['event_date', 'eventDate', 'date']),
      eventDuration: NumberTools.tryParseInt(json, keys: ['event_duration', 'duration', 'eventDuration']),
      eventDurationUnit: StrTools.tryParse(json, keys: ['event_duration_unit', 'duration_unit', 'durationUnit', 'eventDurationUnit']),
      location: StrTools.tryParse(json, keys: ['location', 'loc', 'locationEvent', 'locationEvent']),
      budget: NumberTools.tryParseDouble(json, keys: ['budget', 'budgetEvent', 'budgetEvent', 'planned_budget']),
      status: StatusTools.tryParse(json['status'] ?? json['event_status']),
      createdAt: StrTools.tryParse(json, keys: ['created_at', 'createdAt']),
      isDeleted: isDeleted,
      clientName: StrTools.tryParse(json, keys: ['client_name', 'clientName']),
      coordinatorName: StrTools.tryParse(json, keys: ['coordinator_name', 'coordinatorName']),
      clientPhone: StrTools.tryParse(json, keys: ['client_phone', 'clientPhone']),
      coordinatorPhone: StrTools.tryParse(json, keys: ['coordinator_phone', 'coordinatorPhone']),
      clientEmail: StrTools.tryParse(json, keys: ['client_email', 'clientEmail']),
      clientImg: StrTools.tryParse(json, keys: ['client_img', 'clientImg']),
      totalIncome: NumberTools.tryParseDouble(json, keys: ['total_income', 'totalIncome']),
      totalExpenses: NumberTools.tryParseDouble(json, keys: ['total_expenses', 'totalExpenses']),
      netProfit: NumberTools.tryParseDouble(json, keys: ['net_profit', 'netProfit']),
      totalTasks: NumberTools.tryParseDouble(json, keys: ['total_tasks', 'totalTasks']),
      completedTasks: NumberTools.tryParseDouble(json, keys: ['completed_tasks', 'completedTasks']),
      pendingTasks: NumberTools.tryParseDouble(json, keys: ['pending_tasks', 'pendingTasks']),
      cancelledTasks: NumberTools.tryParseDouble(json, keys: ['cancelled_tasks', 'cancelledTasks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': id,
      'client_id': clientId,
      'coordinator_id': coordinatorId,
      'event_name': eventName,
      'img_url': imgUrl,
      if(description != null) 'description': description,
      'event_date': eventDate,
      'event_duration': eventDuration,
      'event_duration_unit': eventDurationUnit,
      if(location != null) 'location': location,
      'budget': budget,
      'status': status.tryValue(),
      'is_deleted': isDeleted,
      'client_name': clientName,
      'coordinator_name': coordinatorName,
      'client_phone': clientPhone,
      'coordinator_phone': coordinatorPhone,
      'client_email': clientEmail,
      'client_img': clientImg,
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'cancelled_tasks': cancelledTasks,
    };
  }

  Event copyWith({
    int? id,
    int? clientId,
    int? coordinatorId,
    String? eventName,
    String? imgUrl,
    String? description,
    String? eventDate,
    int? eventDuration,
    String? eventDurationUnit,
    String? location,
    double? budget,
    Status? status,
    String? createdAt,
    String? clientName,
    String? coordinatorName,
    String? clientPhone,
    String? coordinatorPhone,
    String? clientEmail,
    String? clientImg,
    double? totalIncome,
    double? totalExpenses,
    double? netProfit,
    double? totalTasks,
    double? completedTasks,
    double? pendingTasks,
    double? cancelledTasks,
    bool? isDeleted,
  }) {
    return Event(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      eventName: eventName ?? this.eventName,
      imgUrl: imgUrl ?? this.imgUrl,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventDuration: eventDuration ?? this.eventDuration,
      eventDurationUnit: eventDurationUnit ?? this.eventDurationUnit,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      clientName: clientName ?? this.clientName,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      clientPhone: clientPhone ?? this.clientPhone,
      coordinatorPhone: coordinatorPhone ?? this.coordinatorPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientImg: clientImg ?? this.clientImg,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      cancelledTasks: cancelledTasks ?? this.cancelledTasks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        clientPhone,
        eventName,
        description,
        eventDate,
        eventDuration,
        eventDurationUnit,
        location,
        budget,
        status,
        createdAt,
        coordinatorId,
        coordinatorName,
        coordinatorPhone,
        isDeleted,
        totalIncome,
        totalExpenses,
        netProfit,
        totalTasks,
        completedTasks,
        pendingTasks,
        cancelledTasks,
        imgUrl
      ];
}
