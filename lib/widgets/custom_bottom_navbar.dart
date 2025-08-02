import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final ValueChanged<int>? onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.onFilterPressed,
    this.onTabSelected,
  });

  static const _routes = ['/home', '/tenders', '/notifications', '/profile'];

  int _getCurrentIndex(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    return _routes.indexOf(currentRoute);
  }

  void _onTabTapped(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
    }
    // Also navigate to the correct route if not already there
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    if (_routes[index] != currentRoute) {
      Navigator.pushNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(context, Icons.home, "Home", 0, currentIndex),
            _buildNavItem(
              context,
              Icons.description,
              "My Tenders",
              1,
              currentIndex,
            ),
            _buildNavItem(
              context,
              Icons.bookmark,
              "Favourites",
              2,
              currentIndex,
            ),
            _buildNavItem(context, Icons.person, "My Account", 3, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    bool isSelected = currentIndex == index;
    const EdgeInsets itemPadding = EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    );
    const double navItemWidth = 90;
    return InkWell(
      onTap: () => _onTabTapped(context, index),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: navItemWidth,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C989C) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: itemPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
