import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Components/BottomNavBar.dart';
import 'package:go_toba/Providers/NavBarProv.dart';
import 'package:go_toba/Providers/UserProv.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = context.read<UserProvider>().uid;

    if (uid == null || uid.trim().isEmpty) return;

    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        final username = (userData['username'] ?? userData['name'] ?? '')
            .toString();
        final email = (userData['email'] ?? '').toString();
        final phone = (userData['phone'] ?? '').toString();
        final profilePhoto = (userData['profilephoto'] ?? '').toString();

        if (!mounted) return;
        context.read<UserProvider>().updateUserData(
              username,
              email,
              phone,
              profilePhoto,
            );
      }
    } catch (_) {
      // Keep app usable even if user profile document is incomplete/corrupted.
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NavBarProv>();
    return Scaffold(
      body: prov.body[prov.dataCurrentIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
