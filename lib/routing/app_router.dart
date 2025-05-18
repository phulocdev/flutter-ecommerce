import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/screens/admin_home_screen.dart';
import 'package:flutter_ecommerce/screens/cart_screen.dart';
import 'package:flutter_ecommerce/screens/change_password_screen.dart';
import 'package:flutter_ecommerce/screens/checkout_screen.dart';
import 'package:flutter_ecommerce/screens/dashboard.dart';
import 'package:flutter_ecommerce/screens/edit_profile_screen.dart';
import 'package:flutter_ecommerce/screens/forgot_password_screen.dart';
import 'package:flutter_ecommerce/screens/home_screen.dart';
import 'package:flutter_ecommerce/screens/login_screen.dart';
import 'package:flutter_ecommerce/screens/manage_address_screen.dart';
import 'package:flutter_ecommerce/screens/order_detail_screen.dart';
import 'package:flutter_ecommerce/screens/order_history_screen.dart';
import 'package:flutter_ecommerce/screens/otp_screen.dart';
import 'package:flutter_ecommerce/screens/payment_success.dart';
import 'package:flutter_ecommerce/screens/product_catalog_screen.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen_admin.dart';
import 'package:flutter_ecommerce/screens/product_management_screen.dart';
import 'package:flutter_ecommerce/screens/profile_screen.dart';
import 'package:flutter_ecommerce/screens/registration_screen.dart';
import 'package:flutter_ecommerce/screens/user_managenent_screen.dart';
import 'package:flutter_ecommerce/widgets/scaffold_with_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Create a custom refresh listenable to handle auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic>? stream) {
    _subscription = stream?.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorCartKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellCart');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

// This provider is no longer needed since we'll access the stream directly
// final authStateChangesProvider = StreamProvider<dynamic>((ref) {
//   return ref.watch(authProvider.notifier).authStateChanges();
// });

final goRouterProvider = Provider<GoRouter>((ref) {
  // Enable the use of the URL's path in the web platform
  // setUrlStrategy(PathUrlStrategy());

  return GoRouter(
    // Remove initialLocation to allow the app to start from the current URL
    initialLocation: AppRoute.home.path,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(
        ref.read(authProvider.notifier).authStateChanges()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
              GoRoute(
                path: AppRoute.productCatalog.path,
                name: AppRoute.productCatalog.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProductCatalogScreen(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoute.productDetail.path,
                    name: AppRoute.productDetail.name,
                    builder: (context, state) {
                      final productId = state.pathParameters['id']!;
                      return ProductDetailScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCartKey,
            routes: [
              GoRoute(
                path: AppRoute.cart.path,
                name: AppRoute.cart.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CartScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoute.checkout.path,
        name: AppRoute.checkout.name,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.changePassword.path,
        name: AppRoute.changePassword.name,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.editProfileScreen.path,
        name: AppRoute.editProfileScreen.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoute.historyOrders.path,
        name: AppRoute.historyOrders.name,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: AppRoute.orderDetail.path,
        name: AppRoute.orderDetail.name,
        builder: (context, state) {
          final Order? order =
              state.extra != null ? state.extra as Order : null;

          if (order == null) {
            return const ProductCatalogScreen();
          }

          return OrderDetailScreen(order: order);
        },
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        builder: (context, state) {
          final String? email =
              state.extra != null ? state.extra as String : null;

          if (email == null) {
            return ForgotPasswordScreen();
          }

          return OTPScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoute.manageAddress.path,
        name: AppRoute.manageAddress.name,
        builder: (context, state) => const ManageAddressScreen(),
      ),
      GoRoute(
        path: AppRoute.adminHome.path,
        name: AppRoute.adminHome.name,
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: AppRoute.dashboard.path,
        name: AppRoute.dashboard.name,
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: AppRoute.productManagement.path,
        name: AppRoute.productManagement.name,
        builder: (context, state) => const ProductManagementScreen(),
        routes: [
          GoRoute(
            path: AppRoute.productDetailAdmin.path,
            name: AppRoute.productDetailAdmin.name,
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetailAdminScreen(productId: productId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.userManagement.path,
        name: AppRoute.userManagement.name,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: (AppRoute.paymentSuccess.path),
        name: AppRoute.paymentSuccess.name,
        builder: (context, state) {
          final String? orderCode =
              state.extra != null ? state.extra as String : null;

          if (orderCode == null) {
            return ProductCatalogScreen();
          }

          return PaymentSuccessScreen(
            orderCode: orderCode,
          );
        },
      )
    ],
    redirect: (context, state) {
      // Get the current auth state directly in the redirect function
      final user = ref.read(authProvider);
      final isLoggedIn = user != null;
      final isAdmin = user?.role == 'Admin';

      final loggingIn = state.matchedLocation == AppRoute.login.path ||
          state.matchedLocation == AppRoute.register.path ||
          state.matchedLocation == AppRoute.forgotPassword.path;

      final privatePaths = [];

      final adminPaths = [
        AppRoute.productManagement.path,
        AppRoute.userManagement.path,
        AppRoute.adminHome.path,
        AppRoute.dashboard.path,
      ];

      final isAdminPath =
          adminPaths.any((path) => state.matchedLocation.contains(path));

      final isPrivatePath =
          privatePaths.any((path) => state.matchedLocation.contains(path));

      if ((!isAdmin && isAdminPath) || (!isLoggedIn && isPrivatePath)) {
        return AppRoute.login.path;
      }

      if (isLoggedIn && loggingIn) {
        return AppRoute.home.path;
      }

      return null;
      return AppRoute.userManagement.path;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error?.message}'),
      ),
    ),
  );
});

enum AppRoute {
  login('/login'),
  register('/register'),
  forgotPassword('/forgot-password'),
  otp('/otp'),
  home('/'),
  productCatalog('/products'),
  productDetail(':id'),
  checkout('/checkout'),
  cart('/cart'),
  profile('/profile'),
  changePassword('/change-password'),
  editProfileScreen('/me'),
  manageAddress('/manage-address'),
  adminHome('/admin-home'),
  dashboard('/dashboard'),
  userManagement('/user-management'),
  productManagement('/product-management'),
  productDetailAdmin(':id'),
  orderManagement('/order-management'),
  couponManagement('/coupon-management'),
  paymentSuccess('/payment-success'),
  historyOrders('/history-orders'),
  orderDetail('/order-detail'),
  ;

  const AppRoute(this.path);
  final String path;
}
