import 'package:erickshaw/screens/landingpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';

class _Page {
  const _Page(this.icon, this.title, this.highlight, this.body);
  final IconData icon;
  final String title;
  final String highlight;
  final String body;
}

const List<_Page> _pages = [
  _Page(
    Icons.pin_drop_outlined,
    'Pick your stop,',
    'skip the wait',
    'Choose where you are and where you are headed from the campus stops you '
        'already know — Main Gate, Chatter, Central Library and the rest.',
  ),
  _Page(
    Icons.notifications_active_outlined,
    'Drivers see your',
    'request instantly',
    'Your ride request goes straight to every e-rickshaw driver on campus. '
        'The first one to accept is matched with you.',
  ),
  _Page(
    Icons.verified_user_outlined,
    'Know exactly who',
    'is picking you up',
    'Once a driver accepts you get their name, number and number-plate '
        'before they arrive. No guessing at the gate.',
  ),
];

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  /// Persisted flag so onboarding only ever shows on first launch.
  static const String seenKey = 'seen_onboarding_v1';

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Onboarding.seenKey, true);
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const Landing()));
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardPage(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                  AppSpacing.screen, AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: i == _index ? 26 : 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isLast ? 'Get started' : 'Next',
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 86, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(page.title, style: AppText.display, textAlign: TextAlign.center),
          Text(
            page.highlight,
            style: AppText.display.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(page.body,
              style: AppText.bodyMuted, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
