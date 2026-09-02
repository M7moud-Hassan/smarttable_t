import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:svg_flutter/svg.dart';

import '../data/models/layout_model.dart';

class MainBottomNavigationBar extends StatelessWidget {
  const MainBottomNavigationBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<LayoutModel> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: 85 + bottomInset,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textGrayColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          ...tabs.map(
            (item) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SvgPicture.asset(
                  item.inActiveIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textGrayColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SvgPicture.asset(
                    item.activeIcon,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              label: item.title,
            ),
          ),
        ],
      ),
    );
  }
}
