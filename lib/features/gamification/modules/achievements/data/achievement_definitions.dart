import '../models/achievement_model.dart';

/// Định nghĩa tất cả thành tựu trong hệ thống
/// Hệ thống mở rộng vô tận với các chuỗi milestone
/// Icon được lấy từ AchievementIcons helper dựa trên category/id
class AchievementDefinitions {
  AchievementDefinitions._();

  // ============ ACADEMIC ACHIEVEMENTS (Học tập) ============

  /// Chuỗi thành tựu: Số môn đạt
  /// Mở rộng vô tận: 1, 5, 10, 20, 30, 50, 75, 100, 150, 200...
  static List<Achievement> subjectPassedSeries() {
    final milestones = [1, 5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 500];
    return _generateSeries(
      baseId: 'subject_passed',
      baseName: 'Chinh Phục Tri Thức',
      baseDescription: 'Hoàn thành {target} môn học',
      category: AchievementCategory.academic,
      milestones: milestones,
    );
  }

  /// Chuỗi thành tựu: Tổng tín chỉ tích lũy
  /// Mở rộng: 10, 30, 60, 90, 120, 150, 180, 200+
  static List<Achievement> creditsSeries() {
    final milestones = [10, 30, 60, 90, 120, 150, 180, 200, 250, 300];
    return _generateSeries(
      baseId: 'credits_earned',
      baseName: 'Tích Lũy Kiến Thức',
      baseDescription: 'Tích lũy {target} tín chỉ',
      category: AchievementCategory.academic,
      milestones: milestones,
    );
  }

