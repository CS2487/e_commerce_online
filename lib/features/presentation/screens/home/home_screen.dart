
import 'package:shopping/core/imports/imports.dart';

import '../../widgets/category_filter.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/image_slider.dart';
import '../product/product_view_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlider = 0;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar:  const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageSlider(
                currentSlide: currentSlider,
                onChange: (value) {
                  setState(() {
                    currentSlider = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              CategoryFilter(
                onCategorySelected: (category) {
                  productProvider.fetchProducts(category);
                },
              ),
              const SizedBox(height: 20),
              // ProductView
              const ProductView(),
            ],
          ),
        ),
      ),
    );
  }
}
