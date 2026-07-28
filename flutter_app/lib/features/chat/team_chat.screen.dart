import 'package:flutter/material.dart';

class TeamChatScreen extends StatefulWidget {
  const TeamChatScreen({Key? key}) : super(key: key);

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'أحمد علي',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'message': 'السلام عليكم، هناك جولة تفقدية للسلامة بعد 30 دقيقة في مبنى الإنتاج - الخط الأول.',
      'time': '10:30 ص',
      'isMe': false,
    },
    {
      'sender': 'سامي الجهني',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'message': 'تم الاستعداد ومراجعة كشوفات الفحص الدورية.',
      'time': '10:31 ص',
      'isMe': false,
    },
    {
      'sender': 'فهد العتيبي [مشرف السلامة]',
      'avatar': 'https://i.pravatar.cc/150?img=15',
      'message': 'لا تنسوا التأكد من معدات الإطفاء ومخارج الطوارئ ومراجعة الـ LOTO.',
      'time': '10:32 ص',
      'isMe': false,
    },
    {
      'sender': 'أنت',
      'avatar': 'https://i.pravatar.cc/150?img=68',
      'message': 'ممتاز جداً، سنبدأ الجولة في موعدها وسأكون عند نقطة التجمع الس الساخنة في تمام 10:45 ص.',
      'time': '10:33 ص',
      'isMe': true,
    },
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'أنت',
          'avatar': 'https://i.pravatar.cc/150?img=68',
          'message': text,
          'time': 'الآن',
          'isMe': true,
        });
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1E5E3A).withOpacity(0.1),
              radius: 20,
              child: const Icon(Icons.groups, color: Color(0xFF1E5E3A)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('فريق السلامة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                Text('12 عضو - 3 متصل الآن', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone, color: Color(0xFF1E5E3A)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam, color: Color(0xFF1E5E3A)), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade700), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m['isMe'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(radius: 18, backgroundImage: NetworkImage(m['avatar'])),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFE8F5E9) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(16),
                              topLeft: const Radius.circular(16),
                              bottomRight: Radius.circular(isMe ? 16 : 0),
                              bottomLeft: Radius.circular(isMe ? 0 : 16),
                            ),
                            border: Border.all(color: isMe ? const Color(0xFFC8E6C9) : Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(m['sender'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                                ),
                              Text(m['message'], style: const TextStyle(fontSize: 14, color: Color(0xFF1B2533), height: 1.4)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(m['time'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.done_all, size: 14, color: Color(0xFF1E5E3A)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 10),
                        CircleAvatar(radius: 18, backgroundImage: NetworkImage(m['avatar'])),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom WhatsApp style chatbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.mic_none_rounded, color: Colors.grey.shade700), onPressed: () {}),
                  IconButton(icon: Icon(Icons.attach_file, color: Colors.grey.shade700), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة لفريق السلامة...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        suffixIcon: IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1E5E3A)), onPressed: () {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 46, height: 46,
                      decoration: const BoxDecoration(color: Color(0xFF1E5E3A), shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
