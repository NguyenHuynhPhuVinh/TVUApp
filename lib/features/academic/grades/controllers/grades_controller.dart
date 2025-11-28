import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/gamification/utils/rank_helper.dart';
import '../../../../features/gamification/widgets/game_widgets.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../infrastructure/storage/storage_service.dart';

class GradesController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final gradesBySemester = <Map<String, dynamic>>[].obs;
  final gradedSubjects = <Map<String, dynamic>>[].obs;
  final selectedTab = 0.obs;
  final selectedSemesterIndex = 0.obs;
  
  // Rank rewards
  final isClaimingAll = false.obs; // Loading cho nút "Nhận tất cả"
  final claimingRankIndex = Rxn<int>(); // Loading cho từng rank

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
    return RankHelper.getRankIndexFromGpa(gpa);
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
    final gradesData = _storage.getGrades();

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

  // === RANK REWARDS ===
  
  String get _mssv => _authService.username.value;
  
  /// Danh sách rank đã claim
  List<int> get claimedRankRewards => _gameService.stats.value.claimedRankRewards;
  
  /// Số rank chưa claim
  int get unclaimedRankCount => _gameService.countUnclaimedRanks(rankIndex);
  
  /// Có rank chưa claim không
  bool get hasUnclaimedRewards => unclaimedRankCount > 0;

  /// Mở bottom sheet rank rewards
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

  /// Claim reward cho 1 rank
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
        // Hiển thị dialog nhận thưởng
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

  /// Claim tất cả rank rewards
  Future<void> claimAllRankRewards() async {
    if (isClaimingAll.value || claimingRankIndex.value != null) return;
    
    isClaimingAll.value = true;
    
    try {
      final result = await _gameService.claimAllRankRewards(
        mssv: _mssv,
        currentRankIndex: rankIndex,
      );
      
      if (result != null) {
        Get.back(); // Đóng bottom sheet
        
        // Hiển thị dialog nhận thưởng
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



