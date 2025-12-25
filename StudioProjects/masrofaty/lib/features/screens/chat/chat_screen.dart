

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/Database/ai_service.dart';
import '../../models/chat_message.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final AiService _ai;

  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ai = AiService(apiKey: 'AIzaSyBtUFoRCzN4Cc-XjQZTMrl_a7BZrzOzFQY');
  }

  /// --- إرسال الرسالة ---
  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    // التحقق من اتصال الإنترنت
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تحقق من اتصالك بالإنترنت 🌐"),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text, true)); // رسالة المستخدم
      _loading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _ai.reply(text); // الرد من البوت
      setState(() {
        _messages.add(ChatMessage(reply, false));
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء إرسال الرسالة."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// --- تمرير القائمة لأسفل تلقائي ---
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('بوت الدردشة')),
      body: Column(
        children: [
          // قائمة الرسائل أو واجهة فارغة
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _bubble(_messages[i], theme),
                  ),
          ),

          // مؤشر تحميل أثناء انتظار الرد
          if (_loading) const LinearProgressIndicator(minHeight: 2),

          // حقل إدخال النص وزر الإرسال
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 60, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            "أهلاً 👋\nأنا مساعدك الذكي لمصروفاتك.",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "تقدر تسألني عن مصروفاتك بأي عملة، أو حتى تدردش معي خارج موضوع المصاريف 😊",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// --- فقاعة الرسائل ---
  Widget _bubble(ChatMessage m, ThemeData theme) {
    final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = m.fromUser ? Colors.blue[100] : Colors.grey[200];
    const textColor = Colors.black;

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: m.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم نسخ الرسالة"),
              duration: Duration(milliseconds: 300),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            m.text,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
