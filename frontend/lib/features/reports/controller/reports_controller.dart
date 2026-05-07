import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel_pkg;

// استيرادات النماذج والتحكمات الخاصة بك
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/translate_duration_unit.dart';
import '../../../core/utils/status.dart';
import '../../clients/data/models/client.dart';
import '../../events/controller/event_controller.dart';
import '../../events/data/models/event.dart';
import '../../incomes/data/models/income.dart';
import '../../suppliers/data/models/supplier.dart';
import '../../tasks/controller/task_controller.dart';
import '../../incomes/controller/income_controller.dart';
import '../../clients/controller/client_controller.dart';
import '../../suppliers/controller/supplier_controller.dart';
import '../../tasks/data/models/task.dart';
import '../../../core/themes/app_colors.dart';


// ==============================
// 1. ثوابت وأدوات مساعدة (Helpers)
// ==============================

/// ثوابت أنماط Excel المركزية
class ExcelStyles {
  static const String primaryColor = "#34495E";
  static const String secondaryColor = "#D5D8DC";
  static const String accentColor = "#2E86C1";
  static const String white = "#FFFFFF";
  static const String biHeaderColor = "#2C3E50";
  static const String biSubHeaderColor = "#ECF0F1";

  static excel_pkg.CellStyle get titleStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(primaryColor),
        fontColorHex: excel_pkg.ExcelColor.fromHexString(white),
        bold: true,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
        fontSize: 20,
      );

  static excel_pkg.CellStyle get dateHeaderStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(primaryColor),
        fontColorHex: excel_pkg.ExcelColor.fromHexString(white),
        bold: false,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
        fontSize: 16,
      );

  static excel_pkg.CellStyle get dateValueStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(primaryColor),
        fontColorHex: excel_pkg.ExcelColor.fromHexString(white),
        bold: false,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
        fontSize: 10,
      );

  static excel_pkg.CellStyle get summaryHeaderStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(secondaryColor),
        bold: true,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
      );

  static excel_pkg.CellStyle get columnHeaderStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(accentColor),
        fontColorHex: excel_pkg.ExcelColor.fromHexString(white),
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
        bold: true,
      );

  static excel_pkg.CellStyle get dataCellStyle => excel_pkg.CellStyle(
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
      );

  static excel_pkg.CellStyle get biHeaderStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(biHeaderColor),
        fontColorHex: excel_pkg.ExcelColor.fromHexString(white),
        bold: true,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
      );

  static excel_pkg.CellStyle get biSubHeaderStyle => excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString(biSubHeaderColor),
        bold: true,
        fontColorHex: excel_pkg.ExcelColor.fromHexString(biHeaderColor),
      );



  static excel_pkg.CellStyle get cardTitleStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"), // أزرق داكن
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#FFFFFF"),
    bold: true,
    horizontalAlign: excel_pkg.HorizontalAlign.Center,
    verticalAlign: excel_pkg.VerticalAlign.Center,
    fontSize: 18,
  );

  static excel_pkg.CellStyle get cardSubtitleStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#D6E4F0"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"),
    italic: true,
    horizontalAlign: excel_pkg.HorizontalAlign.Center,
    verticalAlign: excel_pkg.VerticalAlign.Center,
    fontSize: 10,
  );

  static excel_pkg.CellStyle get labelStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#F2F2F2"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#333333"),
    bold: true,
    horizontalAlign: excel_pkg.HorizontalAlign.Left,
    verticalAlign: excel_pkg.VerticalAlign.Center,
    fontSize: 12,
  );

  static excel_pkg.CellStyle get valueStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#FFFFFF"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#000000"),
    horizontalAlign: excel_pkg.HorizontalAlign.Left,
    verticalAlign: excel_pkg.VerticalAlign.Center,
    fontSize: 12,
  );

  static excel_pkg.CellStyle get footerStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#E6F0FA"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"),
    italic: true,
    horizontalAlign: excel_pkg.HorizontalAlign.Center,
    verticalAlign: excel_pkg.VerticalAlign.Center,
    fontSize: 9,
  );

  /// Helper to safe parse date strings
  static DateTime? safeParseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return null;
    }
  }

  static String formatDate(String? dateStr) {
    final date = safeParseDate(dateStr);
    return date != null ? date.toString().split('.')[0] : '';
  }



  static excel_pkg.CellStyle get logoStyle => excel_pkg.CellStyle(
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"),
    bold: true,
    italic: true,
    fontSize: 14,
    horizontalAlign: excel_pkg.HorizontalAlign.Left,
  );

  static excel_pkg.CellStyle get idStyle => excel_pkg.CellStyle(
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#7F8C8D"),
    italic: true,
    fontSize: 9,
    horizontalAlign: excel_pkg.HorizontalAlign.Right,
  );

  static excel_pkg.CellStyle get sectionHeaderStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#D6E4F0"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"),
    bold: true,
    fontSize: 14,
    horizontalAlign: excel_pkg.HorizontalAlign.Left,
  );

  static excel_pkg.CellStyle get subTableHeaderStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#BFD9E8"),
    fontColorHex: excel_pkg.ExcelColor.fromHexString("#1F4E79"),
    bold: true,
    horizontalAlign: excel_pkg.HorizontalAlign.Center,
  );

  static excel_pkg.CellStyle get alternatingRowStyle => excel_pkg.CellStyle(
    backgroundColorHex: excel_pkg.ExcelColor.fromHexString("#F9FBFD"),
    horizontalAlign: excel_pkg.HorizontalAlign.Left,
  );
}

/// إضافة دوال مساعدة على excel_pkg.Sheet لتجنب تكرار الكود
extension ExcelSheetExtension on excel_pkg.Sheet {
  void mergeAndStyle({
    required excel_pkg.CellIndex start,
    required excel_pkg.CellIndex end,
    required String value,
    required excel_pkg.CellStyle style,
  }) {
    merge(start, end, customValue: excel_pkg.TextCellValue(value));
    cell(start).cellStyle = style;
  }

  void applyRowStyle(int rowIndex, int columnCount, excel_pkg.CellStyle style) {
    for (int col = 0; col < columnCount; col++) {
      cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex)).cellStyle = style;
    }
  }
}

// ==============================
// 2. خدمات حساب الإحصائيات (Statistic Calculators)
// ==============================

