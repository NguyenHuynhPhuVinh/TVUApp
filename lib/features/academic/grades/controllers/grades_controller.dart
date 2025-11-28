import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../features/gamification/core/rank_helper.dart';
import '../../../../features/gamification/shared/widgets/game_widgets.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../models/grade_model.dart';

class GradesController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final gradesBySemester = <SemesterGrade>[].obs;
  final gradedSubjects = <SubjectGrade>[].obs;
  final selectedTab = 0.obs;
  final selectedSemesterIndex = 0.obs;

  // Rank rewards loading states
  final isClaimingAll = false.obs;
  final claimingRankIndex = Rxn<int>();

  // === TÍCH LŨY ===
  SemesterGrade? get _latestSemester =>
      gradesBySemester.isNotEmpty ? gradesBySemester.first : null;

  String get gpa10 => _latestSemester?.dtbTichLuyHe10 ?? '0';
  String get gpa4 => _latestSemester?.dtbTichLuyHe4 ?? '0';
  String get totalCredits => _latestSemester?.soTinChiDatTichLuy ?? '0';

  // === SEMESTER DATA ===
  SemesterGrade? get currentSemester {
    if (gradesBySemester.isEmpty) return null;
    return gradesBySemester[selectedSemesterIndex.value];
  }

  String get semesterGpa10 => currentSemester?.dtbHkHe10 ?? '';
  String get semesterGpa4 => currentSemester?.dtbHkHe4 ?? '';
  String get semesterCredits => currentSemester?.soTinChiDatHk ?? '';
  String get semesterClassification => currentSemester?.academicRank ?? '';

  List<SubjectGrade> get currentSemesterGrades =>
      currentSemester?.subjects ?? [];

  // === RANK CALCULATION ===
  int get rankIndex {
    final gpa = _latestSemester?.dtbTichLuyHe10Double ?? 0;
    return RankHelper.getRankIndexFromGpa(gpa);
  }

  RankTier get currentTier => RankHelper.getTierFromIndex(rankIndex);
  int get currentLevel => RankHelper.getLevelFromIndex(rankIndex);
  String get rankName => RankHelper.getRankNameFromIndex(rankIndex);
  String get rankAsset => RankHelper.getAssetPathFromIndex(rankIndex);
  Color get rankColor => RankHelper.getTierColor(currentTier);

  double get progressToNextRank {
    if (RankHelper.isMaxRank(rankIndex)) return 1.0;
    final gpa = _latestSemester?.dtbTichLuyHe10Double ?? 0;
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
  Map<String, List<SubjectGrade>> get gradesByClassification {
    final result = <String, List<SubjectGrade>>{
      'Xuất sắc': [],
      'Giỏi': [],
      'Khá': [],
      'Trung bình': [],
      'Yếu': [],
    };

    for (final grade in gradedSubjects) {
      final score = grade.diemTkDouble;
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
  int get passedSubjects => gradedSubjects.where((g) => g.isPassed).length;
  int get excellentSubjects => gradesByClassification['Xuất sắc']!.length;

  SubjectGrade? get highestGrade {
    if (gradedSubjects.isEmpty) return null;
    return gradedSubjects.reduce((a, b) {
      final scoreA = a.diemTkDouble ?? 0;
      final scoreB = b.diemTkDouble ?? 0;
      return scoreA > scoreB ? a : b;
    });
  }

  SubjectGrade? get lowestGrade {
    if (gradedSubjects.isEmpty) return null;
    return gradedSubjects.reduce((a, b) {
      final scoreA = a.diemTkDouble ?? 10;
      final scoreB = b.diemTkDouble ?? 10;
      return scoreA < scoreB ? a : b;
    });
  }

  String getScore(SubjectGrade grade) {
    return grade.diemTk;
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
    final gradesData = _storage.getGrades();

    if (gradesData != null && gradesData['data'] != null) {
      final data = gradesData['data'];
      final semesters = data['ds_diem_hocky'] as List? ?? [];
      gradesBySemester.value =
          semesters.map((e) => SemesterGrade.fromJson(e)).toList();

      // Collect all graded subjects
      final graded = <SubjectGrade>[];
      for (final semester in gradesBySemester) {
        for (final subject in semester.subjects) {
          if (subject.hasGrade) {
            graded.add(subject);
          }
        }
      }
      gradedSubjects.value = graded;
    }
  }

  void selectTab(int index) => selectedTab.value = index;
  void selectSemester(int index) => selectedSemesterIndex.value = index;

  // === RANK REWARDS ===

  String get _mssv => _authService.username.value;

  List<int> get claimedRankRewards =>
      _gameService.stats.value.claimedRankRewards;

  int get unclaimedRankCount => _gameService.countUnclaimedRanks(rankIndex);

  bool get hasUnclaimedRewards => unclaimedRankCount > 0;

  void openRankRewardsSheet() {
    Get.bottomSheet(
      Obx(() => DuoRankRewardsSheet(
            currentRankIndex: rankIndex,
            claimedRanks: claimedRankRewards,
            isClaimingAll: isClaimingAll.value,
            claimingRankIndex: claimingRankIndex.value,
            onClaimRank: claimRankReward,
            onClaimAll: claimAllRankRewards,
          )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> claimRankReward(int rankIdx) async {
    if (claimingRankIndex.value != null || isClaimingAll.value) return;

    claimingRankIndex.value = rankIdx;

    try {
      final result = await _gameService.claimRankReward(
        mssv: _mssv,
        rankIndex: rankIdx,
        currentRankIndex: rankIndex,
      );

      if (result != null) {
        DuoRewardDialog.showCustom(
          title: 'Nhận thưởng Rank!',
          subtitle: RankHelper.getRankNameFromIndex(rankIdx),
          rewards: [
            RewardItem(
              icon: AppAssets.coin,
              label: 'Coins',
              value: result['earnedCoins'],
              color: AppColors.yellow,
            ),
            RewardItem(
              icon: AppAssets.xpStar,
              label: 'XP',
              value: result['earnedXp'],
              color: AppColors.purple,
            ),
            RewardItem(
              icon: AppAssets.diamond,
              label: 'Diamonds',
              value: result['earnedDiamonds'],
              color: AppColors.primary,
            ),
          ],
          leveledUp: result['leveledUp'] ?? false,
          newLevel: result['newLevel'],
        );
      }
    } finally {
      claimingRankIndex.value = null;
    }
  }

  Future<void> claimAllRankRewards() async {
    if (isClaimingAll.value || claimingRankIndex.value != null) return;

    isClaimingAll.value = true;

    try {
      final result = await _gameService.claimAllRankRewards(
        mssv: _mssv,
        currentRankIndex: rankIndex,
      );

      if (result != null) {
        Get.back();

        DuoRewardDialog.showCustom(
          title: 'Nhận tất cả thưởng!',
          subtitle: '${result['claimedCount']} rank',
          rewards: [
            RewardItem(
              icon: AppAssets.coin,
              label: 'Coins',
              value: result['earnedCoins'],
              color: AppColors.yellow,
            ),
            RewardItem(
              icon: AppAssets.xpStar,
              label: 'XP',
              value: result['earnedXp'],
              color: AppColors.purple,
            ),
            RewardItem(
              icon: AppAssets.diamond,
              label: 'Diamonds',
              value: result['earnedDiamonds'],
              color: AppColors.primary,
            ),
          ],
          leveledUp: result['leveledUp'] ?? false,
          newLevel: result['newLevel'],
        );
      }
    } finally {
      isClaimingAll.value = false;
    }
  }
}
