import 'package:get/get.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/game_service.dart';
import '../../../data/services/storage_service.dart';

class CurriculumController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GameService _gameService = Get.find<GameService>();
  final AuthService _authService = Get.find<AuthService>();

  final semesters = <Map<String, dynamic>>[].obs;
  final selectedSemesterIndex = 0.obs;
  final majorName = ''.obs;
  final claimingSubject = ''.obs; // Mã môn đang claim

  // Thống kê
  int get totalCredits {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        total += int.tryParse(sub['so_tin_chi']?.toString() ?? '0') ?? 0;
      }
    }
    return total;
  }

  int get completedCredits {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        if (sub['mon_da_dat'] == 'x') {
          total += int.tryParse(sub['so_tin_chi']?.toString() ?? '0') ?? 0;
        }
      }
    }
    return total;
  }

  int get totalSubjects {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      total += subjects.length;
    }
    return total;
  }

  int get completedSubjects {
    int total = 0;
    for (var sem in semesters) {
      final subjects = sem['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        if (sub['mon_da_dat'] == 'x') total++;
      }
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    loadCurriculum();
  }

  void loadCurriculum() {
    final curriculumData = _storage.getCurriculum();
    if (curriculumData != null && curriculumData['data'] != null) {
      final data = curriculumData['data'];

      // Lấy tên ngành
      final majors = data['ds_nganh_sinh_vien'] as List? ?? [];
      if (majors.isNotEmpty) {
        majorName.value = majors[0]['ten_nganh'] ?? '';
      }

      // Lấy danh sách học kỳ
      final semList = data['ds_CTDT_hocky'] as List? ?? [];
      semesters.value = semList.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  void selectSemester(int index) {
    selectedSemesterIndex.value = index;
  }

  List<Map<String, dynamic>> get currentSemesterSubjects {
    if (semesters.isEmpty) return [];
    final semester = semesters[selectedSemesterIndex.value];
    final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
    return subjects.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Kiểm tra môn học đã claim reward chưa
  bool isSubjectClaimed(String maMon) {
    return _gameService.isSubjectClaimed(maMon);
  }

  /// Kiểm tra học kỳ có môn đạt chưa nhận thưởng không
  bool semesterHasUnclaimedReward(int semesterIndex) {
    if (semesterIndex >= semesters.length) return false;
    final semester = semesters[semesterIndex];
    final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
    
    for (var sub in subjects) {
      final isCompleted = sub['mon_da_dat'] == 'x';
      final maMon = sub['ma_mon'] as String? ?? '';
      if (isCompleted && maMon.isNotEmpty && !isSubjectClaimed(maMon)) {
        return true;
      }
    }
    return false;
  }

  /// Đếm số môn chưa nhận thưởng trong học kỳ
  int countUnclaimedInSemester(int semesterIndex) {
    if (semesterIndex >= semesters.length) return 0;
    final semester = semesters[semesterIndex];
    final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
    
    int count = 0;
    for (var sub in subjects) {
      final isCompleted = sub['mon_da_dat'] == 'x';
      final maMon = sub['ma_mon'] as String? ?? '';
      if (isCompleted && maMon.isNotEmpty && !isSubjectClaimed(maMon)) {
        count++;
      }
    }
    return count;
  }

  /// Tổng số môn chưa nhận thưởng
  int get totalUnclaimedRewards {
    int count = 0;
    for (int i = 0; i < semesters.length; i++) {
      count += countUnclaimedInSemester(i);
    }
    return count;
  }

  /// Lấy trạng thái reward của môn học
  SubjectRewardStatus getSubjectRewardStatus(Map<String, dynamic> subject) {
    final isCompleted = subject['mon_da_dat'] == 'x';
    final maMon = subject['ma_mon'] as String? ?? '';
    
    if (!isCompleted) return SubjectRewardStatus.notCompleted;
    if (claimingSubject.value == maMon) return SubjectRewardStatus.claiming;
    if (isSubjectClaimed(maMon)) return SubjectRewardStatus.claimed;
    return SubjectRewardStatus.canClaim;
  }

  /// Nhận thưởng cho môn học đạt
  Future<void> claimSubjectReward(Map<String, dynamic> subject) async {
    final maMon = subject['ma_mon'] as String? ?? '';
    final tenMon = subject['ten_mon'] as String? ?? '';
    final soTinChi = int.tryParse(subject['so_tin_chi']?.toString() ?? '0') ?? 0;
    
    if (maMon.isEmpty || soTinChi <= 0) return;
    if (claimingSubject.value.isNotEmpty) return; // Đang claim môn khác
    
    claimingSubject.value = maMon;
    
    try {
      final result = await _gameService.claimSubjectReward(
        mssv: _authService.username.value,
        maMon: maMon,
        tenMon: tenMon,
        soTinChi: soTinChi,
      );
      
      if (result != null) {
        // Hiển thị dialog nhận thưởng môn học
        DuoRewardDialog.showSubjectReward(
          tenMon: tenMon,
          rewards: result,
        );
      }
    } finally {
      claimingSubject.value = '';
    }
  }

  final isClaimingAll = false.obs;

  /// Lấy danh sách tất cả môn chưa claim (format cho batch API)
  List<Map<String, dynamic>> get allUnclaimedSubjectsForBatch {
    final List<Map<String, dynamic>> unclaimed = [];
    for (var semester in semesters) {
      final subjects = semester['ds_CTDT_mon_hoc'] as List? ?? [];
      for (var sub in subjects) {
        final isCompleted = sub['mon_da_dat'] == 'x';
        final maMon = sub['ma_mon'] as String? ?? '';
        final soTinChi = int.tryParse(sub['so_tin_chi']?.toString() ?? '0') ?? 0;
        if (isCompleted && maMon.isNotEmpty && soTinChi > 0 && !isSubjectClaimed(maMon)) {
          unclaimed.add({
            'maMon': maMon,
            'tenMon': sub['ten_mon'] ?? '',
            'soTinChi': soTinChi,
          });
        }
      }
    }
    return unclaimed;
  }

  /// Nhận tất cả thưởng môn học đạt (batch - nhanh hơn)
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
