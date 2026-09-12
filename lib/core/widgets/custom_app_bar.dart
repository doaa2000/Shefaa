import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final Function(String)? onSearch;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.onSearch,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      leading:
          canGoBack
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightPrimaryColor, AppColors.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      title:
          showSearch
              ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
              : Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(showSearch ? 90 : kToolbarHeight + 20);
}
