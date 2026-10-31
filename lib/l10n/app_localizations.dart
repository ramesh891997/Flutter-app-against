import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight, compile-time type-safe localized string provider.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  /// Default fallback instance for non-context scopes.
  static const AppLocalizations en = AppLocalizations(Locale('en'));

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return instance ?? en;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [Locale('en')];

  // Brand & General
  static const defaultAppName = 'Store';
  static const defaultTagline = 'Explore quality products';
  static const defaultWelcome = 'Welcome';
  static const defaultGuestUser = 'Guest';

  String get appName => defaultAppName;
  String get tagline => defaultTagline;
  String get welcome => defaultWelcome;
  String get guestUser => defaultGuestUser;

  // Time-based greetings
  static const defaultGoodMorning = 'Good morning,';
  static const defaultGoodAfternoon = 'Good afternoon,';
  static const defaultGoodEvening = 'Good evening,';

  String get goodMorning => defaultGoodMorning;
  String get goodAfternoon => defaultGoodAfternoon;
  String get goodEvening => defaultGoodEvening;

  // Authentication
  static const defaultLoginTitle = 'Welcome Back';
  static const defaultLoginSubtitle = 'Sign in to explore our product catalog';
  static const defaultSignIn = 'Sign In';
  static const defaultEnterCredentials = 'Enter your credentials to continue';
  static const defaultUsernameLabel = 'Username';
  static const defaultUsernameHint = 'e.g. emilys';
  static const defaultPasswordLabel = 'Password';
  static const defaultPasswordHint = 'Enter your password';
  static const defaultUsernameRequired = 'Username is required';
  static const defaultUsernameTooShort =
      'Username must be at least 3 characters';
  static const defaultPasswordRequired = 'Password is required';
  static const defaultPasswordTooShort =
      'Password must be at least 6 characters';
  static const defaultShowPassword = 'Show password';
  static const defaultHidePassword = 'Hide password';
  static const defaultUseDemoCredentials = 'Use demo credentials (emilys)';
  static const defaultLogout = 'Log Out';
  static const defaultLogoutConfirmation =
      'Are you sure you want to sign out of your account?';
  static const defaultCancel = 'Cancel';
  static const defaultSessionExpired = 'Session expired. Please log in again.';
  static const defaultLoginUnexpectedError =
      'An unexpected error occurred during login.';

  String get loginTitle => defaultLoginTitle;
  String get loginSubtitle => defaultLoginSubtitle;
  String get signIn => defaultSignIn;
  String get enterCredentials => defaultEnterCredentials;
  String get usernameLabel => defaultUsernameLabel;
  String get usernameHint => defaultUsernameHint;
  String get passwordLabel => defaultPasswordLabel;
  String get passwordHint => defaultPasswordHint;
  String get usernameRequired => defaultUsernameRequired;
  String get usernameTooShort => defaultUsernameTooShort;
  String get passwordRequired => defaultPasswordRequired;
  String get passwordTooShort => defaultPasswordTooShort;
  String get showPassword => defaultShowPassword;
  String get hidePassword => defaultHidePassword;
  String get useDemoCredentials => defaultUseDemoCredentials;
  String get logout => defaultLogout;
  String get logoutConfirmation => defaultLogoutConfirmation;
  String get cancel => defaultCancel;
  String get sessionExpired => defaultSessionExpired;
  String get loginUnexpectedError => defaultLoginUnexpectedError;

  // Product Listing
  static const defaultProducts = 'Products';
  static const defaultEndOfCatalog = "You've reached the end of the catalog";
  static const defaultRetry = 'Retry';
  static const defaultTryAgain = 'Try Again';
  static const defaultRefresh = 'Refresh';
  static const defaultNoProductsTitle = 'No products available';
  static const defaultNoProductsMessage =
      'There are currently no products in the catalog.';
  static const defaultLoadProductsError = 'Failed to load products.';
  static const defaultFailedToLoadMore = 'Failed to load more products.';
  static const defaultRefreshFailed =
      'Refresh failed. Please check your connection.';
  static const defaultOutOfStock = 'Out of stock';
  static const defaultInStock = 'In Stock';

  String get products => defaultProducts;
  String get endOfCatalog => defaultEndOfCatalog;
  String get retry => defaultRetry;
  String get tryAgain => defaultTryAgain;
  String get refresh => defaultRefresh;
  String get noProductsTitle => defaultNoProductsTitle;
  String get noProductsMessage => defaultNoProductsMessage;
  String get loadProductsError => defaultLoadProductsError;
  String get failedToLoadMore => defaultFailedToLoadMore;
  String get refreshFailed => defaultRefreshFailed;
  String get outOfStock => defaultOutOfStock;
  String get inStock => defaultInStock;
  String inStockWithCount(int count) => 'In Stock ($count)';

  // Product Details
  static const defaultProductDetails = 'Product Details';
  static const defaultBack = 'Back';
  static const defaultPrice = 'Price';
  static const defaultDescription = 'Description';
  static const defaultSpecifications = 'Product Specifications';
  static const defaultSku = 'SKU';
  static const defaultWarranty = 'Warranty';
  static const defaultShipping = 'Shipping';

  String get productDetails => defaultProductDetails;
  String get back => defaultBack;
  String brandPrefix(String brand) => 'Brand: $brand';
  String discountPercentOff(int percent) => '$percent% OFF';
  String get price => defaultPrice;
  String get description => defaultDescription;
  String get specifications => defaultSpecifications;
  String get sku => defaultSku;
  String get warranty => defaultWarranty;
  String get shipping => defaultShipping;

  // Error & Empty Views & Accessibility
  static const defaultOopsSomethingWentWrong = 'Oops, something went wrong';
  static const defaultNoItemsFound = 'No items found';
  static const defaultNoItemsMessage =
      'There are no items to display at this moment.';
  static const defaultBackButton = 'Back button';
  static const defaultLogoutIcon = 'Logout icon';
  static const defaultErrorIcon = 'Error icon';
  static const defaultEmptyStateIcon = 'Empty state illustration';

  String get oopsSomethingWentWrong => defaultOopsSomethingWentWrong;
  String get noItemsFound => defaultNoItemsFound;
  String get noItemsMessage => defaultNoItemsMessage;
  String get backButton => defaultBackButton;
  String get logoutIcon => defaultLogoutIcon;
  String get errorIcon => defaultErrorIcon;
  String get emptyStateIcon => defaultEmptyStateIcon;

  // Network & Failure Messages
  static const defaultNetworkError =
      'Unable to connect to the server. Please check your network.';
  static const defaultConnectionTimeout =
      'Connection timed out. Please check your internet connection.';
  static const defaultConnectionError =
      'Unable to reach the server. Please check your network connection.';
  static const defaultCertificateError =
      'Security certificate validation failed.';
  static const defaultRequestCancelled = 'Request was cancelled.';
  static const defaultNoInternet = 'No internet connection available.';
  static const defaultUnexpectedNetworkError =
      'An unexpected network error occurred.';
  static const defaultInvalidRequest = 'Invalid request parameters.';
  static const defaultInvalidCredentials = 'Invalid username or password.';
  static const defaultAccessDenied =
      'Access denied. You do not have permission.';
  static const defaultNotFound = 'Requested resource was not found.';
  static const defaultServerError =
      'Internal server error. Please try again later.';
  static const defaultUnexpectedServerError =
      'Received unexpected status code from server.';
  static const defaultDataParsingError =
      'Failed to parse response from server.';
  static const defaultStorageError = 'Failed to access local secure storage.';
  static const defaultUnknownError =
      'An unexpected error occurred. Please try again.';
  static const defaultEmptyResponseBody =
      'Received empty response from server.';
  static const defaultLoginFailed = 'Login failed. Please try again.';
  static const defaultLogoutFailed =
      'Failed to clear credentials during logout.';
  static const defaultFetchProductsFailed = 'Failed to fetch products.';
  static const defaultFetchProductDetailsFailed =
      'Failed to fetch product details.';

  String get networkError => defaultNetworkError;
  String get connectionTimeout => defaultConnectionTimeout;
  String get connectionError => defaultConnectionError;
  String get certificateError => defaultCertificateError;
  String get requestCancelled => defaultRequestCancelled;
  String get noInternet => defaultNoInternet;
  String get unexpectedNetworkError => defaultUnexpectedNetworkError;
  String get invalidRequest => defaultInvalidRequest;
  String get invalidCredentials => defaultInvalidCredentials;
  String get accessDenied => defaultAccessDenied;
  String get notFound => defaultNotFound;
  String get serverError => defaultServerError;
  String get unexpectedServerError => defaultUnexpectedServerError;
  String get dataParsingError => defaultDataParsingError;
  String get storageError => defaultStorageError;
  String get unknownError => defaultUnknownError;
  String get emptyResponseBody => defaultEmptyResponseBody;
  String get loginFailed => defaultLoginFailed;
  String get logoutFailed => defaultLogoutFailed;
  String get fetchProductsFailed => defaultFetchProductsFailed;
  String get fetchProductDetailsFailed => defaultFetchProductDetailsFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
