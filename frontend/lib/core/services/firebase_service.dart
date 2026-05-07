import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  /// التوثيق (اختياري، يمكنك استخدامه لاحقاً)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// مرجع قاعدة البيانات
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== دوال عامة للـ CRUD ====================

  /// إنشاء وثيقة جديدة في مجموعة معينة
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة (مثل 'Users', 'Events')
  /// 
  /// - `Map<String, dynamic>` data: يحتوي على البيانات
  /// 
  /// - `String?` docId: (اختياري) معرف الوثيقة. إذا لم يُعطى، سيتم إنشاؤه تلقائياً
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<String>` معرف الوثيقة الجديدة
  Future<String> createDocument(String collectionName, Map<String, dynamic> data, {String? docId}) async {
    try {
      if (docId != null) {
        await _firestore.collection(collectionName).doc(docId).set(data);
        return docId;
      } else {
        final docRef = await _firestore.collection(collectionName).add(data);
        return docRef.id;
      }
    } catch (e) {
      throw Exception('فشل إنشاء الوثيقة: $e');
    }
  }

  /// قراءة وثيقة واحدة من مجموعة باستخدام معرفها
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` docId: معرف الوثيقة
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<Map<String, dynamic>?>` تحتوي على البيانات (معرف الوثيقة مضافاً)
  Future<Map<String, dynamic>?> getDocument(String collectionName, String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('فشل قراءة الوثيقة: $e');
    }
  }

  /// تحديث وثيقة موجودة
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` docId: معرف الوثيقة
  /// 
  /// - `Map<String, dynamic>` data: تحتوي على الحقول المطلوب تحديثها فقط
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>` لا يوجد إرجاع
  Future<void> updateDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update(data);
    } catch (e) {
      throw Exception('فشل تحديث الوثيقة: $e');
    }
  }

  /// حذف وثيقة
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` docId: معرف الوثيقة
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>` لا يوجد إرجاع
  Future<void> deleteDocument(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
    } catch (e) {
      throw Exception('فشل حذف الوثيقة: $e');
    }
  }

  /// حذف ناعم (soft delete): إضافة حقل deletedAt بدلاً من الحذف الفعلي
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` docId: معرف الوثيقة
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>` لا يوجد إرجاع
  Future<void> softDeleteDocument(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update({
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('فشل الحذف الناعم: $e');
    }
  }

  // ==================== دوال الاستعلام ====================

  /// جلب جميع وثائق مجموعة (مع إمكانية استبعاد المحذوفة ناعماً)
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `bool` excludeSoftDeleted: استبعاد المحذوفة ناعماً
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<List<Map<String, dynamic>>>` تحتوي على جميع الوثائق
  Future<List<Map<String, dynamic>>> getAllDocuments(String collectionName, {bool excludeSoftDeleted = true}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionName);
      if (excludeSoftDeleted) {
        query = query.where('deletedAt', isNull: true);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('فشل جلب الوثائق: $e');
    }
  }

  /// استعلام باستخدام شرط واحد
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` field: اسم الحقل
  /// 
  /// - `dynamic` value: القيمة المطلوبة
  /// 
  /// - `bool` excludeSoftDeleted: استبعاد المحذوف ناعماً
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<List<Map<String, dynamic>>>` تحتوي على الوثائق التي تطابق الشرط
  Future<List<Map<String, dynamic>>> queryWhere(
    String collectionName,
    String field,
    dynamic value, {
    bool excludeSoftDeleted = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionName).where(field, isEqualTo: value);
      if (excludeSoftDeleted) {
        query = query.where('deletedAt', isNull: true);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('فشل الاستعلام: $e');
    }
  }

  /// استعلام متعدد الشروط (حتى 10 شروط)
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `List<Map<String, dynamic>>` conditions: قائمة بالشروط
  /// 
  /// - `bool` excludeSoftDeleted: استبعاد المحذوف ناعماً
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<List<Map<String, dynamic>>>` تحتوي على الوثائق التي تطابق الشروط
  Future<List<Map<String, dynamic>>> queryWhereMultiple(
    String collectionName,
    List<Map<String, dynamic>> conditions, {
    bool excludeSoftDeleted = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionName);
      for (var condition in conditions) {
        final field = condition['field'];
        final value = condition['value'];
        final op = condition['operator'] ?? '==';

        query = switch(op){
          '==' => query.where(field, isEqualTo: value),
          '!=' => query.where(field, isNotEqualTo: value),
          '<' => query.where(field, isLessThan: value),
          '<=' => query.where(field, isLessThanOrEqualTo: value),
          '>' => query.where(field, isGreaterThan: value),
          '>=' => query.where(field, isGreaterThanOrEqualTo: value),
          'arrayContains' => query.where(field, arrayContains: value),
          'arrayContainsAny' => query.where(field, arrayContainsAny: value),
          'whereIn' => query.where(field, whereIn: value),
          'whereNotIn' => query.where(field, whereNotIn: value),
          'isNull' => query.where(field, isNull: value),
          _ => throw Exception('عملية غير مدعومة: $op'),
        };
      }
      if (excludeSoftDeleted) {
        query = query.where('deletedAt', isNull: true);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('فشل الاستعلام المتعدد: $e');
    }
  }

  // ==================== دوال البث المباشر (Streams) ====================

  /// الإصغاء للتغييرات في وثيقة واحدة (تحديثات فورية)
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` docId: معرف الوثيقة
  /// 
  /// الإرجاع:
  /// 
  /// - `Stream<Map<String, dynamic>?>` بث مباشر للوثيقة
  Stream<Map<String, dynamic>?> streamDocument(String collectionName, String docId) {
    return _firestore.collection(collectionName).doc(docId).snapshots().map((doc) {
      if (doc.exists) return {'id': doc.id, ...doc.data()!};
      return null;
    });
  }

  /// الإصغاء لكل وثائق مجموعة مع استبعاد المحذوف ناعماً
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `bool` excludeSoftDeleted: استبعاد المحذوف ناعماً
  /// 
  /// الإرجاع:
  /// 
  /// - `Stream<List<Map<String, dynamic>>>` بث مباشر لجميع وثائق المجموعة
  Stream<List<Map<String, dynamic>>> streamCollection(String collectionName, {bool excludeSoftDeleted = true}) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionName);
    if (excludeSoftDeleted) {
      query = query.where('deletedAt', isNull: true);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  /// الإصغاء لاستعلام معين
  /// 
  /// المعاملات:
  /// 
  /// - `String` collectionName: اسم المجموعة
  /// 
  /// - `String` field: اسم الحقل
  /// 
  /// - `dynamic` value: القيمة المطلوبة
  /// 
  /// - `bool` excludeSoftDeleted: استبعاد المحذوف ناعماً
  /// 
  /// الإرجاع:
  /// 
  /// - `Stream<List<Map<String, dynamic>>>` بث مباشر للوثائق التي تطابق الشرط
  Stream<List<Map<String, dynamic>>> streamQuery(
    String collectionName,
    String field,
    dynamic value, {
    bool excludeSoftDeleted = true,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionName).where(field, isEqualTo: value);
    if (excludeSoftDeleted) {
      query = query.where('deletedAt', isNull: true);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  // ==================== دوال مساعدة (Batch) ====================

  /// تنفيذ عدة عمليات كتابة دفعة واحدة (batch)
  /// 
  /// المعاملات:
  /// 
  /// - `List<Future<void> Function(WriteBatch batch)>` operations: قائمة بالعمليات
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>` لا يوجد إرجاع
  Future<void> runBatch(List<Future<void> Function(WriteBatch batch)> operations) async {
    final WriteBatch batch = _firestore.batch();
    for (var operation in operations) {
      await operation(batch);
    }
    await batch.commit();
  }

  /// مثال: إنشاء وثيقتين في دفعة واحدة
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد معاملات
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>` لا يوجد إرجاع
  Future<void> batchCreateExample() async {
    await runBatch([
      (batch) async {
        final ref1 = _firestore.collection('Users').doc();
        batch.set(ref1, {'name': 'أحمد', 'createdAt': FieldValue.serverTimestamp()});
        final ref2 = _firestore.collection('Users').doc();
        batch.set(ref2, {'name': 'سارة', 'createdAt': FieldValue.serverTimestamp()});
        return Future.value();
      }
    ]);
  }

  // ==================== دوال خاصة بالمستخدم الحالي ====================

  /// الحصول على معرف المستخدم الحالي (إذا كنت تستخدم Firebase Auth)
  String? get currentUserId => _auth.currentUser?.uid;

  /// التحقق من تسجيل الدخول
  bool get isLoggedIn => _auth.currentUser != null;
}