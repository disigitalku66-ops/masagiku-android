/// App Routes configuration with go_router
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/main_screen.dart';
import '../features/home/presentation/search_screen.dart';
import '../features/home/presentation/categories_screen.dart';
import '../features/products/presentation/product_detail_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/cart/presentation/checkout_screen.dart';
import '../features/cart/presentation/address_selection_screen.dart';
import '../features/cart/presentation/add_address_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/orders/presentation/screens/refund_request_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/wallet_screen.dart';
import '../features/profile/presentation/screens/loyalty_screen.dart';
import '../features/support/presentation/screens/support_screen.dart';
import '../features/support/presentation/screens/create_ticket_screen.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/compare/presentation/screens/compare_screen.dart';
import '../features/shop/presentation/screens/shop_screen.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/screens/chat_room_screen.dart';
import '../features/cart/presentation/screens/coupon_list_screen.dart';

/// Route paths
abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding =
      '/selamat-datang'; // onboarding -> selamat-datang

  // Auth
  static const String login = '/masuk'; // login -> masuk
  static const String register = '/daftar'; // register -> daftar
  static const String forgotPassword =
      '/lupa-sandi'; // forgot-password -> lupa-sandi
  static const String otp = '/kode-verifikasi'; // otp -> kode-verifikasi
  static const String resetPassword =
      '/atur-ulang-sandi'; // reset-password -> atur-ulang-sandi

  // Main
  static const String main = '/utama'; // main -> utama
  static const String home = '/beranda'; // home -> beranda
  static const String categories = '/kategori'; // categories -> kategori
  static const String cart = '/keranjang'; // cart -> keranjang
  static const String wishlist = '/favorit'; // wishlist -> favorit
  static const String compare = '/bandingkan'; // compare -> bandingkan
  static const String profile = '/profil'; // profile -> profil

  // Products
  static const String productDetail = '/produk/:slug'; // product -> produk
  static const String productSearch = '/pencarian'; // search -> pencarian
  static const String categoryProducts =
      '/kategori/:id'; // category -> kategori

  // Checkout
  static const String checkout = '/pemesanan'; // checkout -> pemesanan
  static const String payment = '/pembayaran'; // payment -> pembayaran
  static const String orderSuccess =
      '/pesanan-berhasil'; // order-success -> pesanan-berhasil

  // Orders
  static const String orders = '/pesanan'; // orders -> pesanan
  static const String orderDetail = '/pesanan/:id'; // order -> pesanan
  static const String orderTracking = '/pesanan/:id/lacak'; // tracking -> lacak
  static const String refundRequest =
      '/pesanan/:id/pengembalian'; // refund -> pengembalian

  // Profile
  static const String editProfile = '/profil/ubah'; // edit -> ubah
  static const String addresses = '/alamat'; // addresses -> alamat
  static const String addAddress = '/alamat/tambah'; // add -> tambah
  static const String editAddress = '/alamat/:id'; // addresses/:id
  static const String wallet = '/dompet'; // wallet -> dompet
  static const String loyalty = '/poin'; // loyalty -> poin
  static const String support = '/bantuan'; // support -> bantuan
  static const String settings = '/pengaturan'; // settings -> pengaturan
  static const String notifications =
      '/notifikasi'; // notifications -> notifikasi

  // Shop
  static const String shop = '/toko/:id'; // shop -> toko

  // Chat
  static const String chatList = '/chat'; // chat list
  static const String chatRoom = '/chat/:roomId'; // chat room

  // Helpers
  static String productDetailPath(String slug) => '/produk/$slug';
  static String categoryProductsPath(String id) => '/kategori/$id';
  static String orderDetailPath(String id) => '/pesanan/$id';
  static String orderTrackingPath(String id) => '/pesanan/$id/lacak';
  static String editAddressPath(String id) => '/alamat/$id';
  static String otpPath(String phone) => '/kode-verifikasi?phone=$phone';
  static String shopPath(int id) => '/toko/$id';
  static String chatRoomPath(String roomId) => '/chat/$roomId';
}

/// Router configuration
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.main,
    debugLogDiagnostics: true,
    routes: [
      // Splash/Loading
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashPlaceholder(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phone: phone);
        },
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.main,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.categories,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CategoriesScreen()),
          ),
          GoRoute(
            path: AppRoutes.cart,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartScreen()),
          ),
          GoRoute(
            path: AppRoutes.wishlist,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WishlistScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Standalone Routes (Full Screen)
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) =>
            const AddressSelectionScreen(isSelectionMode: false),
        routes: [
          GoRoute(
            path: 'tambah',
            builder: (context, state) => const AddAddressScreen(),
          ),
          GoRoute(
            path: 'ubah/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return AddAddressScreen(addressId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.loyalty,
        builder: (context, state) => const LoyaltyScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
        routes: [
          GoRoute(
            path: 'buat',
            builder: (context, state) => const CreateTicketScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),

      // Product Routes
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return ProductDetailScreen(slug: slug);
        },
      ),
      GoRoute(
        path: AppRoutes.productSearch,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _CategoryProductsPlaceholder(id: id);
        },
      ),
      // Shop Route
      GoRoute(
        path: AppRoutes.shop,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ShopScreen(shopId: id);
        },
      ),

      // Chat Routes
      GoRoute(
        path: AppRoutes.chatList,
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':roomId', // Relative path from /chat
            builder: (context, state) {
              final roomId = state.pathParameters['roomId'] ?? '';
              return ChatRoomScreen(roomId: roomId);
            },
          ),
        ],
      ),

      // Compare Route
      GoRoute(
        path: AppRoutes.compare,
        builder: (context, state) => const CompareScreen(),
      ),

      // Order Routes
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.refundRequest,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return RefundRequestScreen(orderId: id);
        },
      ),

      // Checkout Routes
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'alamat', // 'address' -> 'alamat'
            builder: (context, state) =>
                const AddressSelectionScreen(isSelectionMode: true),
            routes: [
              GoRoute(
                path: 'tambah', // 'add' -> 'tambah'
                builder: (context, state) => const AddAddressScreen(),
              ),
              GoRoute(
                path: 'ubah/:id', // 'edit/:id' -> 'ubah/:id'
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return AddAddressScreen(addressId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'kupon',
            builder: (context, state) => const CouponListScreen(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.main),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Placeholder widgets (will be replaced with actual screens)
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

// _CartPlaceholder removed - now using CartScreen

class _CategoryProductsPlaceholder extends StatelessWidget {
  final String id;
  const _CategoryProductsPlaceholder({required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Kategori $id')),
    body: const Center(child: Text('Produk dalam kategori ini')),
  );
}
