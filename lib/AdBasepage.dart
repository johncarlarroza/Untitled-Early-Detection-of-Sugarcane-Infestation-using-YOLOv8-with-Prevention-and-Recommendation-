import 'package:early_application_1/admin/admin_dashboard.dart';
import 'package:early_application_1/admin/admin_users.dart';
import 'package:early_application_1/admin/admin_signin.dart';
import 'package:early_application_1/admin/adminreports.dart';
import 'package:flutter/material.dart';

class AdminBasePage extends StatefulWidget {
  final int initialIndex;
  const AdminBasePage({this.initialIndex = 0, super.key});

  @override
  State<AdminBasePage> createState() => _AdminBasePageState();
}

class _AdminBasePageState extends State<AdminBasePage> {
  static const background = Color(0xFF0D100F);
  static const surface = Color(0xFF191F1C);
  static const green = Color(0xFF44D46B);
  static const orange = Color(0xFFFF922E);
  static const muted = Color(0xFF9EADA2);

  late int _currentIndex;
  static const _titles = ['Dashboard', 'Users', 'Reports'];
  static const _icons = [
    Icons.grid_view_rounded,
    Icons.people_alt_outlined,
    Icons.bar_chart_rounded,
  ];
  final List<Widget> _pages = const [
    AdminDashboard(),
    UsersPage(),
    AdminReports(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2).toInt();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminSignInPage()),
      (_) => false,
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text('Sign out?', style: TextStyle(color: Colors.white)),
        content: const Text('You will return to the admin sign-in page.',
            style: TextStyle(color: muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _logout();
            },
            child: const Text('Sign out', style: TextStyle(color: orange)),
          ),
        ],
      ),
    );
  }

  Widget _sideNavigation() {
    return Container(
      width: 226,
      color: surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 26, 16, 32),
              child: Row(children: [
                Icon(Icons.eco_rounded, color: green, size: 29),
                SizedBox(width: 10),
                Expanded(child: Text('PESCOA', style: TextStyle(
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w800))),
              ]),
            ),
            for (var i = 0; i < _titles.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Material(
                  color: _currentIndex == i
                      ? green.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _currentIndex = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 15),
                      child: Row(children: [
                        Icon(_icons[i], size: 21,
                            color: _currentIndex == i ? green : muted),
                        const SizedBox(width: 14),
                        Text(_titles[i], style: TextStyle(
                            color: _currentIndex == i ? green : muted,
                            fontWeight: _currentIndex == i
                                ? FontWeight.w700 : FontWeight.w500)),
                      ]),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sign out'),
                style: TextButton.styleFrom(
                    foregroundColor: orange,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 760;
      return Scaffold(
        backgroundColor: background,
        appBar: desktop ? null : AppBar(
          backgroundColor: background,
          surfaceTintColor: background,
          elevation: 0,
          titleSpacing: 16,
          title: Row(children: [
            const Icon(Icons.eco_rounded, color: green, size: 23),
            const SizedBox(width: 8),
            Flexible(child: Text('PESCOA  /  ${_titles[_currentIndex]}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white,
                    fontSize: 17, fontWeight: FontWeight.w700))),
          ]),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: orange),
            ),
            const SizedBox(width: 5),
          ],
        ),
        body: Row(children: [
          if (desktop) _sideNavigation(),
          Expanded(child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          )),
        ]),
        bottomNavigationBar: desktop ? null : SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) =>
                  TextStyle(fontSize: 11,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w700 : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? green : muted)),
            ),
            child: NavigationBar(
              height: 68,
              backgroundColor: surface,
              indicatorColor: green.withOpacity(0.14),
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              destinations: [
                for (var i = 0; i < _titles.length; i++)
                  NavigationDestination(
                    icon: Icon(_icons[i], color: muted),
                    selectedIcon: Icon(_icons[i], color: green),
                    label: _titles[i],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
