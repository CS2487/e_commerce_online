import 'package:shopping/core/imports/imports.dart';

import '../auth/login.dart';
import '../auth/signup.dart';

class IntroductionApp extends StatefulWidget {
  const IntroductionApp({super.key});
  @override
  IntroductionAppState createState() => IntroductionAppState();
}

class IntroductionAppState extends State<IntroductionApp> with SingleTickerProviderStateMixin {
  bool _showWalkthrough = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 2);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return _showWalkthrough ? _buildWalkthrough() : _buildJoinApp();
  }

  Widget _buildWalkthrough() {
    List<PageViewModel> pages = [
      for (int i = 0; i < AppConstants.pageInfos(context).length; i++)
        _buildPageModel(AppConstants.pageInfos(context)[i])
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: IntroductionScreen(
          pages: pages,
          onDone: _navigateToJoinApp,
          onSkip: _navigateToJoinApp,
          showSkipButton: true,
          skip: Text(AppConstants.skipText(context)),
          next: Text(
            AppConstants.nextText(context),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          done: Text(
            AppConstants.doneText(context),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  _buildPageModel(Map<String, String> item) {
    return PageViewModel(
      title: item['title']!,
      body: item['body']!,
      image: Image.asset(
        item['img']!,
        height: 185.0,
      ),
    );
  }

  void _navigateToJoinApp() {
    setState(() {
      _showWalkthrough = false;
    });
  }

  Widget _buildJoinApp() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/IntroductionApp');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
          tabs: <Widget>[
            Tab(
              text: l10n.loginButton,
            ),
            Tab(
              text: l10n.signUpButton,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          LoginPage(),
          SignUpPage(),
        ],
      ),
    );
  }
}
