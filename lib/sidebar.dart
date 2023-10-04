import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text('All Fire Tools'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Maps'),
            subtitle: const Text('Get real time imagery'),
            onTap: () => Navigator.pushNamed(context, '/Categories'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Prevention'),
            subtitle: const Text('Select APIs to call'),
            onTap: () => Navigator.pushNamed(context, '/APIs'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            subtitle: const Text('Configure app settings'),
            onTap: () => Navigator.pushNamed(context, '/Settings'),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Themes'),
            subtitle: const Text('Change app theme or style'),
            onTap: () => Navigator.pushNamed(context, '/Themes'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart),
            title: const Text('Report'),
            subtitle: const Text('View analytics and reports'),
            onTap: () => Navigator.pushNamed(context, '/Report'),
          ),
        ],
      ),
    );
  }
}
