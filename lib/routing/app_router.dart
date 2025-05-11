import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/screens/admin_home_screen.dart';
import 'package:flutter_ecommerce/screens/cart_screen.dart';
import 'package:flutter_ecommerce/screens/change_password_screen.dart';
import 'package:flutter_ecommerce/screens/checkout_screen.dart';
import 'package:flutter_ecommerce/screens/edit_profile_screen.dart';
import 'package:flutter_ecommerce/screens/forgot_password_screen.dart';
import 'package:flutter_ecommerce/screens/login_screen.dart';
import 'package:flutter_ecommerce/screens/manage_address_screen.dart';
import 'package:flutter_ecommerce/screens/otp_screen.dart';
import 'package:flutter_ecommerce/screens/payment_success.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart';
import 'package:flutter_ecommerce/screens/dashboard.dart';
import 'package:flutter_ecommerce/screens/products_screen.dart';
import 'package:flutter_ecommerce/screens/profile_screen.dart';
import 'package:flutter_ecommerce/screens/registration_screen.dart';
import 'package:flutter_ecommerce/screens/user_managenent_screen.dart';
import 'package:flutter_ecommerce/widgets/scaffold_with_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorCartKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellCart');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);
  final isLoggedIn = user != null;

  return GoRouter(
    initialLocation: AppRoute.products.path,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
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
                path: AppRoute.products.path,
                name: AppRoute.products.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProductScreen(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoute.productDetail.path, // 'detail/:id'
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
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        builder: (context, state) => const OTPScreen(),
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
        path: AppRoute.userManagement.path,
        name: AppRoute.userManagement.name,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
          path: (AppRoute.paymentSuccess.path),
          name: AppRoute.paymentSuccess.name,
          builder: (context, state) => const PaymentSuccessScreen())
    ],
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == AppRoute.login.path ||
          state.matchedLocation == AppRoute.register.path ||
          state.matchedLocation == AppRoute.forgotPassword.path;

      final publicPaths = [
        AppRoute.products.path,
        AppRoute.productDetail.path,
        AppRoute.profile.path,
        AppRoute.cart.path,
        AppRoute.checkout.path,
        // Test UI - Remove them when complete
        AppRoute.dashboard.path,
        AppRoute.adminHome.path,
        AppRoute.paymentSuccess.path
      ];

      final isPublicPath = publicPaths.any(
        (path) => state.matchedLocation.startsWith(path),
      );

      if (!isLoggedIn && !loggingIn && !isPublicPath) {
        return AppRoute.login.path;
      }

      if (isLoggedIn && loggingIn) {
        return AppRoute.products.path;
      }

      return null;
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
  products('/products'),
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
  paymentSuccess('/payment-success');

  const AppRoute(this.path);
  final String path;
}
