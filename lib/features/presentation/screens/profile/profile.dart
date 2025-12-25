import 'package:shopping/core/imports/imports.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;
  bool _showWalkthrough = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _tabController = TabController(vsync: this, initialIndex: 1, length: 2);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _buildJoinApp(),
    );
  }

  Widget _buildJoinApp() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(),
        const Divider(),
        _buildListTile(
          context,
          icon: Icons.share,
          title: AppLocalizations.of(context)!.share,
          onTap: () => _handleShare(context, AppLocalizations.of(context)!),
        ),
        _buildListTile(
          context,
          icon: Icons.favorite_border,
          title: AppLocalizations.of(context)!.don_favorites,
          onTap: () {
            Navigator.pushReplacementNamed(context, '/FavoritesPage');
          },
        ),
        _buildListTile(
          context,
          icon: Icons.info_outline,
          title: AppLocalizations.of(context)!.about,
          onTap: () => _showDialog(
            context,
            title: AppLocalizations.of(context)!.about,
            message: AppLocalizations.of(context)!.aboutmsg,
            icon: Icons.info_outline,
          ),
        ),
        _buildListTile(
          context,
          icon: Icons.help_outline,
          title: AppLocalizations.of(context)!.help,
          onTap: () => _showDialog(
            context,
            title: AppLocalizations.of(context)!.help,
            message: AppLocalizations.of(context)!.contactwithus,
            icon: Icons.help_center_outlined,
          ),
        ),
        _buildCustomDivider(),
        const LanguageSwitcher(),

        // زر تسجيل الخروج
        _buildListTile(
          context,
          icon: Icons.logout,
          title: AppLocalizations.of(context)!.logout,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final l10n = AppLocalizations.of(context)!;
                return CustomLogoutDialog(
                  context,
                  onLogout: () async {
                    try {
                      if (user != null) {
                        await _auth.signOut();
                        await GoogleSignIn().signOut();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.logoutSuccess)),
                        );

                        setState(() {
                          _showWalkthrough = false;
                        });

                        // الانتقال إلى شاشة تسجيل الدخول
                        Navigator.pushReplacementNamed(context, '/LoginPage');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("لا يوجد مستخدم مسجل حاليًا")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("فشل تسجيل الخروج: $e")),
                      );
                    }
                  },
                  onCancel: () {
                    Navigator.pop(
                        context); // إغلاق نافذة تسجيل الخروج عند الإلغاء
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://via.placeholder.com/150'),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'اسم المستخدم',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'البريد الإلكتروني',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCustomDivider() {
    return const Divider();
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _handleShare(BuildContext context, AppLocalizations l10n) {
    Share.share(
      l10n.shareme,
      subject: l10n.shareme,
    );
  }

  void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          message: message,
          title: title,
          icon: icon,
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }
}
