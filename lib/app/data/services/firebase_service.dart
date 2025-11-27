import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  late final FirebaseFirestore _firestore;
  
  final isSyncing = false.obs;
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;

  Future<FirebaseService> init() async {
    _firestore = FirebaseFirestore.instance;
    return this;
  }

  /// Lưu data học tập lên Firebase theo MSSV (CHỈ điểm, CTDT, học phí - KHÔNG lưu info cá nhân)
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
      
      final studentRef = _firestore.collection('students').doc(mssv);

      // 1. Lưu điểm
      if (grades != null) {
        syncStatus.value = 'Đang lưu điểm học tập...';
        await studentRef.set({
          'grades': grades,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        syncProgress.value = 0.33;
      }

      // 2. Lưu CTDT
      if (curriculum != null) {
        syncStatus.value = 'Đang lưu chương trình đào tạo...';
        await studentRef.set({
          'curriculum': curriculum,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        syncProgress.value = 0.66;
      }

      // 3. Lưu học phí
      if (tuition != null) {
        syncStatus.value = 'Đang lưu thông tin học phí...';
        await studentRef.set({
          'tuition': tuition,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        syncProgress.value = 1.0;
      }

      syncStatus.value = 'Hoàn tất!';
      return true;
    } catch (e) {
      print('Error syncing to Firebase: $e');
      syncStatus.value = 'Lỗi: $e';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Lấy data từ Firebase theo MSSV
  Future<Map<String, dynamic>?> getStudentData(String mssv) async {
    if (mssv.isEmpty) return null;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error getting data from Firebase: $e');
    }
    return null;
  }

  /// Kiểm tra xem MSSV đã có data trên Firebase chưa
  Future<bool> hasStudentData(String mssv) async {
    if (mssv.isEmpty) return false;
    
    try {
      final doc = await _firestore.collection('students').doc(mssv).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Lưu điểm
  Future<bool> saveGrades(String mssv, Map<String, dynamic> grades) async {
    try {
      await _firestore.collection('students').doc(mssv).set({
        'grades': grades,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving grades: $e');
      return false;
    }
  }

  /// Lưu CTDT
  Future<bool> saveCurriculum(String mssv, Map<String, dynamic> curriculum) async {
    try {
      await _firestore.collection('students').doc(mssv).set({
        'curriculum': curriculum,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving curriculum: $e');
      return false;
    }
  }

  /// Lưu học phí
  Future<bool> saveTuition(String mssv, Map<String, dynamic> tuition) async {
    try {
      await _firestore.collection('students').doc(mssv).set({
        'tuition': tuition,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving tuition: $e');
      return false;
    }
  }

  /// Lưu TKB của một học kỳ
  Future<bool> saveSchedule(String mssv, int semester, Map<String, dynamic> schedule) async {
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
      print('Error saving schedule: $e');
      return false;
    }
  }

  /// Lưu danh sách học kỳ
  Future<bool> saveSemesters(String mssv, Map<String, dynamic> semesters) async {
    try {
      await _firestore.collection('students').doc(mssv).set({
        'semesters': semesters,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving semesters: $e');
      return false;
    }
  }

  /// Lấy danh sách học kỳ đã lưu trên Firebase
  Future<List<int>> getSavedSemesters(String mssv) async {
    try {
      final snapshots = await _firestore
          .collection('students')
          .doc(mssv)
          .collection('schedules')
          .get();
      return snapshots.docs.map((doc) => int.tryParse(doc.id) ?? 0).toList();
    } catch (e) {
      print('Error getting saved semesters: $e');
      return [];
    }
  }

  /// Lấy TKB của một học kỳ từ Firebase
  Future<Map<String, dynamic>?> getSchedule(String mssv, int semester) async {
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
      print('Error getting schedule: $e');
    }
    return null;
  }
}
