import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/animation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../features/gamification/utils/rank_helper.dart';
import '../../../../core/components/widgets.dart';
import '../../../../features/gamification/widgets/game_widgets.dart';
import '../controllers/grades_controller.dart';

class GradesView extends GetView<GradesController> {
  const GradesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Xếp hạng học tập',
            style: TextStyle(
              fontSize: AppStyles.textLg,
              fontWeight: AppStyles.fontBold,
              color: Colors.white,
            ),
          ),
          actions: [
            // Icon gift với badge chấm đỏ
            Obx(() => _buildGiftButton()),
          ],
          bottom: TabBar(
            onTap: controller.selectTab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.withAlpha(Colors.white, 0.6),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontSemibold,
            ),
            tabs: const [
              Tab(text: 'Rank'),
              Tab(text: 'Học kỳ'),
              Tab(text: 'Phân tích'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRankTab(),
            _buildSemesterTab(),
            _buildAnalysisTab(),
          ],
        ),
      ),
    );
  }

  // === TAB 1: RANK ===
  Widget _buildRankTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        children: [
          Obx(() => DuoRankCard(
                tier: controller.currentTier,
                level: controller.currentLevel,
                rankIndex: controller.rankIndex,
                rankAsset: controller.rankAsset,
              )).animateFadeSlide(slideBegin: -0.1),
          SizedBox(height: AppStyles.space4),
          Obx(() => DuoStatCard(
                title: 'Điểm tích lũy',
                stats: [
                  DuoStatItem(label: 'GPA (Hệ 10)', value: controller.gpa10),
                  DuoStatItem(label: 'GPA (Hệ 4)', value: controller.gpa4),
                  DuoStatItem(label: 'Tín chỉ', value: controller.totalCredits),
                ],
              )).animateFadeSlide(delay: 100),
          SizedBox(height: AppStyles.space4),
          Obx(() => DuoRankProgress(
                currentRankName: controller.rankName,
                nextRankName: RankHelper.isMaxRank(controller.rankIndex)
                    ? ''
                    : RankHelper.getRankNameFromIndex(controller.rankIndex + 1),
                gpaForNextRank: controller.gpaForNextRank,
                progress: controller.progressToNextRank,
                rankColor: controller.rankColor,
                isMaxRank: RankHelper.isMaxRank(controller.rankIndex),
              )).animateFadeSlide(delay: 200),
          SizedBox(height: AppStyles.space6),
        ],
      ),
    );
  }

  // === TAB 2: SEMESTER ===
  Widget _buildSemesterTab() {
    return Column(
      children: [
        // Semester selector
        Obx(() {
          if (controller.gradesBySemester.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: AppStyles.space3, bottom: AppStyles.space2),
            child: DuoChipSelector<int>(
              selectedValue: controller.selectedSemesterIndex.value,
              activeColor: AppColors.primary,
              height: 40,
              items: controller.gradesBySemester.asMap().entries.map((entry) {
                final index = entry.key;
                final semester = entry.value;
                final tenHK = semester['ten_hoc_ky'] as String? ?? '';
                final shortName = tenHK.replaceAll('Học kỳ ', 'HK').replaceAll(' - Năm học ', ' ');
                final hasGrades = (semester['ds_diem_mon_hoc'] as List?)?.any((g) {
                      final score = g['diem_tk']?.toString() ?? '';
                      return score.isNotEmpty;
                    }) ??
                    false;
                return DuoChipItem<int>(
                  value: index,
                  label: shortName,
                  hasContent: hasGrades,
                );
              }).toList(),
              onSelected: controller.selectSemester,
            ),
          );
        }),
        // Semester info
        Obx(() {
          final gpa10 = controller.semesterGpa10;
          final gpa4 = controller.semesterGpa4;
          final credits = controller.semesterCredits;
          final classification = controller.semesterClassification;

          if (gpa10.isEmpty && credits.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
              child: DuoMiniStatRow(
                stats: const [
                  DuoStatItem(label: 'Trạng thái', value: 'Đang học'),
                ],
              ),
            );
          }

          final stats = <DuoStatItem>[
            DuoStatItem(label: 'ĐTB (10)', value: gpa10),
            DuoStatItem(label: 'ĐTB (4)', value: gpa4),
            DuoStatItem(label: 'TC đạt', value: credits),
          ];
          if (classification.isNotEmpty) {
            stats.add(DuoStatItem(label: 'Xếp loại', value: classification));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
            child: DuoMiniStatRow(stats: stats),
          );
        }),
        SizedBox(height: AppStyles.space3),
        // Grades list
        Expanded(
          child: Obx(() {
            final grades = controller.currentSemesterGrades;
            if (grades.isEmpty) {
              return DuoEmptyState(
                icon: Iconsax.document,
                title: 'Chưa có điểm',
                subtitle: 'Điểm sẽ được cập nhật khi có kết quả',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppStyles.space4),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                final score = controller.getScore(grade);
                return Padding(
                  padding: EdgeInsets.only(bottom: AppStyles.space3),
                  child: DuoGradeCard(
                    subject: grade['ten_mon'] ?? 'N/A',
                    credits: grade['so_tin_chi']?.toString() ?? '0',
                    group: grade['nhom_to']?.toString(),
                    score: score,
                    letterGrade: grade['diem_tk_chu']?.toString(),
                    score4: grade['diem_tk_so']?.toString(),
                    note: score.isEmpty ? 'Chưa có điểm' : null,
                  ),
                ).animateListItem(index: index, staggerDelay: 30, duration: 200);
              },
            );
          }),
        ),
      ],
    );
  }

  // === TAB 3: ANALYSIS ===
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => DuoGradeOverview(
                totalSubjects: controller.totalSubjects,
                passedSubjects: controller.passedSubjects,
                excellentSubjects: controller.excellentSubjects,
              )).animateFadeSlide(),
          SizedBox(height: AppStyles.space4),
          Obx(() {
            final dist = controller.gradesByClassification;
            return DuoGradeDistribution(
              distribution: {
                'Xuất sắc': dist['Xuất sắc']!.length,
                'Giỏi': dist['Giỏi']!.length,
                'Khá': dist['Khá']!.length,
                'Trung bình': dist['Trung bình']!.length,
                'Yếu': dist['Yếu']!.length,
              },
              totalSubjects: controller.totalSubjects,
              getColor: controller.getClassificationColor,
            );
          }).animateFadeSlide(delay: 100),
          SizedBox(height: AppStyles.space4),
          Obx(() {
            final highest = controller.highestGrade;
            final lowest = controller.lowestGrade;
            if (highest == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm nổi bật',
                  style: TextStyle(
                    fontSize: AppStyles.textLg,
                    fontWeight: AppStyles.fontBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppStyles.space3),
                DuoGradeHighlight(
                  title: 'Điểm cao nhất',
                  subject: highest['ten_mon'] ?? '',
                  score: controller.getScore(highest),
                  color: AppColors.green,
                  isHighest: true,
                ),
                if (lowest != null) ...[
                  SizedBox(height: AppStyles.space3),
                  DuoGradeHighlight(
                    title: 'Điểm thấp nhất',
                    subject: lowest['ten_mon'] ?? '',
                    score: controller.getScore(lowest),
                    color: AppColors.orange,
                    isHighest: false,
                  ),
                ],
              ],
            );
          }).animateFadeSlide(delay: 200),
          SizedBox(height: AppStyles.space4),
          // Danh sách môn theo học lực
          Obx(() => _buildGradesByClassification()),
          SizedBox(height: AppStyles.space6),
        ],
      ),
    );
  }

  /// Nút gift trên AppBar với badge chấm đỏ nếu có reward chưa nhận
  Widget _buildGiftButton() {
    final hasUnclaimed = controller.hasUnclaimedRewards;
    final unclaimedCount = controller.unclaimedRankCount;
    
    return Padding(
      padding: EdgeInsets.only(right: AppStyles.space2),
      child: Stack(
        children: [
          IconButton(
            onPressed: controller.openRankRewardsSheet,
            icon: Image.asset(
              AppAssets.giftPurple,
              width: 28,
              height: 28,
            ),
          ),
          // Badge chấm đỏ
          if (hasUnclaimed)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unclaimedCount > 9 ? '9+' : unclaimedCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradesByClassification() {
    final dist = controller.gradesByClassification;
    final categories = ['Xuất sắc', 'Giỏi', 'Khá', 'Trung bình', 'Yếu'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết theo học lực',
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppStyles.space3),
        ...categories.where((cat) => dist[cat]!.isNotEmpty).map((category) {
          final grades = dist[category]!;
          final color = controller.getClassificationColor(category);
          return DuoGradeCategory(
            title: category,
            count: grades.length,
            color: color,
            items: grades
                .map((g) => DuoGradeCategoryItem(
                      subject: g['ten_mon'] ?? '',
                      score: controller.getScore(g),
                      letterGrade: g['diem_tk_chu']?.toString() ?? '',
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}




