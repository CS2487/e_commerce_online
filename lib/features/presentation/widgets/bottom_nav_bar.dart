import 'package:shopping/core/imports/imports.dart';

import '../screens/cart/cart_screen.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartPage(),
    const FavoritesPage(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double width = MediaQuery.of(context).size.width;

    if (width >= 1025) {
      // Desktop View
      return Scaffold(
        body: Row(
          children: [
            _buildSideNavigationBar(l10n), // Sidebar for navigation
            Expanded(
              child: _screens[_currentIndex], // Main content area
            ),
          ],
        ),
      );
    } else if (width >= 768) {
      // Tablet View
      return Scaffold(
        body: Row(
          children: [
            _buildSideNavigationBar(l10n), // Compact Sidebar
            Expanded(
              child: _screens[_currentIndex], // Main content area
            ),
          ],
        ),
      );
    } else {
      // Mobile View
      return Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.home, // Translated label for "Home"
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: l10n.cart, // Translated label for "Cart"
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: l10n.favorites, // Translated label for "Favorites"
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: l10n.profile, // Translated label for "Profile"
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      );
    }
  }

  Widget _buildSideNavigationBar(AppLocalizations l10n) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home),
          label: Text(l10n.home), // Translated label for "Home"
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.shopping_cart),
          label: Text(l10n.cart), // Translated label for "Cart"
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.favorite),
          label: Text(l10n.favorites), // Translated label for "Favorites"
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person),
          label: Text(l10n.profile), // Translated label for "Profile"
        ),
      ],
    );
  }
}
