// lib/screens/main/chats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('الرجاء تسجيل الدخول لعرض المحادثات')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: Provider.of<ChatProvider>(context).getUserChats(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد محادثات بعد', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere((id) => id != currentUser.id, orElse: () => '');
              final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم غير معروف';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    chat.lastMessageContent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTime(chat.lastMessageTime),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: chat.id,
                          otherUserId: otherUserId,
                          otherUserName: otherUserName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) return '${difference.inDays} يوم';
    if (difference.inHours > 0) return '${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return '${difference.inMinutes} دقيقة';
    return 'الآن';
  }
}
