import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
