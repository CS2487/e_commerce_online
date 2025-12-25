import 'package:flutter/material.dart';
import '../../shared/bottom_nav_bar.dart';
import '../../shared/app_theme.dart';
import '../core/Database/prefs_service.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final PageController _controller = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  final List<Map<String, dynamic>> pages = const [
    {
      'title': 'سجّل مصروفاتك اليومية 📝',
      'desc': 'كم تمضغ قات؟ كم تدخن؟ كم تاكل؟ كل شيء مسجّل بضغطة زر!',
      'icon': Icons.edit_note,
    },
    {
      'title': 'شوف تقاريرك 😵📊',
      'desc': 'رسوم بيانية ممتعة تكشف كل فلوسك وين راحت 🔥💸',
      'icon': Icons.bar_chart,
    },
    {
      'title': 'حدد ميزانيتك الشهرية 💰',
      'desc': 'خليك ملتزم ولا تتهور، 👀😎',
      'icon': Icons.savings,
    },
    {
      'title': 'شارك مع أصحابك 🤝',
      'desc': 'ضحكك مع الصحاب أهم من الفلوس!😂🎉',
      'icon': Icons.emoji_people,
    },
  ];

  Future<void> _finish(BuildContext context) async {
    final prefs = await PrefsService.getInstance();
    await prefs.setSeenOnboarding(true);

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => _currentIndex.value = i,
                itemBuilder: (context, i) {
                  final page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.scale(
                                scale: value,
                                child: Icon(
                                  page['icon'],
                                  size: screenWidth * 0.3,
                                  color: theme.colorScheme.primary,
                                )),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style:
                              textTheme.headlineMedium?.copyWith(height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['desc'],
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: _currentIndex,
                    builder: (_, index, __) => Row(
                      children: List.generate(
                        pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: i == index ? 12 : 8,
                          height: i == index ? 12 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == index
                                ? theme.colorScheme.primary
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<int>(
                    valueListenable: _currentIndex,
                    builder: (_, index, __) => Ink(
                      decoration: BoxDecoration(
                        gradient: index == pages.length - 1
                            ? const LinearGradient(
                                colors: [
                                  AppTheme.seedColor,
                                  AppTheme.seedColor
                                ],
                              )
                            : null,
                        color: index != pages.length - 1
                            ? AppTheme.seedColor
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (index == pages.length - 1) {
                            _finish(context);
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          index == pages.length - 1 ? 'يلا خلّصنا' : 'التالي',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
