
import '../../../../core/utils/number_toolse.dart';
import '../../../../core/utils/status.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/string_toolse.dart';

class Task extends Equatable {
  final int id;
  final int eventId;
  final int serviceId;
  final String eventName;
  final String? typeTask;
  final Status status; 
  final String? dateStart;
  final String? dateDue;
  final String? dateCompletion;
  final String createdAt;

  final int coordinatorId;
  final String takCreatorName;
  final int userAssignId;
  final String assignmentType;
  final String? assigneName;
  final String? description;
  final double cost;
  final String? notes;
  final String? urlImage;
  final String? reminderType;
  final int? reminderValue;
  final String? reminderUnit;
  final double adjustmentAmount;
  final String adjustmentType; // 'INCREASE', 'DECREASE', 'NONE'
  final double? rating;
  final String? ratingComment;
  final String? ratedAt;

  const Task({
    required this.id,
    required this.eventId,
    required this.serviceId,
    required this.eventName,
    this.typeTask,
    this.status = Status.PENDING,
    this.dateStart,
    this.dateDue,
    this.dateCompletion,
    this.createdAt = '',
    required this.coordinatorId,
    required this.takCreatorName,
    required this.userAssignId,
    required this.assignmentType,
    this.assigneName,
    this.description,
    this.cost = 0.0,
    this.adjustmentAmount = 0.0,
    this.adjustmentType = 'NONE',
    this.notes,
    this.urlImage,
    this.reminderType,
    this.reminderValue,
    this.reminderUnit,
    this.rating,
    this.ratingComment,
    this.ratedAt,
  });

  double get totalCost {
    if (adjustmentType == 'INCREASE') return cost + adjustmentAmount;
    if (adjustmentType == 'DECREASE') return cost - adjustmentAmount;
    return cost;
  }

  Task copyWith({
    int? id,
    int? eventId,
    int? serviceId,
    String? eventName,
    int? coordinatorId,
    String? creatorName,
    int? userAssignId,
    String? userAssignType,
    String? userAssignName,
    String? description,
    double? cost,
    double? adjustmentAmount,
    String? adjustmentType,
    String? notes,
    String? urlImage,
    String? reminderType,
    int? reminderValue,
    String? reminderUnit,
    double? rating,
    String? ratingComment,
    String? ratedAt,
    String? typeTask,
    Status? status,
    String? dateStart,
    String? dateDue,
    String? dateCompletion,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      serviceId: serviceId ?? this.serviceId,
      eventName: eventName ?? this.eventName,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      takCreatorName: creatorName ?? this.takCreatorName,
      userAssignId: userAssignId ?? this.userAssignId,
      assignmentType: userAssignType ?? this.assignmentType,
      assigneName: userAssignName ?? this.assigneName,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      adjustmentAmount: adjustmentAmount ?? this.adjustmentAmount,
      adjustmentType: adjustmentType ?? this.adjustmentType,
      notes: notes ?? this.notes,
      urlImage: urlImage ?? this.urlImage,
      reminderType: reminderType ?? this.reminderType,
      reminderValue: reminderValue ?? this.reminderValue,
      reminderUnit: reminderUnit ?? this.reminderUnit,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      ratedAt: ratedAt ?? this.ratedAt,
      typeTask: typeTask ?? this.typeTask,
      status: status ?? this.status,
      dateStart: dateStart ?? this.dateStart,
      dateDue: dateDue ?? this.dateDue,
      dateCompletion: dateCompletion ?? this.dateCompletion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: NumberTools.tryParseInt(json, keys: ['task_assign_id', 'task_id', 'id']),
      eventId: NumberTools.tryParseInt(json, keys: ['event_id', 'eventId']),
      typeTask: StrTools.tryParse(json, keys: ['type_task', 'typeTask']),
      notes: StrTools.tryParse(json, keys: ['notes']),
      serviceId: NumberTools.tryParseInt(json, keys: ['service_id', 'serviceId']),
      userAssignId: NumberTools.tryParseInt(json, keys: ['user_assign_id', 'userAssignId', 'assignee_id']),
      coordinatorId: NumberTools.tryParseInt(json, keys: ['coordinator_id', 'coordinatorId']),
      status: StatusTools.tryParse(json, keys: ['status', 'task_status']),
      description: StrTools.tryParse(json, keys: ['description', 'task_description']),
      cost: NumberTools.tryParseDouble(json, keys: ['cost']),
      adjustmentAmount: NumberTools.tryParseDouble(json, keys: ['adjustment_amount', 'adjustmentAmount']),
      adjustmentType: StrTools.tryParse(json, keys: ['adjustment_type', 'adjustmentType'], defaultV: 'NONE'),
      urlImage: StrTools.tryParse(json, keys: ['url_image', 'urlImage']),
      dateStart: StrTools.tryParse(json, keys: ['date_start', 'dateStart']),
      dateDue: StrTools.tryParse(json, keys: ['date_due', 'dateDue']),
      dateCompletion: StrTools.tryParse(json, keys: ['date_completion', 'dateCompletion']),
      reminderType: StrTools.tryParse(json, keys: ['reminder_type', 'reminderType']),
      reminderValue: NumberTools.tryParseInt(json, keys: ['reminder_value', 'reminderValue']),
      reminderUnit: StrTools.tryParse(json, keys: ['reminder_unit', 'reminderUnit']),
      eventName: StrTools.tryParse(json, keys: ['event_name', 'eventName']),
      takCreatorName: StrTools.tryParse(json, keys: ['task_creator_name', 'taskCreatorName']),
      assignmentType: StrTools.tryParse(json, keys: ['assignment_type', 'assignmentType']),
      assigneName: StrTools.tryParse(json, keys: ['assigne_name', 'assigneName']),
      rating: NumberTools.tryParseDouble(json, keys: ['rating', 'rating_value']),
      ratingComment: StrTools.tryParse(json, keys: ['evaluation_comment', 'evaluationComment', 'rating_comment']),
      ratedAt: StrTools.tryParse(json, keys: ['rated_at', 'ratedAt']),
      createdAt: StrTools.tryParse(json, keys: ['created_at', 'createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'service_id': serviceId,
      'coordinator_id': coordinatorId,
      'creator_name': takCreatorName,
      'user_assign_id': userAssignId,
      'user_assign_type': assignmentType,
      if (assigneName != null) 'user_assign_name': assigneName,
      if (description != null) 'description': description,
      'cost': cost,
      'adjustment_amount': adjustmentAmount,
      'adjustment_type': adjustmentType,
      if (notes != null) 'notes': notes,
      if(urlImage != null) 'url_image': urlImage,
      if(reminderType != null) 'reminder_type': reminderType,
      if(reminderValue != null) 'reminder_value': reminderValue,
      if(reminderUnit != null) 'reminder_unit': reminderUnit,
      if(rating != null) 'rating': rating,
      if(ratingComment != null) 'rating_comment': ratingComment,
      if(ratedAt != null) 'rated_at': ratedAt,
      if(typeTask != null) 'type_task': typeTask,
      'status': status.tryValue(),
      if(dateStart != null) 'date_start': dateStart,
      if(dateDue != null) 'date_due': dateDue,
      if(dateCompletion != null) 'date_completion': dateCompletion,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        eventName,
        typeTask,
        status,
        dateStart,
        dateDue,
        dateCompletion,
        createdAt,
        coordinatorId,
        takCreatorName,
        userAssignId,
        assignmentType,
        assigneName,
        description,
        cost,
        notes,
        urlImage,
        reminderType,
        reminderValue,
        reminderUnit,
        rating,
        ratingComment,
        ratedAt,
      ];
}
