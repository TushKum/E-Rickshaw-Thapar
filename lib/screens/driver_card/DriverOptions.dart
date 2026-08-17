// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';

import 'package:erickshaw/screens/landingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widget.dart';
import '../passinfo.dart';

class DriverOptions extends StatefulWidget {
  const DriverOptions({Key? key}) : super(key: key);

  @override
  State<DriverOptions> createState() => _DriverOptionsState();
}

class _DriverOptionsState extends State<DriverOptions> {
  final auth = FirebaseAuth.instance;
  late Databases db;
  List docs = [];
  bool _loadedOnce = false;

  late Timer timer;
  late String _uid;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
    _uid = auth.currentUser?.uid.toString() ?? "";
    // NOTE: polls the whole requests collection once per second. Firestore
    // bills one read per document returned, so this is the single biggest
    // quota risk at pilot scale — see docs/RUNNING.md. Should move to a
    // snapshots() listener.
    timer = Timer.periodic(const Duration(seconds: 1), (_) => Reload());
    Reload();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> Reload() async {
    final value = await db.read();
    if (!mounted) return;
    setState(() {
      docs = value ?? [];
      _loadedOnce = true;
    });
  }

  void _accept(Map request) {
    db.create_request(
        request['from'], request['to'], request['id'], '1', _uid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Userdetails(
          uid: request['id'],
          pfrom: request['from'],
          to: request['to'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Requests already claimed by a driver should not sit in the open list.
    final open = docs.where((d) => d['pending'] == '0').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Available rides'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () {
              auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Landing()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: !_loadedOnce
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : open.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screen,
                        AppSpacing.sm, AppSpacing.screen, AppSpacing.xl),
                    itemCount: open.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _RequestCard(
                      request: open[i],
                      onAccept: () => _accept(open[i]),
                    ),
                  ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onAccept});

  final Map request;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AccentIcon(Icons.person_outline, size: 38),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['from'] ?? '',
                        style: AppText.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(request['to'] ?? '',
                              style: AppText.bodyMuted
                                  .copyWith(color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
              ),
              child: const Text('Accept ride'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 68, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No open requests',
                style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'New ride requests from students will appear here as soon as '
              'they are made.',
              style: AppText.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
