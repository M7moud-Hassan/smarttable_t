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

class _NotificationCardState extends ConsumerState<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: widget.notfificaionModel.isRead
            ? Colors.white
            : AppColors.secondryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(PngAssets.appLogoSmall, width: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.notfificaionModel.title,
                              style: context.textTheme.titleMedium!.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\n${widget.notfificaionModel.timeCreated} - ${widget.notfificaionModel.dateCreated}',
                              style: context.textTheme.bodySmall!.copyWith(
                                color: AppColors.textGrayColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  const Divider(
                    color: AppColors.primaryColor,
                    height: 1,
                    thickness: 1.2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.notfificaionModel.body,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmDialogWidget(
                                  title: context.locale.deleteNotification,
                                  onConfirm: () {
                                    ref
                                        .read(
                                            notificationsMangeProvider.notifier)
                                        .deleteNotification(
                                          widget.notfificaionModel.id,
                                        );
                                  },
                                );
                              },
                            );
                          },
                          icon: SvgPicture.asset(
                            SvgAssets.trash,
                            colorFilter: const ColorFilter.mode(
                              AppColors.pinkColor,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