class EventStatistics {
  static Map<String, dynamic> compute(List<Event> events) {
    double totalBudget = 0;
    double totalExpenses = 0;
    double totalPayments = 0;
    int completed = 0, pending = 0, inProgress = 0, cancelled = 0;

    for (var e in events) {
      totalBudget += e.budget;
      totalExpenses += e.totalExpenses;
      totalPayments += e.totalIncome;
      if (e.status.isCompleted) { completed++; }
      else if (e.status.isPending) { pending++; }
      else if (e.status.isInProgress) { inProgress++; }
      else if (e.status.isCancelled) { cancelled++; }
    }

    return {
      'total': events.length,
      'completed': completed,
      'pending': pending,
      'inProgress': inProgress,
      'cancelled': cancelled,
      'totalBudget': totalBudget,
      'totalExpenses': totalExpenses,
      'totalPayments': totalPayments,
    };
  }

  static Map<String, dynamic> detailedStats(Event event, List<Task> allTasks) {
    final eventTasks = allTasks.where((t) => t.eventId == event.id).toList();
    Map<Status, int> counts = {};
    Map<Status, double> costs = {};
    
    for (var status in Status.values) {
      counts[status] = 0;
      costs[status] = 0.0;
    }

    for (var t in eventTasks) {
      counts[t.status] = (counts[t.status] ?? 0) + 1;
      costs[t.status] = (costs[t.status] ?? 0) + t.cost;
    }

    return {
      'counts': counts,
      'costs': costs,
    };
  }
}

class TaskStatistics {
  static Map<String, dynamic> compute(List<Task> tasks) {
    double totalExpenses = 0;
    int completed = 0, inProgress = 0, pending = 0, cancelled = 0, rejected = 0, inReview = 0;

    for (var t in tasks) {
      totalExpenses += t.status == Status.CANCELLED ? 0 : t.cost;
      if (t.status.isCompleted) { completed++; }
      else if (t.status.isInProgress) { inProgress++; }
      else if (t.status.isPending) { pending++; }
      else if (t.status.isCancelled) { cancelled++; }
      else if (t.status.isRejected) { rejected++; }
      else if (t.status.isUnderReview) { inReview++; }
    }

    return {
      'total': tasks.length,
      'completed': completed,
      'inProgress': inProgress,
      'pending': pending,
      'cancelled': cancelled,
      'rejected': rejected,
      'inReview': inReview,
      'totalExpenses': totalExpenses,
    };
  }
}

class SupplierStatistics {
  static Map<String, dynamic> compute(List<Supplier> suppliers) {
    return {'total': suppliers.length};
  }

  static Map<String, dynamic> detailedStats(Supplier supplier, List<Task> allTasks, List<Event> allEvents) {
    final tasks = allTasks.where((t) => t.userAssignId == supplier.id).toList();
    Map<String, int> taskCounts = {
      'total': tasks.length,
      'completed': 0,
      'inProgress': 0,
      'pending': 0,
      'cancelled': 0,
      'rejected': 0,
      'inReview': 0,
    };
    Map<String, double> taskCosts = {
      'total': 0,
      'completed': 0,
      'inProgress': 0,
      'pending': 0,
      'cancelled': 0,
      'rejected': 0,
      'inReview': 0,
    };
    Set<int> eventIds = {};
    Map<Status, Set<int>> eventsByStatus = {
      Status.PENDING: {},
      Status.IN_PROGRESS: {},
      Status.COMPLETED: {},
      Status.CANCELLED: {},
    };

    for (var t in tasks) {
      taskCosts['total'] = (taskCosts['total'] ?? 0) + t.cost;
      eventIds.add(t.eventId);
      final event = allEvents.firstWhereOrNull((e) => e.id == t.eventId);
      if (event != null) eventsByStatus[event.status]?.add(event.id);

      if (t.status.isCompleted) {
        taskCounts['completed'] = (taskCounts['completed'] ?? 0) + 1;
        taskCosts['completed'] = (taskCosts['completed'] ?? 0) + t.cost;
      } else if (t.status.isInProgress) {
        taskCounts['inProgress'] = (taskCounts['inProgress'] ?? 0) + 1;
        taskCosts['inProgress'] = (taskCosts['inProgress'] ?? 0) + t.cost;
      } else if (t.status.isPending) {
        taskCounts['pending'] = (taskCounts['pending'] ?? 0) + 1;
        taskCosts['pending'] = (taskCosts['pending'] ?? 0) + t.cost;
      } else if (t.status.isCancelled) {
        taskCounts['cancelled'] = (taskCounts['cancelled'] ?? 0) + 1;
        taskCosts['cancelled'] = (taskCosts['cancelled'] ?? 0) + t.cost;
      } else if (t.status.isRejected) {
        taskCounts['rejected'] = (taskCounts['rejected'] ?? 0) + 1;
        taskCosts['rejected'] = (taskCosts['rejected'] ?? 0) + t.cost;
      } else if (t.status.isUnderReview) {
        taskCounts['inReview'] = (taskCounts['inReview'] ?? 0) + 1;
        taskCosts['inReview'] = (taskCosts['inReview'] ?? 0) + t.cost;
      }
    }

    return {
      'taskCounts': taskCounts,
      'taskCosts': taskCosts,
      'totalEvents': eventIds.length,
      'eventsPending': eventsByStatus[Status.PENDING]?.length ?? 0,
      'eventsInProgress': eventsByStatus[Status.IN_PROGRESS]?.length ?? 0,
      'eventsCompleted': eventsByStatus[Status.COMPLETED]?.length ?? 0,
      'eventsCancelled': eventsByStatus[Status.CANCELLED]?.length ?? 0,
      'servicesCount': supplier.services.length,
    };
  }
}

class FinancialStatistics {
  static Map<String, dynamic> compute(List<Event> events, List<Income> incomes, List<Task> tasks) {
    double totalBudget = events.fold(0.0, (sum, e) => sum + e.budget);
    double totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
    double totalExpenses = tasks.fold(0.0, (sum, t) => sum + t.cost);
    double remaining = totalBudget - totalExpenses;
    double profit = totalIncome - totalExpenses;
    double loss = profit < 0 ? profit.abs() : 0;
    if (profit < 0) profit = 0;

    return {
      'totalBudget': totalBudget,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalRemaining': remaining,
      'totalLoss': loss,
      'totalProfit': profit,
    };
  }
}

