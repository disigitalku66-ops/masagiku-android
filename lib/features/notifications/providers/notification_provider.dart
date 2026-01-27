import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';

class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data
    final mockNotifications = [
      NotificationModel(
        id: '1',
        title: 'Pesanan Berhasil',
        body: 'Pesanan #ORD-2024-001 Anda telah berhasil dibuat.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.order,
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Flash Sale Dimulai! ⚡',
        body:
            'Dapatkan diskon hingga 50% untuk produk elektronik hanya hari ini.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.promo,
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Selamat Datang di Masagiku',
        body:
            'Terima kasih telah bergabung. Lengkapi profil Anda untuk pengalaman belanja yang lebih baik.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Pembayaran Dikonfirmasi',
        body:
            'Pembayaran untuk pesanan #ORD-2024-001 telah diterima. Penjual sedang memproses pesanan Anda.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        type: NotificationType.order,
        isRead: true,
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      notifications: mockNotifications,
      unreadCount: mockNotifications.where((n) => !n.isRead).length,
    );
  }

  Future<void> markAsRead(String id) async {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: updatedNotifications.where((n) => !n.isRead).length,
    );
  }

  Future<void> markAllAsRead() async {
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updatedNotifications, unreadCount: 0);
  }

  void addNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadCount: state.unreadCount + (notification.isRead ? 0 : 1),
    );
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier();
    });
