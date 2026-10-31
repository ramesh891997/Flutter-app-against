import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/app/theme/app_theme.dart';
import 'package:flutter_demo_app/core/widgets/app_error_view.dart';
import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/products_provider.dart';
import 'package:flutter_demo_app/features/products/presentation/screens/products_screen.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_card_skeleton.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAuthRepository mockAuthRepository;

  const tSession = AuthSession(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    accessToken: 'test_token',
  );

  const tProduct = Product(
    id: 1,
    title: 'Essence Mascara',
    description: 'Volumizing mascara',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 20,
    tags: ['beauty'],
    images: [],
    thumbnail: '',
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest({required ProductsNotifier productsNotifier}) {
    return ProviderScope(
      overrides: [
        productsProvider.overrideWith((ref) => productsNotifier),
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            loginUseCase: mockLoginUseCase,
            logoutUseCase: mockLogoutUseCase,
            repository: mockAuthRepository,
          )..state = const AuthState.authenticated(tSession),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProductsScreen(),
      ),
    );
  }

  group('ProductsScreen Widget Tests', () {
    testWidgets(
      'displays ProductListSkeleton shimmer when in initial loading state',
      (tester) async {
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return const PaginatedProducts(
            products: [],
            total: 0,
            skip: 0,
            limit: 15,
          );
        });

        final notifier = ProductsNotifier(mockGetProductsUseCase);
        notifier.state = const ProductsState(
          status: ProductsStatus.loading,
          products: [],
          hasMore: true,
          skip: 0,
          limit: 15,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(productsNotifier: notifier),
        );

        expect(find.byType(ProductListSkeleton), findsOneWidget);
      },
    );

    testWidgets('displays AppErrorView when error occurs and list is empty', (
      tester,
    ) async {
      final notifier = ProductsNotifier(mockGetProductsUseCase);
      notifier.state = const ProductsState(
        status: ProductsStatus.error,
        products: [],
        hasMore: false,
        skip: 0,
        limit: 15,
        errorMessage: 'Failed to load catalog',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(productsNotifier: notifier),
      );

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Failed to load catalog'), findsOneWidget);
    });

    testWidgets(
      'renders ProductCard items when products are loaded with time greeting and user name',
      (tester) async {
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
        ).thenAnswer(
          (_) async => const PaginatedProducts(
            products: [tProduct],
            total: 1,
            skip: 0,
            limit: 15,
          ),
        );

        final notifier = ProductsNotifier(mockGetProductsUseCase);
        notifier.state = const ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct],
          hasMore: false,
          skip: 1,
          limit: 15,
          total: 1,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(productsNotifier: notifier),
        );
        await tester.pump();

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.text('Essence Mascara'), findsOneWidget);
        expect(find.text('Emily'), findsOneWidget);
        expect(
          find.text("You've reached the end of the catalog"),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping logout icon shows logout confirmation dialog', (
      tester,
    ) async {
      final notifier = ProductsNotifier(mockGetProductsUseCase);
      notifier.state = const ProductsState(
        status: ProductsStatus.loaded,
        products: [tProduct],
        hasMore: false,
        skip: 1,
        limit: 15,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(productsNotifier: notifier),
      );

      final logoutButton = find.byTooltip('Log Out');
      expect(logoutButton, findsOneWidget);

      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to sign out of your account?'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log Out'), findsOneWidget);
    });
  });
}
