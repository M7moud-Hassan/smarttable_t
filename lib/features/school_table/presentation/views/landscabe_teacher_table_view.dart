import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../providers/teacher_table_provider.dart';
import '../widgets/teacher_table_widget.dart';

class LandscabeTeacherTableView extends ConsumerStatefulWidget {
  const LandscabeTeacherTableView({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LandscabeTeacherTableViewState();
}

class _LandscabeTeacherTableViewState
    extends ConsumerState<LandscabeTeacherTableView> {
  bool fitScreen = false;
  @override
  void initState() {
    super.initState();
    // Lock the orientation to portrait mode for this screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    // Revert back to the default orientation settings when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherTableAsyncValue = ref.watch(teacherTableProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(context.locale.showFullScheduleAppBar),
          actions: [
            IconButton(
                onPressed: () => setState(() => fitScreen = !fitScreen),
                icon:
                    Icon(fitScreen ? Icons.fullscreen_exit : Icons.fullscreen))
          ],
        ),
        body: SingleChildScrollView(
          child: teacherTableAsyncValue.when(
            data: (data) {
              final headerClasess =
                  getHeaderClassesList(data.tableInfo.first.lessons);
              final lessonsData = prepareLessonsData(
                  data.tableInfo.first.lessons,
                  data.tableInfo.first.daysOfWeek,
                  headerClasess.length);
              return DashedBorderTable(
                headerClasess: headerClasess,
                daysOfWeek: data.tableInfo.first.daysOfWeek,
                lessonsData: lessonsData,
                isLandscape: fitScreen,
              );
            },
            error: (error, stackTrace) => CustomErrorWidget(
              onTap: () => ref.invalidate(teacherTableProvider),
            ),
            loading: () => const Center(child: LoadingWidget()),
          ),
        ));
  }
}
