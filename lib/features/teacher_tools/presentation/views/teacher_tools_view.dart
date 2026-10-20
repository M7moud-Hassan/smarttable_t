import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/classroom_timer_view.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/quick_question_view.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/random_pick_view.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/session_summary_view.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/seat_map_view.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class TeacherToolsView extends StatelessWidget {
  TeacherToolsView({
    super.key,
    required LessonModel lesson,
    this.embedded = false,
  }) : lessonContext = TeacherToolsContext(
          classId: lesson.classroomId,
          className: lesson.classroomName,
          session: lesson.classNumber,
          sessionLabel: lesson.classNumberText,
          subject: lesson.subjectName,
          date: DateTime.now(),
        );

  const TeacherToolsView.withContext({
    super.key,
    required this.lessonContext,
    this.embedded = false,
  });

  final TeacherToolsContext lessonContext;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final tools = <_ToolDefinition>[
      _ToolDefinition(
        title: 'السؤال السريع',
        icon: Icons.quiz_outlined,
        color: AppColors.primaryColor,
        badge: 'خطوتان',
        page: QuickQuestionView(lessonContext: lessonContext),
      ),
      _ToolDefinition(
        title: 'اختيار عشوائي',
        icon: Icons.casino_outlined,
        color: teacherToolsBlue,
        badge: 'أثناء الحصة',
        page: RandomPickView(lessonContext: lessonContext),
      ),
      _ToolDefinition(
        title: 'مخطط المقاعد',
        icon: Icons.event_seat_outlined,
        color: teacherToolsAmber,
        badge: 'للفصل',
        page: SeatMapView(lessonContext: lessonContext),
      ),
      _ToolDefinition(
        title: 'ملخص الحصة',
        icon: Icons.assessment_outlined,
        color: teacherToolsGreen,
        badge: 'نهاية الحصة',
        page: SessionSummaryView(lessonContext: lessonContext),
      ),
      const _ToolDefinition(
        title: 'مؤقت الحصة',
        icon: Icons.timer_outlined,
        color: AppColors.secondryColor,
        badge: 'محلي',
        page: ClassroomTimerView(),
      ),
    ];

    final body = SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          TeacherToolsContextCard(lessonContext: lessonContext),
          const SizedBox(height: 22),
          const TeacherToolSectionTitle(
            title: 'ماذا تريد أن تفعل؟',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tools.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 154,
                ),
                itemBuilder: (_, index) => _TeacherToolCard(
                  definition: tools[index],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondryColor,
                  size: 21,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'السؤال السريع والاختيار العشوائي يعرضان الطلاب الحاضرين فقط. إذا لم يُسجّل الحضور بعد، تظهر قائمة الفصل كاملة.',
                    style: TextStyle(
                      color: Color(0xFF626262),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: embedded
          ? ColoredBox(color: Colors.white, child: body)
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: const TeacherToolsAppBar(title: 'أدوات الحصة'),
              body: body,
            ),
    );
  }
}

class _ToolDefinition {
  const _ToolDefinition({
    required this.title,
    required this.icon,
    required this.color,
    required this.badge,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String badge;
  final Widget page;
}

class _TeacherToolCard extends StatelessWidget {
  const _TeacherToolCard({required this.definition});

  final _ToolDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => definition.page),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: definition.color.withValues(alpha: .22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: definition.color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      definition.icon,
                      color: definition.color,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: definition.color,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: definition.color.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  definition.badge,
                  style: TextStyle(
                    color: definition.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                definition.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
