import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/rank_helper.dart';
import '../../../data/services/local_storage_service.dart';

class GradesController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final gradesBySemester = <Map<String, dynamic>>[].obs;
  final gradedSubjects = <Map<String, dynamic>>[].obs;
  final selectedTab = 0.obs;
  final selectedSemesterIndex = 0.obs;

  // Tích lũy
  String get gpa10 => _latestSemester?['dtb_tich_luy_he_10']?.toString() ?? '0';
  String get gpa4 => _latestSemester?['dtb_tich_luy_he_4']?.toString() ?? '0';
  String get totalCredits => _latestSemester?['so_tin_chi_dat_tich_luy']?.toString() ?? '0';

  Map<String, dynamic>? get _latestSemester {
    if (gradesBySemester.isEmpty) return null;
    return gradesBySemester.first;
  }

  // === SEMESTER DATA ===
  Map<String, dynamic>? get currentSemester {
    if (gradesBySemester.isEmpty) return null;
    return gradesBySemester[selectedSemesterIndex.value];
  }

  String get semesterGpa10 => currentSemester?['dtb_hk_he10']?.toString() ?? '';
  String get semesterGpa4 => currentSemester?['dtb_hk_he4']?.toString() ?? '';
  String get semesterCredits => currentSemester?['so_tin_chi_dat_hk']?.toString() ?? '';
  String get semesterClassification => currentSemester?['xep_loai_tkb_hk']?.toString() ?? '';

  List<Map<String, dynamic>> get currentSemesterGrades {
    if (currentSemester == null) return [];
    final grades = currentSemester!['ds_diem_mon_hoc'] as List? ?? [];
    return grades.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // === RANK CALCULATION ===
  int get rankIndex {
    final gpa = double.tryParse(gpa10) ?? 0;
    final index = ((gpa / 10) * 55).floor().clamp(0, 55);
    return index;
  }

  RankTier get currentTier => RankHelper.getTierFromIndex(rankIndex);
  int get currentLevel => RankHelper.getLevelFromIndex(rankIndex);
  String get rankName => RankHelper.getRankNameFromIndex(rankIndex);
  String get rankAsset => RankHelper.getAssetPathFromIndex(rankIndex);
  Color get rankColor => RankHelper.getTierColor(currentTier);

  double get progressToNextRank {
    if (RankHelper.isMaxRank(rankIndex)) return 1.0;
    final gpa = double.tryParse(gpa10) ?? 0;
    final currentRankGpa = (rankIndex / 55) * 10;
    final nextRankGpa = ((rankIndex + 1) / 55) * 10;
    final progress = (gpa - currentRankGpa) / (nextRankGpa - currentRankGpa);
    return progress.clamp(0.0, 1.0);
  }

  String get gpaForNextRank {
    if (RankHelper.isMaxRank(rankIndex)) return 'MAX';
    final nextGpa = ((rankIndex + 1) / 55) * 10;
    return nextGpa.toStringAsFixed(2);
  }

  // === GRADE ANALYSIS ===
  Map<String, List<Map<String, dynamic>>> get gradesByClassification {
    final result = <String, List<Map<String, dynamic>>>{
      'Xuất sắc': [],
      'Giỏi': [],
      'Khá': [],
      'Trung bình': [],
      'Yếu': [],
    };

    for (final grade in gradedSubjects) {
      final score = _getScoreValue(grade);
      if (score == null) continue;

      if (score >= 9.0) {
        result['Xuất sắc']!.add(grade);
      } else if (score >= 8.0) {
        result['Giỏi']!.add(grade);
      } else if (score >= 7.0) {
        result['Khá']!.add(grade);
      } else if (score >= 5.0) {
        result['Trung bình']!.add(grade);
      } else {
        result['Yếu']!.add(grade);
      }
    }

    return result;
  }

  int get totalSubjects => gradedSubjects.length;
  int get passedSubjects => gradedSubjects.where((g) {
        final score = _getScoreValue(g);
        return score != null && score >= 4.0;
      }).length;
  int get excellentSubjects => gradesByClassification['Xuất sắc']!.length;

  Map<String, dynamic>? get highestGrade {
    if (gradedSubjects.isEmpty) return null;
    return gradedSubjects.reduce((a, b) {
      final scoreA = _getScoreValue(a) ?? 0;
      final scoreB = _getScoreValue(b) ?? 0;
      return scoreA > scoreB ? a : b;
    });
  }

  Map<String, dynamic>? get lowestGrade {
    if (gradedSubjects.isEmpty) return null;
    return gradedSubjects.reduce((a, b) {
      final scoreA = _getScoreValue(a) ?? 10;
      final scoreB = _getScoreValue(b) ?? 10;
      return scoreA < scoreB ? a : b;
    });
  }

  double? _getScoreValue(Map<String, dynamic> grade) {
    final scoreStr = grade['diem_tk']?.toString() ?? '';
    if (scoreStr.isEmpty) return null;
    return double.tryParse(scoreStr);
  }

  String getScore(Map<String, dynamic> grade) {
    return grade['diem_tk']?.toString() ?? '';
  }

  Color getClassificationColor(String classification) {
    switch (classification) {
      case 'Xuất sắc':
        return AppColors.purple;
      case 'Giỏi':
        return AppColors.green;
      case 'Khá':
        return AppColors.primary;
      case 'Trung bình':
        return AppColors.orange;
      case 'Yếu':
        return AppColors.red;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadGrades();
  }

  void loadGrades() {
    final gradesData = _localStorage.getGrades();

    if (gradesData != null && gradesData['data'] != null) {
      final data = gradesData['data'];
      final semesters = data['ds_diem_hocky'] as List? ?? [];
      gradesBySemester.value = semesters.map((e) => Map<String, dynamic>.from(e)).toList();

      final graded = <Map<String, dynamic>>[];
      for (final semester in gradesBySemester) {
        final grades = semester['ds_diem_mon_hoc'] as List? ?? [];
        for (final grade in grades) {
          final gradeMap = Map<String, dynamic>.from(grade);
          final scoreStr = gradeMap['diem_tk']?.toString() ?? '';
          if (scoreStr.isNotEmpty && double.tryParse(scoreStr) != null) {
            graded.add(gradeMap);
          }
        }
      }
      gradedSubjects.value = graded;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void selectSemester(int index) {
    selectedSemesterIndex.value = index;
  }
}
