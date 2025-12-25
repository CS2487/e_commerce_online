import 'package:flutter/material.dart';
import 'package:shopping/core/theme/app_theme.dart';

class ImageSlider extends StatefulWidget {
  final Function(int) onChange;
  final int currentSlide;

  const ImageSlider({
    super.key,
    required this.currentSlide,
    required this.onChange,
  });

  @override
  ImageSliderState createState() => ImageSliderState();
}

class ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderHeight = constraints.maxWidth < 600 ? 220.0 : 400.0;
        final indicatorSize = constraints.maxWidth < 600 ? 8.0 : 13.0;
        bool isWeb = constraints.maxWidth >= 600;
        return Stack(
          children: [
            SizedBox(
              height: sliderHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: widget.onChange,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Image.asset("assets/images/slider2.png", fit: BoxFit.cover),
                    Image.asset("assets/images/slider3.png", fit: BoxFit.cover),
                    Image.asset("assets/images/slider.png", fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              bottom: 10,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => GestureDetector(
                      onTap: isWeb ? () => _goToPage(index) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: widget.currentSlide == index
                            ? indicatorSize * 1.5
                            : indicatorSize,
                        height: indicatorSize,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: widget.currentSlide == index
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          border: Border.all(color: AppTheme.secondaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
