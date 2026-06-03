import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/home/data/models/home_data_model.dart';
import 'package:smart_table_app/features/home/data/models/menu_data_model.dart';
import 'package:smart_table_app/features/home/data/repositories/home_repo.dart';

final homeMenuProvider = FutureProvider<HomeDataModel>((ref) async {
  final apiResponse = await ref.read(homeRepoProvider).getHomeMenues();
  return HomeDataModel(
    welcome: apiResponse.welcome,
    menus: [
      // Smart Schedule Tab (Tab 0)
      MenuDataModel(
        id: 1,
        image: "",
        title: "الجدول المدرسي",
        key: "school_schedule",
        description: "",
        isActive: true,
        displayOrder: 1,
      ),
      MenuDataModel(
        id: 2,
        image: "",
        title: "حصص الإنتظار",
        key: "waiting_classes",
        description: "",
        isActive: true,
        displayOrder: 2,
      ),
      MenuDataModel(
        id: 3,
        image: "",
        title: "المهام المجدولة",
        key: "scheduled_tasks",
        description: "",
        isActive: true,
        displayOrder: 4,
      ),
      MenuDataModel(
        id: 10,
        image: "",
        title: "لجان الإختبارات",
        key: "exam_committees",
        description: "",
        isActive: true,
        displayOrder: 3,
      ),

      // Administrative Follow-up Tab (Tab 1)
      MenuDataModel(
        id: 4,
        image: "",
        title: "ملاحظات الإدارة",
        key: "admin_notes",
        description: "",
        isActive: true,
        displayOrder: 5,
      ),
      MenuDataModel(
        id: 5,
        image: "",
        title: "التعاميم الإدارية",
        key: "admin_circulars",
        description: "",
        isActive: true,
        displayOrder: 6,
      ),
      MenuDataModel(
        id: 6,
        image: "",
        title: "الحالات الصحية",
        key: "health_cases",
        description: "",
        isActive: true,
        displayOrder: 7,
      ),
      MenuDataModel(
        id: 7,
        image: "",
        title: "الزيارات الصفية",
        key: "class_visits",
        description: "",
        isActive: true,
        displayOrder: 8,
      ),
      MenuDataModel(
        id: 8,
        image: "",
        title: "الحالات الإجتماعية",
        key: "social_cases",
        description: "",
        isActive: true,
        displayOrder: 9,
      ),
      MenuDataModel(
        id: 9,
        image: "",
        title: "الخطة الأسبوعية",
        key: "weekly_plan",
        description: "",
        isActive: true,
        displayOrder: 10,
      ),
      MenuDataModel(
        id: 11,
        image: "",
        title: "شواهد الأداء",
        key: "performance_evidence",
        description: "",
        isActive: true,
        displayOrder: 11,
      ),
    ],
  );
});




