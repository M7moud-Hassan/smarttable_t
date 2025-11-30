import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/confirm_dialog_widget.dart';
import 'package:smart_table_app/features/notifications/providers/notifications_notifer.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/constants/constants.dart';
import '../../data/models/notifications_model.dart';

class NotificationCard extends ConsumerStatefulWidget {
  const NotificationCard({super.key, required this.notfificaionModel});
  final NotificationsModel notfificaionModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationCardState();
}

class _NotificationCardState extends ConsumerState<NotificationCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.notfificaionModel.isRead
          ? Colors.transparent
          : AppColors.secondryColor,
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 25,
                          spreadRadius: -5,
                          offset: Offset(
                            0,
                            20,
                          ),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 10,
                          spreadRadius: -5,
                          offset: Offset(
                            0,
                            10,
                          ),
                        ),
                      ]),
                  child: Image.asset(PngAssets.appLogoSmall, width: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.notfificaionModel.title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppAssets.arFont),
                        ),
                        TextSpan(
                          text:
                              ' ${widget.notfificaionModel.timeCreated}\n ${widget.notfificaionModel.dateCreated}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: AppAssets.arFont),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: expanded
                        ? AppColors.primaryColor
                        : AppColors.grayBordredColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    color: expanded ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Wrap the expanding content in AnimatedSize to animate the height change
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 70),
              Expanded(
                child: Text(
                  widget.notfificaionModel.body,
                  maxLines: expanded ? null : 2,
                ),
              ),
              const SizedBox(width: 10),
              if (expanded)
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmDialogWidget(
                              title: context.locale.deleteNotification,
                              onConfirm: () {
                                ref
                                    .read(notificationsMangeProvider.notifier)
                                    .deleteNotification(
                                      widget.notfificaionModel.id,
                                    );
                              });
                        });
                  },
                  icon: SvgPicture.asset(SvgAssets.trash),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