  /// Chuỗi thành tựu: GPA tích lũy
  /// Mở rộng: 5.0, 6.0, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5
  static List<Achievement> gpaSeries() {
    final milestones = [50, 60, 70, 75, 80, 85, 90, 95]; // x10 để dùng int
    return _generateSeriesCustom(
      baseId: 'gpa_milestone',
      names: [
        'Khởi Đầu Vững Chắc',
        'Tiến Bộ Đều Đặn',
        'Học Sinh Khá',
        'Vượt Trội',
        'Học Sinh Giỏi',
        'Xuất Sắc',
        'Thủ Khoa Tiềm Năng',
        'Đỉnh Cao Học Thuật',
      ],
      descriptions:
          milestones.map((m) => 'Đạt GPA tích lũy ${m / 10}').toList(),
      category: AchievementCategory.academic,
      milestones: milestones,
      tiers: [
        AchievementTier.wood,
        AchievementTier.stone,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  /// Chuỗi thành tựu: Điểm A (9.0+)
  static List<Achievement> gradeASeries() {
    final milestones = [1, 3, 5, 10, 15, 20, 30, 50];
    return _generateSeries(
      baseId: 'grade_a',
      baseName: 'Điểm A Xuất Sắc',
      baseDescription: 'Đạt {target} môn điểm A (9.0+)',
      category: AchievementCategory.academic,
      milestones: milestones,
    );
  }

  /// Chuỗi thành tựu: Điểm 10
  static List<Achievement> perfectScoreSeries() {
    final milestones = [1, 2, 3, 5, 7, 10, 15, 20];
    return _generateSeriesCustom(
      baseId: 'perfect_score',
      names: [
        'Điểm 10 Đầu Tiên',
        'Hoàn Hảo Đôi',
        'Hat-trick Hoàn Hảo',
        'Ngôi Sao Sáng',
        'Thiên Tài Nổi Bật',
        'Bậc Thầy Hoàn Hảo',
        'Huyền Thoại Học Đường',
        'Thần Đồng',
      ],
      descriptions: milestones.map((m) => 'Đạt $m môn điểm 10').toList(),
      category: AchievementCategory.academic,
      milestones: milestones,
      tiers: [
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  // ============ ATTENDANCE ACHIEVEMENTS (Chuyên cần) ============

  /// Chuỗi thành tựu: Số tiết đã học
  static List<Achievement> lessonsAttendedSeries() {
    final milestones = [10, 50, 100, 200, 500, 1000, 2000, 5000, 10000];
    return _generateSeries(
      baseId: 'lessons_attended',
      baseName: 'Chăm Chỉ Học Tập',
      baseDescription: 'Tham gia {target} tiết học',
      category: AchievementCategory.attendance,
      milestones: milestones,
    );
  }

  /// Chuỗi thành tựu: Tỷ lệ chuyên cần
  static List<Achievement> attendanceRateSeries() {
    final milestones = [50, 60, 70, 80, 85, 90, 95, 100]; // %
    return _generateSeriesCustom(
      baseId: 'attendance_rate',
      names: [
        'Bắt Đầu Đi Học',
        'Cố Gắng Hơn',
        'Khá Chuyên Cần',
        'Chuyên Cần Tốt',
        'Rất Chuyên Cần',
        'Siêu Chuyên Cần',
        'Gần Như Hoàn Hảo',
        'Chuyên Cần Tuyệt Đối',
      ],
      descriptions:
          milestones.map((m) => 'Đạt tỷ lệ chuyên cần $m%').toList(),
      category: AchievementCategory.attendance,
      milestones: milestones,
      tiers: [
        AchievementTier.wood,
        AchievementTier.stone,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  /// Chuỗi thành tựu: Tổng số buổi đã check-in
  static List<Achievement> checkInTotalSeries() {
    final milestones = [5, 10, 25, 50, 100, 200, 500, 1000];
    return _generateSeriesCustom(
      baseId: 'checkin_total',
      names: [
        'Bắt Đầu Check-in',
        'Sinh Viên Chăm Chỉ',
        'Đi Học Đều Đặn',
        'Nửa Trăm Buổi',
        'Trăm Buổi Học',
        'Siêu Chuyên Cần',
        'Huyền Thoại Điểm Danh',
        'Vua Check-in',
      ],
      descriptions:
          milestones.map((m) => 'Check-in $m buổi học').toList(),
      category: AchievementCategory.attendance,
      milestones: milestones,
      tiers: [
        AchievementTier.wood,
        AchievementTier.stone,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  // ============ FINANCIAL ACHIEVEMENTS (Tài chính) ============

  /// Chuỗi thành tựu: Học phí đã đóng
  static List<Achievement> tuitionPaidSeries() {
    // Đơn vị: triệu VND
    final milestones = [5, 10, 20, 50, 100, 150, 200, 300];
    return _generateSeriesCustom(
      baseId: 'tuition_paid',
      names: [
        'Đầu Tư Đầu Tiên',
        'Sinh Viên Gương Mẫu',
        'Đóng Góp Đáng Kể',
        'Nhà Đầu Tư Giáo Dục',
        'Trăm Triệu Tri Thức',
        'Đại Gia Học Đường',
        'Tỷ Phú Tri Thức',
        'Huyền Thoại Đầu Tư',
      ],
      descriptions: milestones.map((m) => 'Đóng học phí ${m}M VND').toList(),
      category: AchievementCategory.financial,
      milestones: milestones.map((m) => m * 1000000).toList(), // Convert to VND
      tiers: [
        AchievementTier.wood,
        AchievementTier.stone,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  /// Chuỗi thành tựu: Số học kỳ đóng đủ
  static List<Achievement> semestersPaidSeries() {
    final milestones = [1, 2, 4, 6, 8, 10, 12, 16];
    return _generateSeries(
      baseId: 'semesters_paid',
      baseName: 'Hoàn Thành Nghĩa Vụ',
      baseDescription: 'Đóng đủ học phí {target} học kỳ',
      category: AchievementCategory.financial,
      milestones: milestones,
    );
  }

  // ============ PROGRESS ACHIEVEMENTS (Tiến trình game) ============

  /// Chuỗi thành tựu: Level
  static List<Achievement> levelSeries() {
    final milestones = [5, 10, 20, 30, 50, 75, 100, 150, 200, 500];
    return _generateSeries(
      baseId: 'level_reached',
      baseName: 'Cấp Độ Mới',
      baseDescription: 'Đạt level {target}',
      category: AchievementCategory.progress,
      milestones: milestones,
    );
  }

  /// Chuỗi thành tựu: Tổng coins kiếm được
  static List<Achievement> coinsEarnedSeries() {
    // Đơn vị: triệu coins
    final milestones = [1, 5, 10, 50, 100, 500, 1000, 5000];
    return _generateSeriesCustom(
      baseId: 'coins_earned',
      names: [
        'Triệu Phú Đầu Tiên',
        'Nhà Giàu Mới',
        'Chục Triệu Coins',
        'Đại Gia Coins',
        'Trăm Triệu Coins',
        'Tỷ Phú Coins',
        'Nghìn Tỷ Coins',
        'Huyền Thoại Giàu Có',
      ],
      descriptions: milestones.map((m) => 'Kiếm được ${m}M coins').toList(),
      category: AchievementCategory.progress,
      milestones: milestones.map((m) => m * 1000000).toList(),
      tiers: [
        AchievementTier.wood,
        AchievementTier.stone,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  /// Chuỗi thành tựu: Tổng diamonds kiếm được
  static List<Achievement> diamondsEarnedSeries() {
    final milestones = [1000, 5000, 10000, 50000, 100000, 500000, 1000000];
    return _generateSeriesCustom(
      baseId: 'diamonds_earned',
      names: [
        'Kim Cương Đầu Tiên',
        'Bộ Sưu Tập Nhỏ',
        'Vạn Kim Cương',
        'Kho Báu Kim Cương',
        'Trăm Nghìn Kim Cương',
        'Vua Kim Cương',
        'Triệu Kim Cương',
      ],
      descriptions: milestones.map((m) => 'Kiếm được $m diamonds').toList(),
      category: AchievementCategory.progress,
      milestones: milestones,
      tiers: [
        AchievementTier.wood,
        AchievementTier.bronze,
        AchievementTier.silver,
        AchievementTier.gold,
        AchievementTier.platinum,
        AchievementTier.amethyst,
        AchievementTier.onyx,
      ],
    );
  }

  /// Chuỗi thành tựu: Rank đạt được
  static List<Achievement> rankSeries() {
    return [
      const Achievement(
        id: 'rank_stone',
        name: 'Lên Hạng Đá',
        description: 'Đạt rank Đá',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.stone,
        targetValue: 7, // Rank index 7 = Stone I
        seriesIndex: 0,
      ),
      const Achievement(
        id: 'rank_bronze',
        name: 'Lên Hạng Đồng',
        description: 'Đạt rank Đồng',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.bronze,
        targetValue: 14,
        seriesIndex: 1,
      ),
      const Achievement(
        id: 'rank_silver',
        name: 'Lên Hạng Bạc',
        description: 'Đạt rank Bạc',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.silver,
        targetValue: 21,
        seriesIndex: 2,
      ),
      const Achievement(
        id: 'rank_gold',
        name: 'Lên Hạng Vàng',
        description: 'Đạt rank Vàng',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.gold,
        targetValue: 28,
        seriesIndex: 3,
      ),
      const Achievement(
        id: 'rank_platinum',
        name: 'Lên Hạng Bạch Kim',
        description: 'Đạt rank Bạch Kim',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.platinum,
        targetValue: 35,
        seriesIndex: 4,
      ),
      const Achievement(
        id: 'rank_amethyst',
        name: 'Lên Hạng Thạch Anh',
        description: 'Đạt rank Thạch Anh',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.amethyst,
        targetValue: 42,
        seriesIndex: 5,
      ),
      const Achievement(
        id: 'rank_onyx',
        name: 'Lên Hạng Hắc Ngọc',
        description: 'Đạt rank Hắc Ngọc',
        icon: '',
        category: AchievementCategory.progress,
        tier: AchievementTier.onyx,
        targetValue: 49,
        seriesIndex: 6,
      ),
    ];
  }

  // ============ SPECIAL ACHIEVEMENTS (Đặc biệt) ============

  static List<Achievement> specialAchievements() {
    return const [
      Achievement(
        id: 'first_login',
        name: 'Chào Mừng!',
        description: 'Đăng nhập lần đầu tiên',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.wood,
        targetValue: 1,
      ),
      Achievement(
        id: 'game_initialized',
        name: 'Bắt Đầu Hành Trình',
        description: 'Khởi tạo hệ thống game',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.wood,
        targetValue: 1,
      ),
      Achievement(
        id: 'first_checkin',
        name: 'Check-in Đầu Tiên',
        description: 'Check-in buổi học đầu tiên',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.wood,
        targetValue: 1,
      ),
      Achievement(
        id: 'first_subject_reward',
        name: 'Phần Thưởng Đầu Tiên',
        description: 'Nhận thưởng môn học đầu tiên',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.stone,
        targetValue: 1,
      ),
      Achievement(
        id: 'first_rank_reward',
        name: 'Thưởng Rank Đầu Tiên',
        description: 'Nhận thưởng rank đầu tiên',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.stone,
        targetValue: 1,
      ),
      Achievement(
        id: 'all_semester_paid',
        name: 'Sinh Viên Mẫu Mực',
        description: 'Đóng đủ học phí tất cả học kỳ',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.gold,
        targetValue: 1,
      ),
      Achievement(
        id: 'perfect_attendance_semester',
        name: 'Học Kỳ Hoàn Hảo',
        description: 'Chuyên cần 100% trong 1 học kỳ',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.platinum,
        targetValue: 1,
      ),
      Achievement(
        id: 'graduate',
        name: 'Tốt Nghiệp',
        description: 'Hoàn thành chương trình đào tạo',
        icon: '',
        category: AchievementCategory.special,
        tier: AchievementTier.onyx,
        targetValue: 1,
      ),
    ];
  }

  // ============ GET ALL ACHIEVEMENTS ============

  /// Lấy tất cả định nghĩa thành tựu
  static List<Achievement> getAllDefinitions() {
    return [
      // Academic
      ...subjectPassedSeries(),
      ...creditsSeries(),
      ...gpaSeries(),
      ...gradeASeries(),
      ...perfectScoreSeries(),
      // Attendance
      ...lessonsAttendedSeries(),
      ...attendanceRateSeries(),
      ...checkInTotalSeries(),
      // Financial
      ...tuitionPaidSeries(),
      ...semestersPaidSeries(),
      // Progress
      ...levelSeries(),
      ...coinsEarnedSeries(),
      ...diamondsEarnedSeries(),
      ...rankSeries(),
      // Special
      ...specialAchievements(),
    ];
  }

  /// Lấy thành tựu theo category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllDefinitions().where((a) => a.category == category).toList();
  }

  /// Lấy thành tựu theo ID
  static Achievement? getById(String id) {
    try {
      return getAllDefinitions().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ HELPER METHODS ============

  /// Tạo chuỗi thành tựu với tier tự động tăng
  static List<Achievement> _generateSeries({
    required String baseId,
    required String baseName,
    required String baseDescription,
    required AchievementCategory category,
    required List<int> milestones,
  }) {
    return List.generate(milestones.length, (index) {
      final tier = _getTierForIndex(index, milestones.length);
      return Achievement(
        id: '${baseId}_${milestones[index]}',
        name: '$baseName ${_toRoman(index + 1)}',
        description:
            baseDescription.replaceAll('{target}', milestones[index].toString()),
        icon: '', // Icon được lấy từ AchievementIcons helper
        category: category,
        tier: tier,
        targetValue: milestones[index],
        seriesIndex: index,
      );
    });
  }

  /// Tạo chuỗi thành tựu với tên và tier tùy chỉnh
  static List<Achievement> _generateSeriesCustom({
    required String baseId,
    required List<String> names,
    required List<String> descriptions,
    required AchievementCategory category,
    required List<int> milestones,
    required List<AchievementTier> tiers,
  }) {
    assert(names.length == milestones.length);
    assert(descriptions.length == milestones.length);
    assert(tiers.length == milestones.length);

    return List.generate(milestones.length, (index) {
      return Achievement(
        id: '${baseId}_${milestones[index]}',
        name: names[index],
        description: descriptions[index],
        icon: '', // Icon được lấy từ AchievementIcons helper
        category: category,
        tier: tiers[index],
        targetValue: milestones[index],
        seriesIndex: index,
      );
    });
  }

  /// Lấy tier dựa trên index trong chuỗi
  static AchievementTier _getTierForIndex(int index, int totalCount) {
    final tierCount = AchievementTier.values.length;
    final tierIndex =
        ((index / totalCount) * tierCount).floor().clamp(0, tierCount - 1);
    return AchievementTier.values[tierIndex];
  }

  /// Chuyển số thành số La Mã
  static String _toRoman(int number) {
    if (number <= 0 || number > 20) return number.toString();
    const romans = [
      'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
      'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX'
    ];
    return romans[number - 1];
  }
}
