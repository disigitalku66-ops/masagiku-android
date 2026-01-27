import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: chatListAsync.when(
        data: (chatRooms) {
          if (chatRooms.isEmpty) {
            return const Center(child: Text('Belum ada percakapan'));
          }
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(room.shopLogo),
                  onBackgroundImageError: (_, _) {},
                  child: const Icon(Icons.store),
                ),
                title: Text(room.shopName),
                subtitle: Text(
                  room.lastMessage?.content ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: room.unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: room.unreadCount > 0 ? Colors.black87 : Colors.grey,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(room.updatedAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (room.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          room.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  context.push(AppRoutes.chatRoomPath(room.id));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return DateFormat.Hm().format(time); // 14:30
    } else {
      return DateFormat.d().format(time); // 24
    }
  }
}