// ==============================
// 3. خدمة تصدير Excel (Export Service)
// ==============================

class ExcelExportService {
  static Future<void> exportBIReport({
    required String reportScope,
    required String timeFilter,
    required double totalRevenue,
    required double totalExpenses,
    required double netProfit,
    required double taskSuccessRate,
    required double budgetAdherence,
    required Map<String, int> taskStatsMap,
    required List<Event> events,
    required List<Task> tasks,
  }) async {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()]!;

    // العنوان
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A1'),
      end: excel_pkg.CellIndex.indexByString('D1'),
      value: 'تقرير ذكاء الأعمال My Party',
      style: ExcelStyles.biHeaderStyle,
    );

    sheet.appendRow([excel_pkg.TextCellValue('النطاق:'), excel_pkg.TextCellValue(reportScope)]);
    sheet.appendRow([excel_pkg.TextCellValue('فترة التقرير:'), excel_pkg.TextCellValue(timeFilter)]);
    sheet.appendRow([excel_pkg.TextCellValue('')]);

    // الملخص المالي
    sheet.appendRow([excel_pkg.TextCellValue('-- الملخص المالي والتنفيذي --')]);
    sheet.appendRow([excel_pkg.TextCellValue('إجمالي الإيرادات'), excel_pkg.TextCellValue('${totalRevenue.toStringAsFixed(2)} ر.س')]);
    sheet.appendRow([excel_pkg.TextCellValue('إجمالي التكاليف (المهام)'), excel_pkg.TextCellValue('${totalExpenses.toStringAsFixed(2)} ر.س')]);
    sheet.appendRow([excel_pkg.TextCellValue('صافي الربح'), excel_pkg.TextCellValue('${netProfit.toStringAsFixed(2)} ر.س')]);
    sheet.appendRow([excel_pkg.TextCellValue('نسبة نجاح المهام'), excel_pkg.TextCellValue('${taskSuccessRate.toStringAsFixed(1)}%')]);
    sheet.appendRow([excel_pkg.TextCellValue('نسبة الاستهلاك من الميزانية'), excel_pkg.TextCellValue('${budgetAdherence.toStringAsFixed(1)}%')]);
    sheet.appendRow([excel_pkg.TextCellValue('')]);
    sheet.appendRow([
      excel_pkg.TextCellValue('حالة المهام التفصيلية'),
      excel_pkg.TextCellValue(
        'قيد الانتظار: ${taskStatsMap['pending']} | قيد التنفيذ: ${taskStatsMap['in_progress']} | مكتملة: ${taskStatsMap['completed']} | ملغاة: ${taskStatsMap['cancelled']}'
      )
    ]);

    // جدول المناسبات
    if (events.isNotEmpty) {
      sheet.appendRow([excel_pkg.TextCellValue('')]);
      sheet.appendRow([excel_pkg.TextCellValue('تفاصيل المناسبات المدرجة')]);
      final headerRow = sheet.maxRows;
      sheet.appendRow([
        excel_pkg.TextCellValue('العنوان'),
        excel_pkg.TextCellValue('الحالة'),
        excel_pkg.TextCellValue('الميزانية المعتمدة'),
        excel_pkg.TextCellValue('التاريخ')
      ]);
      sheet.applyRowStyle(headerRow, 4, ExcelStyles.biSubHeaderStyle);

      for (var ev in events) {
        sheet.appendRow([
          excel_pkg.TextCellValue(ev.eventName),
          excel_pkg.TextCellValue(ev.status.name),
          excel_pkg.TextCellValue('${ev.budget} ر.س'),
          excel_pkg.TextCellValue(ev.eventDate)
        ]);
      }
    }

    // جدول المهام
    if (tasks.isNotEmpty) {
      sheet.appendRow([excel_pkg.TextCellValue('')]);
      sheet.appendRow([excel_pkg.TextCellValue('تفاصيل المهام المدرجة')]);
      final headerRow = sheet.maxRows;
      sheet.appendRow([
        excel_pkg.TextCellValue('نوع المهمة'),
        excel_pkg.TextCellValue('الوصف'),
        excel_pkg.TextCellValue('التكلفة'),
        excel_pkg.TextCellValue('الحالة')
      ]);
      sheet.applyRowStyle(headerRow, 4, ExcelStyles.biSubHeaderStyle);

      for (var t in tasks) {
        sheet.appendRow([
          excel_pkg.TextCellValue(t.typeTask ?? ''),
          excel_pkg.TextCellValue(t.description ?? ''),
          excel_pkg.TextCellValue('${t.cost} ر.س'),
          excel_pkg.TextCellValue(t.status.name)
        ]);
      }
    }

    await _saveAndShare(excel, 'BI_Report');
  }

  static Future<void> exportTabReport({
    required String tabName,
    required Map<String, dynamic> stats,
    required List<dynamic> items, // يمكن أن تكون Event, Task, Supplier
    required List<String> headers,
    required List<String> Function(dynamic) rowBuilder,
    bool isSupplier = false,
  }) async {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()]!;
    int currentRow = 0;

    // عنوان رئيسي
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A1'),
      end: excel_pkg.CellIndex.indexByString('P1'),
      value: 'تقرير بيانات $tabName',
      style: ExcelStyles.titleStyle,
    );
    currentRow++;

    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A2'),
      end: excel_pkg.CellIndex.indexByString('P2'),
      value: 'تاريخ التصدير:',
      style: ExcelStyles.dateHeaderStyle,
    );
    currentRow++;

    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A3'),
      end: excel_pkg.CellIndex.indexByString('P3'),
      value: DateTime.now().toString(),
      style: ExcelStyles.dateValueStyle,
    );
    currentRow++;
    sheet.appendRow([excel_pkg.TextCellValue('')]);
    currentRow++;

    // قسم الإحصائيات
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A$currentRow'),
      end: excel_pkg.CellIndex.indexByString('P$currentRow'),
      value: '-- إحصائيات إجمالية --',
      style: ExcelStyles.summaryHeaderStyle,
    );
    currentRow++;

    // صفوف الإحصائيات - بناء ديناميكي
    if (tabName == 'المناسبات') {
      _addStatsRow(sheet, [
        'إجمالي المناسبات:', 'قيد الإنتظار:', 'قيد التنفيذ:', 'مكتملة:', 'ملغاة:',
        'إجمالي الميزانية:', 'إجمالي المصروفات:', 'إجمالي الدفعات:'
      ], [
        '${stats['total']}', '${stats['pending']}', '${stats['inProgress']}', '${stats['completed']}',
        '${stats['cancelled']}', '${stats['totalBudget'].toStringAsFixed(2)}',
        '${stats['totalExpenses'].toStringAsFixed(2)}', '${stats['totalPayments'].toStringAsFixed(2)}'
      ], sheet.maxRows);
      currentRow += 2;
    } else if (tabName == 'المهام') {
      _addStatsRow(sheet, [
        'إجمالي المهام:', 'قيد الإنتظار:', 'قيد التنفيذ:', 'قيد المراجعة:', 'مكتملة:',
        'ملغاة:', 'مرفوضة:', 'إجمالي التكاليف:'
      ], [
        '${stats['total']}', '${stats['pending']}', '${stats['inProgress']}', '${stats['inReview']}',
        '${stats['completed']}', '${stats['cancelled']}', '${stats['rejected']}',
        '${stats['totalExpenses'].toStringAsFixed(2)}'
      ], sheet.maxRows);
      currentRow += 2;
    } else if (tabName == 'الموردين') {
      sheet.appendRow([excel_pkg.TextCellValue('إجمالي الموردين المدرجين:'), excel_pkg.TextCellValue('${stats['total']}')]);
      currentRow++;
    }
    sheet.appendRow([excel_pkg.TextCellValue('')]);
    currentRow++;

    // جدول البيانات
    final headerRowIndex = sheet.maxRows;
    sheet.appendRow(headers.map((h) => excel_pkg.TextCellValue(h)).toList());
    sheet.applyRowStyle(headerRowIndex, headers.length, ExcelStyles.columnHeaderStyle);

    for (var item in items) {
      final rowValues = rowBuilder(item);
      sheet.appendRow(rowValues.map((v) => excel_pkg.TextCellValue(v)).toList());
      sheet.applyRowStyle(sheet.maxRows - 1, headers.length, ExcelStyles.dataCellStyle);
    }

    await _saveAndShare(excel, '${tabName}_Report');
  }

  static void _addStatsRow(excel_pkg.Sheet sheet, List<String> headers, List<String> values, int startRow) {
    sheet.appendRow(headers.map((h) => excel_pkg.TextCellValue(h)).toList());
    sheet.applyRowStyle(startRow, headers.length, ExcelStyles.columnHeaderStyle);
    sheet.appendRow(values.map((v) => excel_pkg.TextCellValue(v)).toList());
    sheet.applyRowStyle(startRow + 1, values.length, ExcelStyles.dataCellStyle);
  }

  static Future<void> exportSingleItem({
    required String title,
    required String itemType, // 'Event', 'Task', 'Supplier'
    required List<MapEntry<String, String>> basicFields,
    Map<String, dynamic>? advancedStats,
    List<Map<String, String>>? subTableRows,
    String? subTableTitle,
    String? notes,
  }) async {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()]!;
    int currentRow = 0;

    // ========== HEADER ==========
    // الصف 0: شعار (نصي) على اليسار ومعرف التقرير على اليمين
    final logoCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0,rowIndex: currentRow));
    logoCell.value = excel_pkg.TextCellValue('My Party');
    logoCell.cellStyle = ExcelStyles.logoStyle;

    final idCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 3,rowIndex: currentRow));
    idCell.value = excel_pkg.TextCellValue('رقم: ${DateTime.now().millisecondsSinceEpoch}');
    idCell.cellStyle = ExcelStyles.idStyle;
    currentRow++;

    // الصف 1: عنوان التقرير (مدمج)
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
      end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
      value: title,
      style: ExcelStyles.cardTitleStyle,
    );
    currentRow++;

    // الصف 2: تاريخ التصدير
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
      end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
      value: 'تاريخ التصدير: ${DateTime.now().toString()}',
      style: ExcelStyles.cardSubtitleStyle,
    );
    currentRow++;

    // سطر فارغ
    sheet.appendRow([excel_pkg.TextCellValue('')]);
    currentRow++;

    // ========== BASIC INFO CARD ==========
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
      end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
      value: '📋 المعلومات الأساسية',
      style: ExcelStyles.sectionHeaderStyle,
    );
    currentRow++;

    for (int i = 0; i < basicFields.length; i++) {
      final rowIdx = currentRow + i;
      final labelCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0,rowIndex: rowIdx));
      labelCell.value = excel_pkg.TextCellValue(basicFields[i].key);
      labelCell.cellStyle = ExcelStyles.labelStyle;

      final valueCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1,rowIndex: rowIdx));
      valueCell.value = excel_pkg.TextCellValue(basicFields[i].value);
      valueCell.cellStyle = ExcelStyles.valueStyle;
    }
    currentRow += basicFields.length;
    sheet.appendRow([excel_pkg.TextCellValue('')]);
    currentRow++;

    // ========== ADVANCED STATISTICS SECTION ==========
    if (advancedStats != null && advancedStats.isNotEmpty) {
      sheet.mergeAndStyle(
        start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
        end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
        value: '📊 إحصائيات تفصيلية',
        style: ExcelStyles.sectionHeaderStyle,
      );
      currentRow++;

      final statEntries = advancedStats.entries.toList();
      for (int i = 0; i < statEntries.length; i++) {
        final rowIdx = currentRow + i;
        final labelCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0,rowIndex: rowIdx));
        labelCell.value = excel_pkg.TextCellValue(statEntries[i].key);
        labelCell.cellStyle = ExcelStyles.labelStyle;

        final valueCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1,rowIndex: rowIdx));
        valueCell.value = excel_pkg.TextCellValue(statEntries[i].value.toString());
        valueCell.cellStyle = ExcelStyles.valueStyle;
      }
      currentRow += statEntries.length;
      sheet.appendRow([excel_pkg.TextCellValue('')]);
      currentRow++;
    }

    // ========== SUB TABLE (e.g., Tasks, Services) ==========
    if (subTableRows != null && subTableRows.isNotEmpty && subTableTitle != null) {
      sheet.mergeAndStyle(
        start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
        end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
        value: subTableTitle,
        style: ExcelStyles.sectionHeaderStyle,
      );
      currentRow++;

      // عناوين الأعمدة (نأخذها من أول صف)
      final headers = subTableRows.first.keys.toList();
      for (int col = 0; col < headers.length; col++) {
        final headerCell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col,rowIndex: currentRow));
        headerCell.value = excel_pkg.TextCellValue(headers[col]);
        headerCell.cellStyle = ExcelStyles.subTableHeaderStyle;
      }
      currentRow++;

      // البيانات
      for (int row = 0; row < subTableRows.length; row++) {
        final rowData = subTableRows[row];
        for (int col = 0; col < headers.length; col++) {
          final cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col,rowIndex: currentRow + row));
          cell.value = excel_pkg.TextCellValue(rowData[headers[col]] ?? '');
          cell.cellStyle = (row % 2 == 0) ? ExcelStyles.alternatingRowStyle : ExcelStyles.valueStyle;
        }
      }
      currentRow += subTableRows.length;
      sheet.appendRow([excel_pkg.TextCellValue('')]);
      currentRow++;
    }

    // ========== NOTES / FOOTER ==========
    if (notes != null && notes.isNotEmpty) {
      sheet.mergeAndStyle(
        start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
        end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
        value: '📝 ملاحظات: $notes',
        style: ExcelStyles.footerStyle,
      );
      currentRow++;
      sheet.appendRow([excel_pkg.TextCellValue('')]);
      currentRow++;
    }

    // تذييل الشكر
    sheet.mergeAndStyle(
      start: excel_pkg.CellIndex.indexByString('A${currentRow + 1}'),
      end: excel_pkg.CellIndex.indexByString('D${currentRow + 1}'),
      value: 'شكراً لاستخدامك نظام My Party - تم إنشاء هذا التقرير بواسطة النظام الآلي',
      style: ExcelStyles.footerStyle,
    );

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 50);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);

    await _saveAndShare(excel, 'Detailed_${itemType}_${DateTime.now().millisecondsSinceEpoch}');
  }
  
  static Future<void> _saveAndShare(excel_pkg.Excel excel, String baseFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${directory.path}/$fileName';
    final fileBytes = excel.save();
    if (fileBytes == null) throw Exception('فشل حفظ ملف Excel');
    final file = dart_io.File(path);
    await file.writeAsBytes(fileBytes);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(path)],
      text: 'تقرير $baseFileName',
    ));
    // await Share.shareXFiles([XFile(path)], text: 'تقرير $baseFileName');
  }
}

