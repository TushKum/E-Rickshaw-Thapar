// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:erickshaw/screens/driverinfo.dart';
import 'package:erickshaw/screens/select_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../theme/app_theme.dart';
import '../widgets/widget.dart';

class PassWait extends StatefulWidget {
  const PassWait({Key? key}) : super(key: key);

  @override
  State<PassWait> createState() => _PassWaitState();
}

class _PassWaitState extends State<PassWait> {
  late Databases db;
  StreamSubscription<Map<String, dynamic>?>? _sub;
  final auth = FirebaseAuth.instance;
  late String _uid;

  /// Guards against acting twice: clearing the request after a match pushes
  /// another snapshot through the same listener.
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
    _uid = auth.currentUser?.uid.toString() ?? "";
    _sub = db.watch_request(_uid).listen(_onRequestChanged);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onRequestChanged(Map<String, dynamic>? value) {
    if (!mounted || _handled || value == null) return;
    if (value['pending'] != '1') return;

    _handled = true;
    _sub?.cancel();

    final from = value['from'] as String? ?? '';
    final to = value['to'] as String? ?? '';
    final driverUid = value['driver_uid'] as String? ?? '';

    db.delete(_uid);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => driver_details(uid: driverUid, pfrom: from, to: to),
      ),
    );
  }

  void _cancel() {
    _handled = true;
    _sub?.cancel();
    db.delete(_uid);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const SelectRoute()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _PulsingRickshaw(),
              const SizedBox(height: AppSpacing.xl),
              const Text('Finding you a rickshaw',
                  style: AppText.display, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Your request is visible to every driver on campus. '
                'You will see their details as soon as one accepts.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(label: 'Cancel ride', onPressed: _cancel),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gently pulsing badge so the wait does not feel frozen.
class _PulsingRickshaw extends StatefulWidget {
  const _PulsingRickshaw();

  @override
  State<_PulsingRickshaw> createState() => _PulsingRickshawState();
}

class _PulsingRickshawState extends State<_PulsingRickshaw>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.94, end: 1.06)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        height: 170,
        width: 170,
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.electric_rickshaw,
            size: 78, color: AppColors.primary),
      ),
    );
  }
}
