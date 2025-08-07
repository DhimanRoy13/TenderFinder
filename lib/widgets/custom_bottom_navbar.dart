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

  // Selected/Unselected colors
  final Color _selectedItemColor = const Color(0xFF23BBBF);
  final Color _unselectedItemColor = Colors.white;

  int _getCurrentIndex(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    return _routes.indexOf(currentRoute);
  }

  void _onTabTapped(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
    }
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    if (_routes[index] != currentRoute) {
      Navigator.pushNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return BottomAppBar(
      color: const Color(0xFF222222),
      shape: const CircularNotchedRectangle(),
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
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: navItemWidth,
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: itemPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? _selectedItemColor : _unselectedItemColor,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _selectedItemColor : _unselectedItemColor,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
