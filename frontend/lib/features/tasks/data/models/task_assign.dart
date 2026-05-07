// import '../../../../core/utils/number_toolse.dart';
// import '../../../coordinators/data/models/coordinator.dart';

// import '../../../../core/utils/string_toolse.dart';
// import '../../../../data/models/user.dart';
// import 'task.dart';

// class TaskAssign {
  
//   TaskAssign({
//     required this.id,
//     required this.taskId,
//     required this.userAssignId,
//     required this.coordinatorId,
//     required this.userAssignType,
//     this.description,
//     this.cost = 0.0,
//     this.notes,
//     this.urlImage,
//     this.reminderType,
//     this.reminderValue,
//     this.reminderUnit,
//   });

//   factory TaskAssign.fromJson(json) {
//     return TaskAssign(
//       id: NumberTools.tryParseInt(json, keys: ['id', 'task_assign_id']),
//       taskId: NumberTools.tryParseInt(json, keys: ['task_id', 'taskId']),
//       userAssignId: NumberTools.tryParseInt(json, keys: ['user_assign_id', 'userAssignId']),
//       coordinatorId: NumberTools.tryParseInt(json, keys: ['coordinator_id', 'coordinatorId']),
//       userAssignType: StrTools.tryParse(json, keys: ['user_assign_type', 'userAssignType']),
//       description: StrTools.tryParse(json, keys: ['description']),
//       cost: NumberTools.tryParseDouble(json, keys: ['cost']),
//       notes: StrTools.tryParse(json, keys: ['notes']),
//       urlImage: StrTools.tryParse(json, keys: ['url_image', 'urlImage']),
//       reminderType: StrTools.tryParse(json, keys: ['reminder_type', 'reminderType']),
//       reminderValue: NumberTools.tryParseInt(json, keys: ['reminder_value', 'reminderValue']),
//       reminderUnit: StrTools.tryParse(json, keys: ['reminder_unit', 'reminderUnit']),
//     );
//   }

//   toJson() {
//     return {
//       'id': id,
//       'task_id': taskId,
//       'user_assigne_id': userAssignId,
//       'coordinator_id': coordinatorId,
//       'user_assign_type': userAssignType,
//       if(description != null) 'description': description,
//       'cost': cost,
//       if(notes != null) 'notes': notes,
//       if(urlImage != null) 'url_image': urlImage,
//       if(reminderType != null) 'reminder_type': reminderType,
//       if(reminderValue != null) 'reminder_value': reminderValue,
//       if(reminderUnit != null) 'reminder_unit': reminderUnit,
//     };
//   }

//   TaskAssign copyWith({
//     int? id,
//     int? taskId,
//     int? userAssignId,
//     int? coordinatorId,
//     String? userAssignType,
//     String? description,
//     double? cost,
//     String? notes,
//     String? urlImage,
//     String? reminderType,
//     int? reminderValue,
//     String? reminderUnit,
//   }) {
//     return TaskAssign(
//       id: id ?? this.id,
//       taskId: taskId ?? this.taskId,
//       userAssignId: userAssignId ?? this.userAssignId,
//       coordinatorId: coordinatorId ?? this.coordinatorId,
//       userAssignType: userAssignType ?? this.userAssignType,
//       description: description ?? this.description,
//       cost: cost ?? this.cost,
//       notes: notes ?? this.notes,
//       urlImage: urlImage ?? this.urlImage,
//       reminderType: reminderType ?? this.reminderType,
//       reminderValue: reminderValue ?? this.reminderValue,
//       reminderUnit: reminderUnit ?? this.reminderUnit,
//     );
//   }
// }