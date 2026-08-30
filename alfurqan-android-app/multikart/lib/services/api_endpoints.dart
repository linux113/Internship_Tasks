/// Sare api endpoints yaha ek jagah rakho.
/// Jab bhi tum naya curl/api do, isme bas ek line add karni hai.
class ApiEndpoints {
  ApiEndpoints._();
  static const String login = 'Core/LogInWeb';
  static const String register = 'Core/AddUser';
  // Profile update (PUT) — body: {name, email, phone, country_code, _method:"PUT"}
  static const String updateUserProfile = 'Core/UpdateUserProfile';
  static const String getUserDetail = 'Core/GetUserDetail';
  // Orders (login ke baad, token se)
  static const String getUserOrders = 'Orders/GetUserOrders';
  // Ek order ka FULL detail (items + status timeline + address + totals)
  static const String getOrder = 'Orders/GetOrder';
  // Checkout preview (totals) + FINAL order place — OrderSaveDto body
  static const String checkout = 'Orders/CheckOut';
  static const String placeOrder = 'Orders/OrderPlace';
  // Coupons list
  static const String getCoupons = 'Coupon/GetAllCoupons';
  // Change password — body: {current_password, new_password, confirm_password}
  static const String changePassword = 'Core/ChangePassword';
  // CMS pages (Terms & Conditions / About Us ka content backend se)
  static const String getPages = 'Pages/GetAllPages';
  // Wallet points transactions
  static const String getPoints = 'Wallet_Point/GetPoints';
  // Wallet balance (login ke baad)
  static const String getWallet = 'Wallet_Point/GetWallet';

  static const String topCategory = 'https://alfurqan.ae/app/MobileAppApi/GetTopCategory';
  static const String productList = 'https://alfurqan.ae/web/Products/GetAllProductsFront';

  // ---------------- NAYA home api (purana GetTopCategory band ho gaya hai) ----------------
  // Full url: https://alfurqan.ae/api/MobileAppApi/GetHomePageDataApp
  static const String homePageData = 'MobileAppApi/GetHomePageDataApp';

  // ---------------- Cart ----------------
  static const String addToCart = 'Cart/AddToCart';
  static const String getCart = 'Cart/GetCart';

  // ---------------- Location (countries/states) ----------------
  // NOTE: api/Core/* (api namespace) use karo — web/CoreFront wali list ke
  // CountryId backend ke Core_Countries table se match nahi karte, jisse
  // AddAddress me FK error aati thi
  // ("FK_Addresses_Core_Countries_CountryId"). api/Core wali list wahi table
  // read karti hai jis table ka FK lagta hai.
  static const String countries = 'https://alfurqan.ae/api/Core/GetAllCountry';
  // fallback (purana web wala): https://alfurqan.ae/web/CoreFront/GetAllCountryFront
  static const String states = 'https://alfurqan.ae/api/Core/GetStates';
  // fallback (purana web wala): https://alfurqan.ae/web/CoreFront/GetStatesFront
  static const String currencies = 'https://alfurqan.ae/web/CoreFront/GetAllCurrenciesFront';

  // ---------------- Address (login ke baad — POST me user_id bhejna zaroori) ----------------
  static const String addAddress = 'Location/AddAddress';
  // swagger se (live verify): list/update/delete bhi available hai (token chahiye)
  static const String getAllAddress = 'Location/GetAllAddress';
  static const String updateAddress = 'Location/UpdateAddress';
  static const String deleteAddress = 'Location/DeleteAddress';

  // ---------------- Wishlist (login ke baad) ----------------
  static const String addToWishlist = 'Wishlist/AddToWishlist';
  static const String getWishlist = 'Wishlist/GetWishlist';
  static const String deleteWishlist = 'Wishlist/DeleteWishlist';

  // Aage jitni bhi api dogi, unhe yaha isi tarah add karte jayenge, e.g:
  // static const String forgotPassword = 'Core/ForgotPassword';
}
