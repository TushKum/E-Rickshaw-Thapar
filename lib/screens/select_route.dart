// ignore_for_file: use_build_context_synchronously

import 'package:erickshaw/screens/landingpage.dart';
import 'package:erickshaw/screens/pass_waiting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../theme/app_theme.dart';
import '../widgets/widget.dart';

/// Pickup / drop points on the Thapar (TIET) Patiala campus.
/// Single source for both the FROM and TO dropdowns — edit here only.
const List<String> campusStops = <String>[
  "Main Gate",
  "Fountain Chowk",
  "Academic Blocks (A/B/C)",
  "E Block",
  "G Block",
  "Lecture Theatre (LT)",
  "Central Library",
  "LM Thapar School of Management",
  "Chatter",
  "Student Centre",
  "Sports Complex",
  "Boys Hostels (A-G)",
  "Girls Hostels (H-Q)",
  "Cosmo Hostel",
  "Medical Centre",
  "Guest House",
  "Faculty Housing",
];

class SelectRoute extends StatefulWidget {
  const SelectRoute({Key? key}) : super(key: key);

  @override
  State<SelectRoute> createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute> {
  late Databases db;
  final auth = FirebaseAuth.instance;
  late String _uid;

  String? fromValue;
  String? toValue;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
    _uid = auth.currentUser?.uid.toString() ?? "";
    _resumeExistingRequest();
  }

  /// If this passenger already has an open request, jump straight back to the
  /// waiting screen rather than letting them file a second one.
  ///
  /// The original navigated unconditionally once check_request resolved. With
  /// no open request that assigned null to a `late Map`, which threw inside
  /// the .then() and was swallowed as an unhandled future error — the redirect
  /// was being suppressed by an exception rather than by a check.
  Future<void> _resumeExistingRequest() async {
    final existing = await db.check_request(_uid);
    if (!mounted || existing == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PassWait()));
  }

  void _swap() {
    setState(() {
      final t = fromValue;
      fromValue = toValue;
      toValue = t;
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ));
  }

  void _search() {
    if (fromValue == null && toValue == null) {
      _toast('Choose where you are and where you are going');
      return;
    }
    if (fromValue == null) {
      _toast('Pickup point missing');
      return;
    }
    if (toValue == null) {
      _toast('Destination missing');
      return;
    }
    if (fromValue == toValue) {
      _toast('Pickup and destination must be different');
      return;
    }

    db.create_request(fromValue!, toValue!, _uid, '0', "");
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const PassWait()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Where to?'),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm,
              AppSpacing.screen, AppSpacing.xl),
          children: [
            const Text('Book a rickshaw',
                style: AppText.display),
            const SizedBox(height: AppSpacing.sm),
            const Text('Pick your stops and we will find a driver on campus.',
                style: AppText.bodyMuted),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _StopPicker(
                          label: 'FROM',
                          icon: Icons.my_location,
                          value: fromValue,
                          hint: 'Pickup point',
                          onChanged: (v) => setState(() => fromValue = v),
                        ),
                        const Divider(height: AppSpacing.md),
                        _StopPicker(
                          label: 'TO',
                          icon: Icons.place_outlined,
                          value: toValue,
                          hint: 'Destination',
                          onChanged: (v) => setState(() => toValue = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    tooltip: 'Swap',
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_vert,
                        color: AppColors.primary, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
                label: 'Find a rickshaw',
                icon: Icons.search,
                onPressed: _search),
            const SizedBox(height: AppSpacing.xl),
            const Text('POPULAR STOPS', style: AppText.sectionLabel),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final stop in const [
                  'Main Gate',
                  'Central Library',
                  'Chatter',
                  'Sports Complex',
                ])
                  _StopChip(
                    label: stop,
                    onTap: () => setState(() {
                      if (fromValue == null) {
                        fromValue = stop;
                      } else if (toValue == null && stop != fromValue) {
                        toValue = stop;
                      }
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StopPicker extends StatelessWidget {
  const _StopPicker({
    required this.label,
    required this.icon,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.sectionLabel),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  hint: Text(hint,
                      style: AppText.body
                          .copyWith(color: AppColors.textSecondary)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                  style: AppText.body,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  items: campusStops
                      .map((s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StopChip extends StatelessWidget {
  const _StopChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: AppText.body.copyWith(fontSize: 13)),
      ),
    );
  }
}
