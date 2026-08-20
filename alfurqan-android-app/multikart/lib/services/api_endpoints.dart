/// Sare api endpoints yaha ek jagah rakho.
/// Jab bhi tum naya curl/api do, isme bas ek line add karni hai.
class ApiEndpoints {
  ApiEndpoints._();
  static const String login = 'Core/LogInWeb';
  static const String register = 'Core/AddUser';

  static const String topCategory = 'https://alfurqan.ae/app/MobileAppApi/GetTopCategory';
  static const String productList = 'https://alfurqan.ae/web/Products/GetAllProductsFront';

  // ---------------- Cart ----------------
  static const String addToCart = 'Cart/AddToCart';
  static const String getCart = 'Cart/GetCart';

  // Aage jitni bhi api dogi, unhe yaha isi tarah add karte jayenge, e.g:
  // static const String forgotPassword = 'Core/ForgotPassword';
}
