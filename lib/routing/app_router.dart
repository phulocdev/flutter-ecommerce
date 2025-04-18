import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/screens/cart_screen.dart';
import 'package:flutter_ecommerce/screens/forgot_password_screen.dart';
import 'package:flutter_ecommerce/screens/login_screen.dart';
import 'package:flutter_ecommerce/screens/otp_screen.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart';
import 'package:flutter_ecommerce/screens/products_screen.dart';
import 'package:flutter_ecommerce/screens/profile_screen.dart';
import 'package:flutter_ecommerce/screens/registration_screen.dart';
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
  // Use Provider if you need ref, otherwise just define GoRouter directly
  // In a real app, you'd check auth state here using ref.watch(authProvider)
  final bool isLoggedIn = true; // Placeholder: Replace with actual auth check

  return GoRouter(
    initialLocation: AppRoute.products.path, // Start at the products screen
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true, // Useful for debugging routing issues

    // Define all routes
    routes: [
      // Application shell using ShellRoute
      // This provides the persistent Scaffold with BottomNavigationBar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Return the widget that implements the custom shell (e.g., ScaffoldWithNavBar)
          // The navigationShell is passed to be able to navigate between sections
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home/Products Tab
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoute.products.path, // '/' or '/products'
                name: AppRoute.products.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey, // Important for state preservation
                  child: const ProductScreen(), // Your products screen
                ),
                routes: [
                  // Nested route for product details under the home tab
                  GoRoute(
                    path: AppRoute.productDetail.path, // 'product/:id'
                    name: AppRoute.productDetail.name,
                    // Use root navigator to push detail screen over the shell
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final productId = state.pathParameters['id'];
                      // TODO: Fetch product details based on productId
                      // For now, let's assume product is passed via extra (not ideal for deep links)
                      // Better: pass ID and fetch in ProductDetailScreen, or use a Provider
                      final Product? product = state.extra as Product?;
                      if (product != null) {
                        return ProductDetailScreen(product: product);
                      } else if (productId != null) {
                        // Ideally fetch product using productId here or inside the screen
                        return ProductDetailScreen(
                            product: Product(
                                id: DateTime.now().toString(),
                                name: 'Test',
                                description: 'test',
                                price: 12,
                                imageUrl:
                                    'https://picsum.photos/seed/d_monitor_curved/250/250'));
                      } else {
                        // Handle error: ID missing or invalid
                        return const Scaffold(
                            body: Center(child: Text('Product not found')));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Cart Tab
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCartKey,
            routes: [
              GoRoute(
                  path: AppRoute.cart.path, // '/cart'
                  name: AppRoute.cart.name,
                  pageBuilder: (context, state) => NoTransitionPage(
                        key: state.pageKey,
                        child: const CartScreen(), // Your cart screen
                      ),
                  routes: [
                    // Optional: Nested routes within cart if needed, e.g., checkout
                    // GoRoute( path: 'checkout', ... ),
                  ]),
            ],
          ),

          // Branch 3: Profile Tab
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoute.profile.path, // '/profile'
                name: AppRoute.profile.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(), // Your profile screen
                ),
              ),
            ],
          ),
        ],
      ),

      // Top-level routes (no bottom navigation bar)
      GoRoute(
        path: AppRoute.login.path, // '/login'
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path, // '/register'
        name: AppRoute.register.name,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path, // '/forgot-password'
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
          path: AppRoute.otp.path, // '/otp' - often needs parameters
          name: AppRoute.otp.name,
          builder: (context, state) {
            // Example: Extract verificationId or phone number if passed
            // final String? verificationId = state.extra as String?;
            return const OTPScreen(/* pass params if needed */);
          }),
    ],

    // Optional: Add redirection logic (e.g., redirect to login if not authenticated)
    // redirect: (BuildContext context, GoRouterState state) {
    //   final bool loggedIn = isLoggedIn; // Use your auth state logic
    //   final bool loggingIn = state.matchedLocation == AppRoute.login.path ||
    //                          state.matchedLocation == AppRoute.register.path; // etc.

    //   // If not logged in and not on a public page, redirect to login
    //   if (!loggedIn && !loggingIn && state.matchedLocation != AppRoute.forgotPassword.path) {
    //     return AppRoute.login.path;
    //   }

    //   // If logged in and trying to access login/register, redirect to home
    //   if (loggedIn && loggingIn) {
    //     return AppRoute.products.path;
    //   }

    //   // No redirect needed
    //   return null;
    // },

    // Optional: Error handling
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
  products('/'),
  productDetail('product/:id'),
  cart('/cart'),
  profile('/profile');

  const AppRoute(this.path);
  final String path;
}
