import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Firebase data keys enum
enum FirebaseDataKey {
  grades,
  curriculum,
  tuition,
  semesters,
}

class FirebaseService extends GetxService {
  late final FirebaseFirestore _firestore;

  final isSyncing = false.obs;
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;

  Future<FirebaseService> init() async {
    _firestore = FirebaseFirestore.instance;
    return this;
  }

  // ============ GENERIC HELPERS ============

  /// Generic: Lưu data vào student document
  Future<bool> _updateStudentData(
    String mssv,
    String field,
    Map<String, dynamic> data,
  ) async {
    if (mssv.isEmpty) return false;

    try {
      await _firestore.collection('students').doc(mssv).set({
        field: data,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error saving $field: $e');
      return false;
    }
  }

  /// Generic: Lấy data từ student document
  Future<Map<String, dynamic>?> _getStudentField(
      String mssv, String field) async {
    if (mssv.isEmpty) return null;

    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists && doc.data()?[field] != null) {
        return doc.data()![field] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error getting $field: $e');
    }
    return null;
  }

  // ============ SYNC ALL ============

  Future<bool> syncAllStudentData({
    required String mssv,
    Map<String, dynamic>? grades,
    Map<String, dynamic>? curriculum,
    Map<String, dynamic>? tuition,
  }) async {
    if (mssv.isEmpty) return false;

    try {
      isSyncing.value = true;
      syncProgress.value = 0;

      final dataToSync = <String, Map<String, dynamic>?>{
        'grades': grades,
        'curriculum': curriculum,
        'tuition': tuition,
      };

      final statusMessages = {
        'grades': 'Đang lưu điểm học tập...',
        'curriculum': 'Đang lưu chương trình đào tạo...',
        'tuition': 'Đang lưu thông tin học phí...',
      };

      int completed = 0;
      final total = dataToSync.values.where((v) => v != null).length;

      for (var entry in dataToSync.entries) {
        if (entry.value != null) {
          syncStatus.value = statusMessages[entry.key]!;
          await _updateStudentData(mssv, entry.key, entry.value!);
          completed++;
          syncProgress.value = completed / total;
        }
      }

      syncStatus.value = 'Hoàn tất!';
      return true;
    } catch (e) {
      debugPrint('Error syncing to Firebase: $e');
      syncStatus.value = 'Lỗi: $e';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // ============ STUDENT DATA ============

  Future<Map<String, dynamic>?> getStudentData(String mssv) async {
    if (mssv.isEmpty) return null;

    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Error getting data from Firebase: $e');
    }
    return null;
  }

  Future<bool> hasStudentData(String mssv) async {
    if (mssv.isEmpty) return false;

    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============ CONVENIENCE METHODS ============

  Future<bool> saveGrades(String mssv, Map<String, dynamic> grades) =>
      _updateStudentData(mssv, 'grades', grades);

  Future<bool> saveCurriculum(String mssv, Map<String, dynamic> curriculum) =>
      _updateStudentData(mssv, 'curriculum', curriculum);

  Future<bool> saveTuition(String mssv, Map<String, dynamic> tuition) =>
      _updateStudentData(mssv, 'tuition', tuition);

  Future<bool> saveSemesters(String mssv, Map<String, dynamic> semesters) =>
      _updateStudentData(mssv, 'semesters', semesters);

  // ============ SCHEDULE (subcollection) ============

  Future<bool> saveSchedule(
      String mssv, int semester, Map<String, dynamic> schedule) async {
    if (mssv.isEmpty) return false;

    try {
      await _firestore
          .collection('students')
          .doc(mssv)
          .collection('schedules')
          .doc(semester.toString())
          .set({
        'data': schedule,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      return false;
    }
  }

  Future<List<int>> getSavedSemesters(String mssv) async {
    if (mssv.isEmpty) return [];

    try {
      final snapshots = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('schedules')
          .get();
      return snapshots.docs.map((doc) => int.tryParse(doc.id) ?? 0).toList();
    } catch (e) {
      debugPrint('Error getting saved semesters: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSchedule(String mssv, int semester) async {
    if (mssv.isEmpty) return null;

    try {
      final doc = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('schedules')
          .doc(semester.toString())
          .get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Error getting schedule: $e');
    }
    return null;
  }
}
