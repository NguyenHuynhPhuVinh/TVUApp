import 'package:get/get.dart';

import '../../../../core/enums/reward_claim_status.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/gamification/core/game_service.dart';
import '../../../../features/gamification/widgets/duo_reward_dialog.dart';
import '../../../../infrastructure/storage/storage_service.dart';
import '../../models/curriculum_model.dart';

class CurriculumController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final semesters = <CurriculumSemester>[].obs;
  final selectedSemesterIndex = 0.obs;
  final majorName = ''.obs;
  final claimingSubject = ''.obs;

  // Thống kê
  int get totalCredits =>
      semesters.fold(0, (sum, sem) => sum + sem.totalCredits);

  int get completedCredits =>
      semesters.fold(0, (sum, sem) => sum + sem.completedCredits);

  int get totalSubjects =>
      semesters.fold(0, (sum, sem) => sum + sem.subjects.length);

  int get completedSubjects =>
      semesters.fold(0, (sum, sem) => sum + sem.completedSubjects);

  @override
  void onInit() {
    super.onInit();
    loadCurriculum();
  }

  void loadCurriculum() {
    final curriculumData = _storage.getCurriculum();
    if (curriculumData != null && curriculumData['data'] != null) {
      final data = curriculumData['data'];

      final majors = data['ds_nganh_sinh_vien'] as List? ?? [];
      if (majors.isNotEmpty) {
        majorName.value = majors[0]['ten_nganh'] ?? '';
      }

      final semList = data['ds_CTDT_hocky'] as List? ?? [];
      semesters.value =
          semList.map((e) => CurriculumSemester.fromJson(e)).toList();
    }
  }

  void selectSemester(int index) => selectedSemesterIndex.value = index;

  List<CurriculumSubject> get currentSemesterSubjects {
    if (semesters.isEmpty) return [];
    return semesters[selectedSemesterIndex.value].subjects;
  }

  bool isSubjectClaimed(String maMon) => _gameService.isSubjectClaimed(maMon);

  bool semesterHasUnclaimedReward(int semesterIndex) {
    if (semesterIndex >= semesters.length) return false;
    return semesters[semesterIndex].subjects.any((sub) =>
        sub.isCompleted && sub.maMon.isNotEmpty && !isSubjectClaimed(sub.maMon));
  }

  int countUnclaimedInSemester(int semesterIndex) {
    if (semesterIndex >= semesters.length) return 0;
    return semesters[semesterIndex]
        .subjects
        .where((sub) =>
            sub.isCompleted &&
            sub.maMon.isNotEmpty &&
            !isSubjectClaimed(sub.maMon))
        .length;
  }

  int get totalUnclaimedRewards {
    int count = 0;
    for (int i = 0; i < semesters.length; i++) {
      count += countUnclaimedInSemester(i);
    }
    return count;
  }

  RewardClaimStatus getSubjectRewardStatus(CurriculumSubject subject) {
    if (!subject.isCompleted) return RewardClaimStatus.locked;
    if (claimingSubject.value == subject.maMon) return RewardClaimStatus.claiming;
    if (isSubjectClaimed(subject.maMon)) return RewardClaimStatus.claimed;
    return RewardClaimStatus.canClaim;
  }


  Future<void> claimSubjectReward(CurriculumSubject subject) async {
    if (subject.maMon.isEmpty || subject.soTinChi <= 0) return;
    if (claimingSubject.value.isNotEmpty) return;

    claimingSubject.value = subject.maMon;

    try {
      final result = await _gameService.claimSubjectReward(
        mssv: _authService.username.value,
        maMon: subject.maMon,
        tenMon: subject.tenMon,
        soTinChi: subject.soTinChi,
      );

      if (result != null) {
        DuoRewardDialog.showSubjectReward(
          tenMon: subject.tenMon,
          rewards: result,
        );
      }
    } finally {
      claimingSubject.value = '';
    }
  }

  final isClaimingAll = false.obs;

  List<Map<String, dynamic>> get allUnclaimedSubjectsForBatch {
    final List<Map<String, dynamic>> unclaimed = [];
    for (var semester in semesters) {
      for (var sub in semester.subjects) {
        if (sub.isCompleted &&
            sub.maMon.isNotEmpty &&
            sub.soTinChi > 0 &&
            !isSubjectClaimed(sub.maMon)) {
          unclaimed.add({
            'maMon': sub.maMon,
            'tenMon': sub.tenMon,
            'soTinChi': sub.soTinChi,
          });
        }
      }
    }
    return unclaimed;
  }

  Future<void> claimAllRewards() async {
    if (isClaimingAll.value) return;

    final unclaimed = allUnclaimedSubjectsForBatch;
    if (unclaimed.isEmpty) return;

    isClaimingAll.value = true;

    try {
      final result = await _gameService.claimAllSubjectRewards(
        mssv: _authService.username.value,
        subjects: unclaimed,
      );

      if (result != null && result['claimedCount'] > 0) {
        DuoRewardDialog.showSubjectReward(
          tenMon: '${result['claimedCount']} môn học',
          rewards: {
            'earnedCoins': result['earnedCoins'],
            'earnedDiamonds': result['earnedDiamonds'],
            'earnedXp': result['earnedXp'],
            'leveledUp': result['leveledUp'],
            'newLevel': result['newLevel'],
          },
        );
      }
    } finally {
      isClaimingAll.value = false;
    }
  }
}
