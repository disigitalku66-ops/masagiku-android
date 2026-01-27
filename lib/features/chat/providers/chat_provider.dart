import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_model.dart';

final chatListProvider = FutureProvider.autoDispose<List<ChatRoom>>((
  ref,
) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Mock data
  return [
    ChatRoom(
      id: '1',
      shopId: '101',
      shopName: 'Toko Elektronik Jaya',
      shopLogo: 'https://via.placeholder.com/150',
      unreadCount: 2,
      lastMessage: ChatMessage(
        id: 'm1',
        senderId: '101',
        content: 'Barang ready gan, silakan diorder.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatRoom(
      id: '2',
      shopId: '102',
      shopName: 'Fashion Kekinian',
      shopLogo: 'https://via.placeholder.com/150',
      unreadCount: 0,
      lastMessage: ChatMessage(
        id: 'm2',
        senderId: 'user',
        content: 'Apakah ada warna lain?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
});

final chatMessagesProvider = FutureProvider.family
    .autoDispose<List<ChatMessage>, String>((ref, roomId) async {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock messages
      return [
        ChatMessage(
          id: '1',
          senderId: '101', // Shop
          content: 'Halo, ada yang bisa dibantu?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        ChatMessage(
          id: '2',
          senderId: 'user', // User
          content: 'Apakah stok untuk iPhone 15 ready?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        ChatMessage(
          id: '3',
          senderId: '101',
          content: 'Barang ready gan, silakan diorder.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ].reversed.toList();
    });