// ==============================
// 4. الـ Controller الرئيسي (ReportsController)
// ==============================

class ReportsController extends GetxController {
  // الاعتماديات
  late final EventController eventController;
  late final TaskController taskController;
  late final IncomeController incomeController;
  late final ClientController clientController;
  late final SupplierController supplierController;

  // حالة الـ UI
  final isLoading = false.obs;
  final RxString selectedTimeFilter = 'الكل'.obs;
  final Rxn<DateTimeRange> customDateRange = Rxn<DateTimeRange>();
  final RxString reportScope = 'عام'.obs;
  final RxnInt selectedScopeId = RxnInt();

  // متغيرات البحث
  final RxString eventsSearchQuery = ''.obs;
  final RxString tasksSearchQuery = ''.obs;
  final RxString suppliersSearchQuery = ''.obs;
  final RxString financialSearchQuery = ''.obs;
  final RxInt collapseKey = 0.obs;

  final RxList<dynamic> ratingsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchDetailedData();
  }

  void _initializeControllers() {
    eventController = Get.put(EventController());
    taskController = Get.put(TaskController());
    incomeController = Get.put(IncomeController());
    clientController = Get.put(ClientController());
    supplierController = Get.put(SupplierController());
  }

  Future<void> fetchDetailedData() async {
    try {
      final res = await Get.find<ApiService>().get('${ApiEndpoints.dashboard}/ratings');
      if (res != null && res is Map && (res['result'] != null || res['data'] != null)) {
        ratingsList.value = res['result'] ?? res['data'];
      }
    } catch (e) {
      // تجاهل الأخطاء مؤقتاً
    }
  }

  Future<void> refreshStatistics() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    await fetchDetailedData();
    isLoading.value = false;
  }

  void collapseAll() {
    collapseKey.value++;
  }

  // ============== 5. دوال التصفية (Filtering Logic) ==============

  List<Event> get filteredEvents {
    var raw = eventController.events.toList();
    if (reportScope.value == 'لعميل محدد' && selectedScopeId.value != null) {
      raw = raw.where((e) => e.clientId == selectedScopeId.value).toList();
    } else if (reportScope.value == 'لمناسبة محددة' && selectedScopeId.value != null) {
      raw = raw.where((e) => e.id == selectedScopeId.value).toList();
    }
    return _applyTimeFilter<Event>(raw, dateGetter: (e) => ExcelStyles.safeParseDate(e.eventDate));
  }

  List<Task> get filteredTasks {
    final events = eventController.events;
    var raw = taskController.tasks.toList();
    if (reportScope.value == 'لمناسبة محددة' && selectedScopeId.value != null) {
      raw = raw.where((t) => t.eventId == selectedScopeId.value).toList();
    } else if (reportScope.value == 'لمورد محدد' && selectedScopeId.value != null) {
      raw = raw.where((t) => t.userAssignId == selectedScopeId.value).toList();
    }
    raw = raw.where((task) {
      final event = events.firstWhereOrNull((e) => e.id == task.eventId);
      return event != null && !event.status.isCancelled;
    }).toList();
    return _applyTimeFilter<Task>(raw, dateGetter: (t) => ExcelStyles.safeParseDate(t.dateStart));
  }

  List<Income> get filteredIncomes {
    var raw = incomeController.incomes.toList();
    if (reportScope.value == 'لمناسبة محددة' && selectedScopeId.value != null) {
      raw = raw.where((i) => i.eventId == selectedScopeId.value).toList();
    }
    return _applyTimeFilter<Income>(raw, dateGetter: (i) => ExcelStyles.safeParseDate(i.paymentDate));
  }

  List<Client> get filteredClients {
    if (reportScope.value == 'لعميل محدد' && selectedScopeId.value != null) {
      return clientController.clients.where((c) => c.id == selectedScopeId.value).toList();
    }
    return _applyTimeFilter<Client>(clientController.clients.toList(), dateGetter: (c) => ExcelStyles.safeParseDate(c.createdAt));
  }

  List<Supplier> get filteredSuppliers {
    if (reportScope.value == 'لمورد محدد' && selectedScopeId.value != null) {
      return supplierController.suppliers.where((s) => s.id == selectedScopeId.value).toList();
    }
    return _applyTimeFilter<Supplier>(supplierController.suppliers.toList(), dateGetter: (s) => ExcelStyles.safeParseDate(s.createdAt));
  }

  List<T> _applyTimeFilter<T>(List<T> list, {required DateTime? Function(T) dateGetter}) {
    if (selectedTimeFilter.value == 'الكل') return list;

    final now = DateTime.now();
    return list.where((item) {
      final date = dateGetter(item);
      if (date == null) return false;

      if (selectedTimeFilter.value == 'مخصص' && customDateRange.value != null) {
        return date.isAfter(customDateRange.value!.start.subtract(const Duration(days: 1))) &&
               date.isBefore(customDateRange.value!.end.add(const Duration(days: 1)));
      }

      final diff = now.difference(date).abs();
      switch (selectedTimeFilter.value) {
        case 'يومي': return diff.inDays == 0 && now.day == date.day;
        case 'أسبوعي': return diff.inDays <= 7;
        case 'شهري': return diff.inDays <= 30;
        case 'سنوي': return diff.inDays <= 365;
        default: return true;
      }
    }).toList();
  }

  // ============== 6. البيانات المعروضة في التبويبات (Display Data) ==============

  List<Event> get displayEvents {
    var list = filteredEvents;
    if (eventsSearchQuery.value.isNotEmpty) {
      list = list.where((e) => e.eventName.toLowerCase().contains(eventsSearchQuery.value.toLowerCase())).toList();
    }
    return list;
  }

  Map<String, dynamic> get eventStats => EventStatistics.compute(filteredEvents);

  int getSuppliersCountForEvent(int eventId) {
    final tasks = taskController.tasks.where((t) => t.eventId == eventId).toList();
    return tasks.map((t) => t.userAssignId).toSet().length;
  }

  List<Task> get displayTasks {
    var list = filteredTasks;
    if (tasksSearchQuery.value.isNotEmpty) {
      final query = tasksSearchQuery.value.toLowerCase();
      list = list.where((t) =>
        (t.typeTask ?? '').toLowerCase().contains(query) ||
        (t.assigneName ?? '').toLowerCase().contains(query)
      ).toList();
    }
    return list;
  }

  Map<String, dynamic> get taskStats => TaskStatistics.compute(filteredTasks);

  List<Supplier> get displaySuppliers {
    final tasks = taskController.tasks;
    var list = filteredSuppliers.where((s) => tasks.any((t) => t.userAssignId == s.id)).toList();
    if (suppliersSearchQuery.value.isNotEmpty) {
      list = list.where((s) => s.name.toLowerCase().contains(suppliersSearchQuery.value.toLowerCase())).toList();
    }
    return list;
  }

  Map<String, dynamic> get supplierStats => SupplierStatistics.compute(displaySuppliers);

  Map<String, dynamic> getEventDetailedStats(Event event) {
    return EventStatistics.detailedStats(event, taskController.tasks);
  }

  Map<String, dynamic> getSupplierDetailedStats(Supplier supplier) {
    return SupplierStatistics.detailedStats(supplier, taskController.tasks, eventController.events);
  }

  Map<String, dynamic> get financialStats {
    return FinancialStatistics.compute(filteredEvents, filteredIncomes, filteredTasks);
  }

  // ============== 7. مؤشرات سريعة (Quick KPIs) ==============

  double get calculatedTotalRevenue {
    return filteredIncomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  double get calculatedTotalExpenses {
    return filteredTasks.fold(0.0, (sum, t) => sum + t.cost);
  }

  double get netProfit => calculatedTotalRevenue - calculatedTotalExpenses;

  double get taskSuccessRate {
    final tasks = filteredTasks;
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.status.isCompleted).length;
    return (completed / tasks.length) * 100;
  }

  double get budgetAdherence {
    final totalBudgets = filteredEvents.fold(0.0, (sum, e) => sum + e.budget);
    if (totalBudgets == 0) return 0.0;
    return (calculatedTotalExpenses / totalBudgets) * 100;
  }

  Map<String, int> get calculatedTaskStats {
    int pending = 0, ongoing = 0, completed = 0, cancelled = 0;
    for (var t in filteredTasks) {
      if (t.status.isCompleted) { completed++; }
      else if (t.status.isInProgress) { ongoing++; }
      else if (t.status.isCancelled) { cancelled++; }
      else { pending++; }
    }
    return {'pending': pending, 'in_progress': ongoing, 'completed': completed, 'cancelled': cancelled};
  }

  // ============== 8. دوال التصدير (Export Functions) ==============

  Future<void> exportReport(String type, {String? tabName}) async {
    try {
      if (tabName != null) {
        await _exportTabReport(tabName);
      } 
      else {
        await _exportBIReport();
      }
    } catch (e) {
      _showErrorSnackbar('فشل تصدير التقرير: $tabName $e');
    }
  }

  Future<void> _exportBIReport() async {
    await ExcelExportService.exportBIReport(
      reportScope: reportScope.value,
      timeFilter: selectedTimeFilter.value,
      totalRevenue: calculatedTotalRevenue,
      totalExpenses: calculatedTotalExpenses,
      netProfit: netProfit,
      taskSuccessRate: taskSuccessRate,
      budgetAdherence: budgetAdherence,
      taskStatsMap: calculatedTaskStats,
      events: filteredEvents,
      tasks: filteredTasks,
    );
  }

  Future<void> _exportTabReport(String tabName) async {
    if (tabName == 'المناسبات') {
      await ExcelExportService.exportTabReport(
        tabName: tabName,
        stats: eventStats,
        items: displayEvents,
        headers: const [
          'العنوان', 'اسم العميل', 'البريد', 'الهاتف', 'الحالة', 'الميزانية', 'إجمالي المصروفات', 'إجمالي الدفعات',
          'المتبقي على العميل', 'الربح المتوقع', 'الربح الفعلي', 'نسبة الإنجاز',
          'إجمالي المهام', 'المكتملة', 'قيد التنفيذ', 'قيد الانتظار', 'الملغاة',
          'المدة', 'التاريخ'
        ],
        rowBuilder: (item) {
          final e = item as Event;
          return [
            e.eventName,
            e.clientName,
            e.clientEmail,
            e.clientPhone,
            e.status.tryText(),
            e.budget.toStringAsFixed(2),
            e.totalExpenses.toStringAsFixed(2),
            e.totalIncome.toStringAsFixed(2),

            (e.budget - e.totalIncome).toStringAsFixed(2),
            (e.budget - e.totalExpenses).toStringAsFixed(2),
            (e.totalIncome - e.totalExpenses).toStringAsFixed(2),
            '${(e.totalTasks > 0 ? (e.completedTasks / e.totalTasks * 100) : 0.0).toStringAsFixed(2)}%',
           
            e.totalTasks.toInt().toString(),
            e.completedTasks.toInt().toString(),
            (e.totalTasks - e.completedTasks - e.pendingTasks - e.cancelledTasks).toInt().toString(),
            e.pendingTasks.toInt().toString(),
            e.cancelledTasks.toInt().toString(),
            
            translateDurationUnit(e.eventDurationUnit, e.eventDuration),
            ExcelStyles.formatDate(e.eventDate),
          ];
        },
      );
    } 
    else if (tabName == 'المهام') {
      await ExcelExportService.exportTabReport(
        tabName: tabName,
        stats: taskStats,
        items: displayTasks,
        headers: const [
          'النوع', 'الوصف', 'الحالة', 'التكلفة', 'التقييم',
          'المورد', 'الملاحظات', 'المناسبة', 'تاريخ المهمة', 'تاريخ الاستحقاق', 'تاريخ التسليم'
        ],
        rowBuilder: (item) {
          final t = item as Task;
          return [
            t.typeTask ?? 'غير محدد',
            t.description ?? '',
            t.status.tryText(),
            t.cost.toStringAsFixed(2),
            (t.rating ?? 0.0).toInt().toString(),
            t.assigneName ?? 'غير محدد',
            t.notes ?? '',
            t.eventName,
            ExcelStyles.formatDate(t.dateStart),
            ExcelStyles.formatDate(t.dateDue),
            ExcelStyles.formatDate(t.dateCompletion),
          ];
        },
      );
    } else if (tabName == 'الموردين') {
      await ExcelExportService.exportTabReport(
        tabName: tabName,
        stats: supplierStats,
        items: displaySuppliers,
        headers: const [
          'الاسم', 'التقييم', 'عدد الخدمات', 'البريد الالكتروني', 'رقم الهاتف', 'العنوان',
          'كل المهام-تكلفة', 'مهام-تكلفة مكتملة', 'مهام-تكلفة قيد التنفيذ', 'مهام-تكلفة قيد الانتظار', 'مهام-تكلفة ملغاة', 'مهام-تكلفة مرفوضة', 'مهام-تكلفة قيد المراجعة',
          'كل المناسبات', 'مناسبات مكتملة', 'مناسبات قيد التنفيذ', 'مناسبات قيد الانتظار', 'مناسبات ملغاة',
        ],
        rowBuilder: (item) {
          final s = item as Supplier;
          final stats = getSupplierDetailedStats(s);
          final taskCounts = stats['taskCounts'];
          final taskCosts = stats['taskCosts'];
  
          return [
            s.name,
            (s.averageRating ?? 0).toString(),
            "${stats['servicesCount']}",
            s.email,
            s.phoneNumber ?? '',
            s.address ?? '',

            "${taskCounts['total']}-${taskCosts['total']}",
            "${taskCounts['completed']}-${taskCosts['completed']}",
            "${taskCounts['inProgress']}-${taskCosts['inProgress']}",
            "${taskCounts['pending']}-${taskCounts['pending']}",
            "${taskCounts['cancelled']}-${taskCounts['cancelled']}",
            "${taskCounts['rejected']}-${taskCosts['rejected']}",
            "${taskCounts['inReview']}-${taskCosts['inReview']}",

            "${stats['totalEvents']}",
            "${stats['eventsCompleted']}",
            "${stats['eventsInProgress']}",
            "${stats['eventsPending']}",
            "${stats['eventsCancelled']}",
          ];
        },
        isSupplier: true,
      );
    }
  }

  Future<void> exportSingleItem(String type, dynamic item) async {
    String title = '';
    String itemType = '';
    List<MapEntry<String, String>> basicFields = [];
    Map<String, dynamic> advancedStats = {};
    List<Map<String, String>> subTableRows = [];
    String? subTableTitle;
    String? notes;

    if (item is Event) {
      title = 'تفاصيل المناسبة: ${item.eventName}';
      itemType = 'Event';
      
      final stats = getEventDetailedStats(item);
      final counts = stats['counts'] as Map<Status, int>;
      final costs = stats['costs'] as Map<Status, double>;

      // المعلومات الأساسية
      basicFields = [
        MapEntry('اسم العميل', item.clientName),
        MapEntry('بريد العميل', item.clientEmail),
        MapEntry('هاتف العميل', item.clientPhone),
        MapEntry('التاريخ', item.eventDate),
        MapEntry('المدة', translateDurationUnit(item.eventDurationUnit, item.eventDuration)),
        MapEntry('الحالة', item.status.tryText()),
        MapEntry('الميزانية', '${item.budget.toStringAsFixed(2)} ر.س'),
        MapEntry('المصروفات إجمالي', '${item.totalExpenses.toStringAsFixed(2)} ر.س'),
        MapEntry('إجمالي الدفعات', '${item.totalIncome.toStringAsFixed(2)} ر.س'),
        MapEntry('المتبقي على العميل', '${(item.budget - item.totalIncome).toStringAsFixed(2)} ر.س'),
        MapEntry('الربح المتوقع', '${(item.budget - item.totalExpenses).toStringAsFixed(2)} ر.س'),
        MapEntry('الربح الفعلي', '${(item.totalIncome - item.totalExpenses).toStringAsFixed(2)} ر.س'),
      ];

      final tasksForEvent = taskController.tasks.where((t) => t.eventId == item.id).toList();
      final incomesForEvent = incomeController.incomes.where((i) => i.eventId == item.id).toList();
      final uniqueSuppliers = tasksForEvent.map((t) => t.userAssignId).toSet().length;
      
      advancedStats = {
        'المهام: مكتملة': '${counts[Status.COMPLETED]} (${costs[Status.COMPLETED]?.toStringAsFixed(2)} ر.س)',
        'المهام: قيد التنفيذ': '${counts[Status.IN_PROGRESS]} (${costs[Status.IN_PROGRESS]?.toStringAsFixed(2)} ر.س)',
        'المهام: قيد الانتظار': '${counts[Status.PENDING]} (${costs[Status.PENDING]?.toStringAsFixed(2)} ر.س)',
        'المهام: قيد المراجعة': '${counts[Status.UNDER_REVIEW]} (${costs[Status.UNDER_REVIEW]?.toStringAsFixed(2)} ر.س)',
        'المهام: مرفوضة': '${counts[Status.REJECTED]} (${costs[Status.REJECTED]?.toStringAsFixed(2)} ر.س)',
        'المهام: ملغاة': '${counts[Status.CANCELLED]} (${costs[Status.CANCELLED]?.toStringAsFixed(2)} ر.س)',
        'إجمالي المهام': item.totalTasks.toInt().toString(),
        'عدد الموردين': uniqueSuppliers.toString(),
        'عدد الدفعات': incomesForEvent.length.toString(),
        'نسبة الإنجاز': item.totalTasks > 0 ? '${(item.completedTasks / item.totalTasks * 100).toStringAsFixed(1)}%' : '0%',
      };

      // جدول فرعي: المهام المرتبطة
      if (tasksForEvent.isNotEmpty) {
        subTableTitle = '✅ المهام المرتبطة بهذه المناسبة';
        subTableRows = tasksForEvent.map((t) {
          return {
            'نوع المهمة': t.typeTask ?? 'غير محدد',
            'المورد': t.assigneName ?? 'غير محدد',
            'التكلفة': '${t.cost.toStringAsFixed(2)} ر.س',
            'الحالة': t.status.tryText(),
          };
        }).toList();
      }

      notes = item.description ?? 'لا توجد ملاحظات إضافية';
    } 
    else if (item is Task) {
      title = 'تفاصيل المهمة: ${item.typeTask ?? 'بدون نوع'}';
      itemType = 'Task';
      
      basicFields = [
        MapEntry('الوصف', item.description ?? 'لا يوجد وصف'),
        MapEntry('التكلفة', '${item.cost.toStringAsFixed(2)} ر.س'),
        MapEntry('المورد', item.assigneName ?? 'غير محدد'),
        MapEntry('التقييم', (item.rating ?? 0.0).toString()),
        MapEntry('الحالة', item.status.tryText()),
        MapEntry('تاريخ البدء', item.dateStart ?? 'لم يحدد'),
        MapEntry('تاريخ الاستحقاق', item.dateDue ?? 'لم يحدد'),
        MapEntry('تاريخ التسليم', item.dateCompletion ?? 'لم يحدد'),
      ];

      // إحصائيات إضافية عن المورد والمناسبة
      final event = eventController.events.firstWhereOrNull((e) => e.id == item.eventId);
      final supplier = supplierController.suppliers.firstWhereOrNull((s) => s.id == item.userAssignId);
      
      advancedStats = {
        'المناسبة المرتبطة': event?.eventName ?? 'غير معروف',
        'اسم المورد': supplier?.name ?? 'غير معروف',
        'بريد المورد': supplier?.email ?? 'غير متوفر',
        'جوال المورد': supplier?.phoneNumber?.toString() ?? 'غير متوفر',
      };

      notes = item.notes ?? 'لا توجد ملاحظات';
    } 
    else if (item is Supplier) {
      title = 'بطاقة المورد: ${item.name}';
      itemType = 'Supplier';
      
      basicFields = [
        MapEntry('البريد الإلكتروني', item.email),
        MapEntry('رقم الجوال', item.phoneNumber?.toString() ?? 'غير محدد'),
        MapEntry('التقييم العام', (item.averageRating ?? 0).toString()),
        MapEntry('عدد الخدمات المقدمة', item.services.length.toString()),
        MapEntry('العنوان', item.address ?? 'غير محدد'),
        MapEntry('ملاحظات', item.notes ?? 'لا توجد'),
      ];

      // إحصائيات متقدمة عن المورد (المهام، المناسبات)
      final tasksForSupplier = taskController.tasks.where((t) => t.userAssignId == item.id).toList();
      final uniqueEvents = tasksForSupplier.map((t) => t.eventId).toSet().length;
      final totalEarnings = tasksForSupplier.fold(0.0, (sum, t) => sum + t.cost);
      final completedTasks = tasksForSupplier.where((t) => t.status.isCompleted).length;
      
      advancedStats = {
        'عدد المهام المنفذة': tasksForSupplier.length,
        'المهام المكتملة': completedTasks,
        'عدد المناسبات المساهم فيها': uniqueEvents,
        'إجمالي الأرباح (تكلفة المهام)': '${totalEarnings.toStringAsFixed(2)} ر.س',
        'متوسط التقييم للمهام': tasksForSupplier.isEmpty ? '0' : 
            (tasksForSupplier.map((t) => t.rating ?? 0).reduce((a, b) => a + b) / tasksForSupplier.length).toStringAsFixed(1),
      };

      // جدول فرعي: الخدمات التي يقدمها
      if (item.services.isNotEmpty) {
        subTableTitle = '🛠️ الخدمات المقدمة من المورد';
        subTableRows = item.services.map((service) {
          return {
            'اسم الخدمة': service.serviceName,
            // 'التكلفة التقريبية': '${service.cost?.toStringAsFixed(2) ?? 'غير محدد'} ر.س',
            'ملاحظات': service.description ?? '',
          };
        }).toList();
      }

      notes = item.notes ?? 'لا توجد ملاحظات إضافية';
    }

    await ExcelExportService.exportSingleItem(
      title: title,
      itemType: itemType,
      basicFields: basicFields,
      advancedStats: advancedStats,
      subTableRows: subTableRows.isNotEmpty ? subTableRows : null,
      subTableTitle: subTableTitle,
      notes: notes,
    );
  }
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red.withValues(alpha: 0.1),
      colorText: AppColors.red,
    );
  }
}