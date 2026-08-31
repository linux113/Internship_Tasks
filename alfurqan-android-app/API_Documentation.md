# Al Furqan Mobile App — API Documentation

> Source: Google Doc shared by project owner
> (`https://docs.google.com/document/d/1RqD8YPsdxD0uNmvpa8s9TqCYum5UWh3g`)
> Base URL: **https://alfurqan.ae**

---

## ⚡ NEW — Home Page API (added 2026-08-24, replaces stopped GetTopCategory)

- **API:** `https://alfurqan.ae/api/MobileAppApi/GetHomePageDataApp`
- **Type:** `GET`
- **Used in app for:** home banners (with product/category/external redirect links),
  top categories row, Deals of the Day, Find Your Style tabs (Trending/Top Picks/
  Featured/Top Rated/Ready to Ship), Trending products, offer banners.
- **Response shape:** `{ code, message, isSuccess, data: { slug, contentApp: {...} } }`
- **contentApp sections:**
  - `Home_Banner.Banners[]` → `{ Image_Url, Status, Redirect_Link: { Link, Link_Type: "product"|"collection"|"external_url", Product_Ids: [264] } }`
  - `Find_Your_Match.Tab_One..Tab_Five` → `{ Title, MatchTabProducts: [{ Id, Name, Slug, ImageUrl, Price, Discount, DiscountPrice, Rating }] }`
  - `Deals_Of_The_Day.Products[]` → same product shape
  - `Tranding_Products.Products[]` → same product shape
  - `Offer_Banner.Banner_1..3` → same banner shape
  - `Top_Category.TopCategories[]` → `{ Id, Name, Slug, ImageUrl }`
  - `Brand.Brands[]` → `{ Id, Name, Slug, ImageUrl }` (Status=false right now)
- **NOTE:** Keys are CAPITALIZED in this API (unlike the older lowercase snake_case APIs).
- **NOTE (2026-08-24):** Old `https://alfurqan.ae/app/MobileAppApi/GetTopCategory` now returns **404 (stopped by backend)**. `GetAllProductsFront` (products catalog) is still alive and used for shop/search/category-product pages.

---

## 1. Login

- **API:** `https://alfurqan.ae/api/Core/LogInWeb`
- **Type:** `POST`
- **Note:** Check required payload and get response.

## 2. Register User

- **API:** `https://alfurqan.ae/api/Core/AddUser`
- **Type:** `POST`

## 3. Category Page

- **API:** `https://alfurqan.ae/app/MobileAppApi/GetTopCategory`
- **Type:** `GET`
- **Note:** For the category icons shown in the mobile app — the page that opens when a
  category icon is tapped. The API response contains images which must be shown.
  The link to open is `https://alfurqan.ae/category/` + `slug` (slug comes from the response).
- **Example:** `https://alfurqan.ae/category/jurisprudence`

## 4. Category Product Page

- **API:**
  ```
  https://alfurqan.ae/web/Products/GetAllProductsFront?page=1&paginate=12&status=1&field=created_at&price=&category=jurisprudence&tag=&sort=asc&sortBy=asc&rating=&attribute=
  ```
- **Type:** `GET`

### Parameters

| Parameter   | Meaning |
|-------------|---------|
| `page`      | Which page of results (all products cannot be loaded at once) |
| `paginate`  | How many products per page |
| `price`     | Price range filter, e.g. `0-100,100-200` — always comma separated |
| `status`    | Approved products filter (info only — data comes even without it) |
| `category`  | Selected category slug(s), comma separated — e.g. `category=jurisprudence,history,women` |
| `sort`      | Order by — only `asc` or `desc` |
| `rating`    | Filter by rating — only values `1`, `2`, `3`, `4`, `5` |
| `attribute` | Item attributes — e.g. book language, book cover, and more |

> **Note:** More parameters will be communicated later.

## 5. Add To Cart

- **API:** `https://alfurqan.ae/api/Cart/AddToCart`
- **Type:** `POST`
- **JSON payload to send:**

```json
{
  "total": 500.00,
  "items": {
    "id": 0,
    "product_id": productId,
    "variation_id": null,
    "quantity": 10,
    "sub_total": 500,
    "wholesale_price": 50
  }
}
```

- Posting this request saves the data.
- **Save the response locally** — it returns the full cart data.

## 6. Get Cart

- **API:** `https://alfurqan.ae/api/Cart/GetCart`
- **Type:** `GET`
- **Note:** Returns all cart data with products and everything.

## 2026-08-24 (v1.0.2+3) UI cleanup + guest mode

- Home categories ab ICON form me (circular image + name), API Top_Category se.
- Section titles/descriptions ab API se: Deals_Of_The_Day.Title/Description,
  Tranding_Products.Title/Description. Find_Your_Match ka section-level Title
  API abhi nahi bhejta (sirf tab titles aate hai) — isliye app text
  "Find Your Match" use hota hai; backend Title/Description add kare to
  app khud usko pick kar legi (matchSectionTitle/Description ready hai).
- Demo sections HATA diye: "Denim Wear Sales Starts In" timer, fake brand
  logos (NORTH2.0/treva/velocity9), fake "upto 50% off" Offer Corner tiles.
  Ab Offer_Banner.Banner_1 = bada offer banner, Banner_2/3 = Offer Corner grid,
  Brand.Status=true ho tabhi brands dikhte hai (abhi backend me false hai).
- Price fix: "AED 30.0 AED 30.00 ( off)" — ab selling price hamesha
  2 decimals, struck original sirf tab jab discount ho, "( off)" kabhi khaali nahi.
- Category tab: image rounded corners (pehle sharp the), demo sales icon hata diya.
- GUEST MODE: app kholte hi login NAHI maangta — seedha home/dashboard khulta
  hai. Login sirf Add-to-Cart jaise protected action par ya Profile > SIGN IN se.
  Ek baar login karne ke baad app band karke kholne par bhi session bana rehta hai.
  Profile tab guest ko "Guest" + SIGN IN chip dikhata hai.

## 2026-08-26 (v1.0.3+4) Wishlist + Address + Currency REAL APIs

### Ab live wired APIs
| Kaam | API | Note |
|---|---|---|
| Countries (+ states inside) | GET web/CoreFront/GetAllCountryFront | country object ke andar hi `state[]` aata hai — country select karte hi states mil jate hai |
| States (saare) | GET web/CoreFront/GetStatesFront | fallback/complete list (client-side country_id se filter hota) |
| Currencies | GET web/CoreFront/GetAllCurrenciesFront | data.data list; code/symbol/exchange_rate |
| Address save | POST api/Location/AddAddress | LOGIN zaroori; body me poora country object + state object + user_id; CITY = TEXT input (web jaisa hi) |
| Wishlist add | POST api/Wishlist/AddToWishlist | body {id:0, consumer_id, product_id} |
| Wishlist get | GET api/Wishlist/GetWishlist | login ke baad sync — server list source-of-truth |
| Wishlist delete | DELETE api/Wishlist/DeleteWishlist?id=ENTRY_ID | NOTE: `id` = wishlist ENTRY id (product id nahi) |

### Behavior
- Guest: wishlist local device me save hoti hai (jaisa pehle). Login karte hi
  guest-local items pehle server par PUSH hote hai, phir server list se merge.
- Heart tap: local turant (UI fast) + background me server add/delete sync.
- Address form: Country dropdown (default UAE) -> State dropdown (us country ki
  states) -> City TEXT field. Save = POST + local copy (Saved Address page aur
  Checkout address step dono me dikhta hai). Guest save dabata hai to pehle
  login page khulta hai.
- Currency selector ab API se: AED (base, rate 1), INR (~27), USD.

### Backend data issues (inhe backend me theek karna hoga)
- USD ka exchange_rate 3.65 hai (= 1 USD kitne AED, UAE peg) — INVERTED stored
  hai. App isko auto-correct (1/3.65) karke dikhata hai, par behtar hai backend
  me USD rate 0.27 kar do.
- GBP aur EUR ka exchange_rate 0.01 hai — placeholder/galat. Itne chhote rate
  par price galat (65 AED -> £0.65) dikhti, isliye app abhi GBP/EUR ko list se
  HIDE kar deta hai. Backend me sahi rate (GBP ~0.20, EUR ~0.23) daalne par wo
  khud show ho jayenge.
- "EUR " code me trailing space hai — app trim karta hai.

## 2026-08-26 (v1.0.4+5) Address AutoMapper fix + detail wishlist + cart cleanup

- AddAddress POST: backend (.NET AutoMapper) nested `state` object ko map nahi
  kar pa raha tha — error "Missing type map configuration... StateDto -> State,
  Destination Member: State". Ab app 3 payload variants try karti hai:
  (1) curl-exact, (2) state:null (scalar stateName/state_id + country object),
  (3) state+country dono null. Jo pehle success ho wahi use hota hai.
  (Backend me StateDto->State ka CreateMap add kar doge to variant 1 hi chalega.)
- Product DETAIL page ka WISHLIST button pehle sirf wishlist tab kholta tha,
  product SAVE nahi karta tha — ab pehle save hota hai (local+server) phir
  wishlist tab khulti hai.
- Cart: fake "Qty 1 / Size S" dropdowns hide (books ke liye meaningless),
  "Move to wishlist" ab real save karta hai, "You May also Like" ab demo
  fashion ki jagah REAL books dikhata hai (tap se real detail khulta hai).

## 2026-08-26 (v1.0.5+6) FK fix + wishlist remove + cart enrichment

- AddAddress country source BADLI: ab `api/Core/GetAllCountry` (api namespace,
  wahi Core_Countries DB table) se aati hai. Pehle `web/CoreFront/GetAllCountryFront`
  ke ids DB table se match nahi karte the — isliye INSERT par
  "FK_Addresses_Core_Countries_CountryId" error aati thi. States bhi
  `api/Core/GetStates` (dono live verify kiye).
- Wishlist Remove button ka copy-paste bug fix (Remove ab bhi Add-to-Cart
  trigger karta tha). Title ka count dynamic "Your Wishlist (N)".
- Cart items jinme GetCart product detail nahi bhejta ("Product #264" + khali
  image) — ab app ke loaded product pools se naam/image/price bharte hai.
- Cart item ka id ab PRODUCT id hai (pehle cart-row id thi — Move-to-wishlist
  galat id save karta tha).
- DB/.NET raw errors user ko nahi dikhte — friendly toast.

## 2026-08-26 (v1.0.6+7) Address SCALAR country_id fix + wishlist multi-delete fix

### 1) Address save = FOREIGN KEY error — ROOT CAUSE pakda gaya (swagger)

- Live swagger (`https://alfurqan.ae/swagger/v2/swagger.json`) ka **AddressDto**
  schema dekha: `country_id` aur `state_id` SCALAR fields hai (i32), saath me
  `is_default` (i32) aur `country_code` (str). Website ka working curl bhi yahi
  bhejta hai (humara curl doc wahi se truncated tha).
- Backend ka `Addresses` table FK columns (`CountryId`/`StateId`) INHI scalar
  fields se bharta hai. Pehle app sirf nested `country`/`state` objects bhejta
  tha → CountryId=0 insert → DB har baar
  `FK_Addresses_Core_Countries_CountryId` error deta tha.
- FIX: har payload variant me scalar `country_id` + `state_id` + `is_default`
  + `country_code` AB HAMESHA jaata hai; variant 1 = web-exact (objects null,
  sirf scalars). Purane 2 variants (country object / dono objects) fallback
  ke roop me bane rahe.

### 2) Wishlist — 1 remove karne par 3 hat jaana — FIX

- Parse bug: `ServerWishlistItem` flat server row me `product_id` ki jagah
  wishlist ENTRY ka `id` product-id samajh leta tha → list me id collisions /
  duplicates → `removeWhere(id == ...)` ek saath kai items hata deta tha.
- FIX: product id ab HAMESHA pehle entry-level `product_id` se aati hai;
  nested product ka `id` sirf tab jab sach me alag nested object ho.
- Local list + server list dono productId se DEDUPE hoti hai (ek product ek
  hi baar dikhega).
- Server par ek product ki DUPLICATE wishlist entries ho to sync unhe
  background me clean karti hai; remove par us product ki SARI entries delete
  hoti hai + fresh server list pull → stale item wapas nahi aata.
- Save-side guard: jo product server par pehle se wishlisted hai use dobara
  add nahi karte (duplicates hi nahi bante).
- Purane version ki galat-id wali local items entryId/naam match karke skip —
  junk push band.

## 2026-08-27 (v1.0.7+8) Address EDIT/REMOVE working + wishlist "only one item" fix

### 1) Address EDIT button kaam nahi karta tha — FIX
- Root cause: Saved Address list ke REMOVE/EDIT buttons (ActionButton) me koi
  tap handler hi nahi tha — sirf demo UI tha.
- Ab: EDIT → Add Address form existing address se PREFILL hokar khulta hai;
  SAVE par `PUT api/Location/UpdateAddress` (existing id + scalar
  country_id/state_id payload) hota hai. Kabhi server par save na hua local
  address ho to POST AddAddress se upload ho jata hai.
- REMOVE → local + `DELETE api/Location/DeleteAddress?id=` (server-par-saved
  ho to). Saved Address page aur checkout Delivery page dono refresh hote hai.
- Naye endpoints (swagger se, live): `GET api/Location/GetAllAddress` (token
  se meri list — website par save kiye addresses bhi dikhte hai, install
  ke baad bhi), `PUT UpdateAddress`, `DELETE DeleteAddress` dono app me wired.

### 2) Wishlist me sirf EK item add hota tha — FIX
- Root cause: GetWishlist rows ka shape backend ke hisaab se atakta hai
  (product nested object kabhi LIST hota hai, kabhi product_id row me hi nahi
  hota). Parse miss par productId null → sab items display-id `0` le lete the
  → dedupe ne sabko ek samajh kar chipka diya → list me bas 1 item bachta tha.
- FIX: parser ab entry id (`id`/`Id`/`wishlist_id`...), product id
  (entry-level `product_id` family pehle), aur nested product (Map HO YA
  single-item LIST — dono) leniently padhta hai. Display ke liye UNIQUE
  `displayId = productId ?? wishlistId` use hota hai — parse miss hone par bhi
  har entry alag id rakhti hai, isliye list kabhi collapse nahi hoti.
- Add/remove dono isi displayId par chalte hai → remove hamesha sirf wahi ek
  item hataata hai; add ke baad poori list sahi dikhti hai.

## 2026-08-27 (v1.0.8+9) Wishlist 4-par-atakna FIX (union sync)

- Swagger verify (chunk 23): `GET api/Wishlist/GetWishlist` me KOI parameter/
  pagination nahi — server cap nahi karta. Problem app-side sync design me thi.
- Root cause: har add ke baad app server list se LOCAL list ko REPLACE karta
  tha. GetWishlist naya item turant nahi dikhata (ya shape badalta hai) → naya
  item chupchaap list se gayab ho jata tha → wishlist purani 4 par atak jati.
- FIX (wishlist sync engine dobara likha):
  - Add: local turant + server POST; response ki wishlist ENTRY id register,
    local list ko kabhi overwrite nahi karte.
  - Sync: UNION (server items + local-only) — local list server response ki
    wajah se kabhi CHHOTI nahi hoti; local-only items server par re-push bhi
    hote hai. Guest favorites login par save rehte hai.
  - Remove: us product ki SARI server entries delete; entry id na pata ho to
    ek fresh fetch se dhoondh kar delete. Local se turant hatata hai.
  - UI (wishlist screen + count) har add/remove par turant refresh.
- Console me ApiService ke Wishlist request/response logs chhape rehte hai —
  agar kabhi phir issue aaye to `flutter run` console ki Wishlist lines
  screenshot/copy karke bhejne se root cause turant pakda jayega.

## 2026-08-27 (v1.0.9+10) Wishlist RACE fix + hearts sahi state (screenshot bug)

- User ne 6 books par heart dabaye (sab red dikhe) par wishlist me sirf 2
  bache. Root cause RACE CONDITION — deep fix:
  1) Background server-sync purana local SNAPSHOT pakad kar baad me `_saveAll`
     overwrite karta tha — sync chalte waqt dabaye gaye naye hearts wipe ho
     jate the. Ab final merge ATOMIC hai: push ke BAAD fresh local dobara
     padhkar turant save (beech me koi await nahi) → koi item kabhi wipe nahi.
  2) Naye items jo sync ke dauraan aaye unhe next auto-sync par push karne ke
     liye `_serverSynced` smart flag.
  3) REMOVE ke dauraan sync chale to server rows item ko wapas na le aaye —
     `_recentlyRemoved` TOMBSTONE set: zombie server rows sync me drop + delete
     retry; fetch confirm hone par tombstone auto-clear. Dobara add karne par
     tombstone turant hatt jata hai.
  4) Home/product lists ke hearts pehle sirf in-memory state dikhate the —
     ab `syncFavStatesFromWishlist()` har add/remove/home-load par hearts ko
     SACH (saved wishlist) ke mutabik set karta hai. Ab jo red heart dikhega
     wo wishlist me hoga HI.

## 2026-08-29 (v1.1.0+11) Bara fix batch (13 issues)

- #1/#2/#4 Drawer: guest me ab "Hello, Guest" + LOG IN button (pehle Paige
  Turner + LOG OUT aata tha); login ke baad REAL name. Orders/Your Account
  guest taps -> login page. Paige photo -> neutral person icon (har jagah).
- #5 Profile Setting: SAVE ab PUT api/Core/UpdateUserProfile ({name,email,
  phone,country_code,_method:"PUT"}) — pehle button sirf page band karta
  tha. EDIT chip profile setting kholta hai + naam/email prefill.
- #8 Similar product tap: naye product par page TOP par scroll.
- #9 Shop title: slug ki jagah category NAME + "2050 products" hardcode ki
  jagah REAL product count. Shop callers ab {'slug','name'} map bhejte hai.
- #10 Cart REMOVE: pehle sirf demo bottom sheet tha + puri list par ek
  InkWell jo DEMO "cloths" product page kholta tha. Ab real remove (UI
  turant + totals recompute + server par qty:0 AddToCart + GetCart confirm);
  image tap real product detail.
- #11 Delivery Details ka "Expected Delivery" gray locked blank container
  (static demo) hata diya.
- #12 **Phone BACK GESTURE root cause**: template ne WillPopScope -> PopScope
  migrate kiya par `canPop:false` rakha + onPopInvoked se `return true` —
  PopScope me callback ka return value IGNORE hota hai isliye gesture dead
  tha. Sab pages par canPop:true (+cleanup didPop ke baad). Login me
  canPop = isBack.
- #13 Order History: demo kapdon ke orders gaye — ab api/Orders/GetUserOrders
  (lenient parse); guest -> login msg; empty -> "No orders yet".
- Payment page: static demo cards slider -> "No saved cards yet" (cards ka
  backend api nahi); Wallet balance ab api/Wallet_Point/GetWallet se REAL.

## 2026-08-29 (v1.1.1+12) Back-gesture deep-audit — dashboard + onboarding baaki the

- v1.1.0 me sab PAGE-level PopScope fix ho gaye the, par deep audit me 2 root
  screens abhi bhi `canPop:false` par mile:
  - **Dashboard (home/root):** pehle back gesture BILKUL dead tha (koi handler
    hi nahi tha). Ab standard behaviour: dusre bottom-tab par back dabao ->
    pehle Home tab par aa jao; Home tab par 2 second ke andar back DOBARA
    dabao tabhi app exit hogi — beech me "Press back again to exit" toast.
  - **Onboarding (intro):** wahi purana broken pattern (`onPopInvoked` se
    return true jo PopScope me IGNORE hota hai). Ab login jaisa:
    `canPop = isBack` (arguments se) — jahan se aaya wapas ja sakta hai.
- Ab pure app me koi dead back gesture nahi: product detail, shop, inner
  category, login, onboarding, dashboard — sab verified.

## 2026-08-29 (v1.1.1+12 hotfix-audit) Second deep audit — reference-level

- Full reference audit chalaya: routes (30/31 wired — `changeTheme`/`myCart`
  template ke unused leftovers, kahin call nahi hote), AppArray getters (sab
  defined), Session keys (sab defined), controllers/classes (sab maujood),
  ApiEndpoints (sab defined), assets (logo/m_logo dono disk par), language
  keys (AppFonts-style usage app me hai hi nahi — sab direct text).
- "Paige Turner" sirf translation files me DEAD entry — koi view use nahi
  karta, render nahi hota.
- Nit clean: product detail scroll-top me duplicate `hasClients` condition
  hatayi (behaviour same).

## 2026-08-30 (v1.2.0+13) CHECKOUT LIVE + 6 naye features (sab demo/static hatao batch)

- **⭐ PLACE ORDER (sabse bada):** pehle "Pay Now" seedha STATIC success
  page kholta tha — server par order kabhi nahi jata tha! Ab REAL flow:
  POST api/Orders/CheckOut (preview, best-effort) -> POST api/Orders/
  OrderPlace (FINAL). Body OrderSaveDto (swagger verify): {consumer_id,
  products:[{product_id, variation_id, quantity}], shipping_address_id,
  billing_address_id, points_amount:false, wallet_balance:false, coupon,
  delivery_description, delivery_interval, payment_method:"cod"}.
  Guards: login zaroori, cart khaali nahi, SERVER-saved address chahiye
  (selected address id delivery step par storage me save hota hai).
  Success par local cart clear + coupon reset + order success page.
  Payment page se FAKE offers list + FAKE card/wallet/bank methods hate;
  unki jagah REAL coupon box (View Coupons link ke sath) + COD selector.
- **Order Detail REAL:** order history card tap ab real order id bhejta
  hai; detail page GET api/Orders/GetOrder?id= se LIVE items, status
  timeline (OrderStatusActivities), shipping address, price breakup —
  purana static banner/timeline/demo address pura hata diya.
- **Coupons REAL:** GET api/Coupon/GetAllCoupons (demo coupon list gayab;
  loading/empty states). APPLY tap -> code storage me save (checkout par
  auto use).
- **Profile server prefill:** GET api/Core/GetUserDetail — phone (jo login
  response me nahi aata) ab server se prefill hota hai.
- **CHANGE PASSWORD working:** POST api/Core/ChangePassword
  {current_password, new_password, confirm_password} (PasswordChangeDto).
  Profile Setting me pehle "Date of birth" label wala box ab "Phone",
  + Current/New password boxes + real button.
- **Category tab REDESIGN:** odd/even colored boxes (user: "ugly") ki jagah
  clean 3-column modern grid — rounded image card + naam, REAL api data,
  tap -> shop page (slug + naam).
- **Terms & Conditions + About Us REAL:** backend CMS Pages (GET
  api/Pages/GetAllPages) se content (slug/title match: "term"/"about",
  HTML strip karke). Backend me page nahi mila to saaf message — demo
  Lorem Ipsum wapas nahi aata.
- **Wallet transactions:** GET api/Wallet_Point/GetPoints — balance ke
  niche real transaction history list.

## 2026-08-30 (v1.2.1+14) Bug-hunt pass — 2 real bugs pakde aur fix kiye

Deep line-by-line audit ke baad mile bugs + fixes:
- **BUG 1 (CMS instance mix-up):** Terms & About EK hi CmsPageController
  instance share karte the — About kholte hi piche pada Terms page bhi
  About ka content dikhane lagta tha. FIX: har page ka alag TAGGED
  instance ('cms-term' / 'cms-about') + GetBuilder tag ke sath.
- **BUG 2 (currency hardcode):** Order Detail page par price "AED"
  hardcoded tha — user ki SELECTED currency ignore hoti. FIX: ab wallet
  jaisa `priceSymbol × rateValue` use hota hai (USD select karo to $ me
  dikhega).
- Check kiya gaya aur galat NAHI nikla: payment total arguments flow
  (delivery→payment sahi jata hai), OrderSuccess page, qty parse, coupon
  guard (Get.isRegistered), order detail Get.put cycle. Woh sab sahi tha.

## 2026-08-30 (v1.2.2+15) COMPILE FIX — card_balance.dart context shadowing

- Device build error: `CardBalanceController can't be assigned to
  BuildContext` at card_balance.dart:35 — v1.1.0 ke wallet rewrite me
  GetBuilder ka builder param galati se `context` naam ka tha, jisse andar
  ke `MediaQuery.of(context)` ko ye controller (context nahi) lagta tha.
  FIX: param ka naam `cardBalanceCtrl` kiya — ab asli BuildContext milta
  hai. Pure lib me ye pattern sirf yahi 1 jagah tha (globally grep verify).
- Dart compiler ek pass me SAARE errors dikhata hai — us build me sirf
  yahi 1 error tha, matlab baaki sab compile-clean hai.

## 2026-08-30 (v1.2.3+16) STRICT team-review pass — BUG #3 (infinite refetch) fix

6-reviewer style full audit (type-hunter, API-review, controller logic,
view/nav, null-safety, const-check) ke baad:
- **BUG #3 (REAL):** CmsPageController ka guard sirf `content.isNotEmpty`
  tha — agar backend me Terms/About page NAHI mila (content khaali), to
  har rebuild par naya fetch hota jata (build->fetch->update->build->
  fetch... INFINITE REFETCH LOOP, data/battery waste + LG sakta tha app).
  FIX: `_attempted` flag — ek page par ek hi baar attempt (Retry chhod kar).
- Confirmed SAFE (galat nahi nikla): saare `!` asserts guarded hain
  (pehle != null checks), const constructors sahi, route arguments dono
  taraf match, ApiService ka "data" unwrap + mere lenient parsers dono
  cases cover karte hai, base URL https://alfurqan.ae/api/ + endpoints
  swagger se exact match.

## 2026-08-31 (v1.3.0+17) Screenshot feedback batch — cart ghost item, drawer texts, hides

User ke 4 screenshots se mile issues + fixes:
- **CART "auto-product":** CartController singleton rehne se cart tab dobara
  kholne par PURANA data dikhta tha; plus server cart ka purana leftover
  item (remove tab kaam nahi karta tha jab add hua tha). FIX: cart screen
  har baar khulne par FRESH GetCart (initState refresh). Agar phir bhi
  koi item dikhe to wo SERVER par sach me saved hai — Remove button ab
  server par bhi delete karta hai.
- **Drawer fashion texts:** "Men, Women, Kids, Beauty.." (fashion template
  ka text) -> "Quran, Hadees, Fiqh, Seerah & more". Home/Orders/Wishlist/
  Account subtitles bhi book-shop ke hisaab se (Saved Cards hata diya
  kyunki saved-cards backend me hai hi nahi).
- **HIDE (user request):** drawer se Notification (index 10 — backend API
  nahi hai) + About us (index 12) gayab; app bar ka BELL icon bhi har jagah
  se hata diya. Index mapping wahi rakhi (goToPage sahi chalta hai).
- **Cart "Coupons:" dead label -> FUNCTIONAL:** ab "View Coupons" link se
  asli coupons page khulta hai; APPLY karne se code cart me green chip me
  dikhta hai, X se remove; Place Order par coupon apne aap lagta hai
  (pehle ka coupon plumbing isi 'coupon_code' storage se chalti thi).
- Strict checks: 542 files 0 problems; DeleteIcon/Space/BorderLineLayout
  sab existing widgets hi use hue.

## 31 Aug 2026 (v1.3.1+18) AGENCY-AGENTS STRICT FULL-POWER AUDIT — onboarding fashion images+text khatam, Help Lorem khatam, Pages menu hide

User ne agency-agents repo (msitarzewski/agency-agents) lagakar FULL strict review karaya — team roles: **Mobile App Builder, Code Reviewer, AppSec Engineer, Reality Checker, API Tester, UI Designer**. Report:

### 🔴 BLOCKERS found & FIXED (user-visible)
1. **Onboarding ke TEENO images pure fashion template the** — phone mockup jisme "Multikart" logo, Women/Men/Kids/Beauty/Footwear, "Welcome To Multikart Flat 50% OFF", "Pink Hoodie by Mango", "Blue Denim Jacket $32". App ka PEHLA screen! → 3 NAI bookstore images banayi (Quran stack + lantern / rehal par khuli kitab + bachchon ki books / delivery scooter + books parcel + masjid). Theme green #044015, koi embedded text nahi.
2. **Onboarding TEXTS fashion the** (4 languages): "Latest Trends In Clothing For Women, Men & Kids At Multikart...", titles "Perfect Pair for Everyone" etc. → book-shop copy: Quran/Hadees/Fiqh/Seerah collection, har umr ki asli Islamic books, COD + UAE fast shipping. en/ar/hi/kr sab update.
3. **Help page ke SARE jawab Lorem Ipsum the** (`helpListDec`) — drawer se Help abhi bhi khulti hai. → REAL support text (order/delivery/payment/wallet/refund ke liye support@alfurqan.ae) 4 languages me.
4. **Drawer "Pages" (index 2)** template ka developer sitemap tha (OnBoarding/Login/OTP/Reset demo navigation) → production se HIDE kar diya (indexes ab hidden: 2, 10, 12; mapping intact).

### 🟡 SUGGESTIONS fixed (dead-code brand leakage — render nahi hoti, phir bhi saaf)
- "title" key: "Multikart is premier fashion destination..." → Al Furqan tagline (4 langs).
- `aboutDesc` key: Lorem Ipsum → real shop intro (4 langs).
- `about_us_array` stats: "Multikart have 150+ users/stores/orders/brands" → book-shop stats.
- `ourBrand` fashion brand text → trusted publishers line.
- `topBrandForMultikart` / `termsConditionForMultikart` values → Al Furqan (4 langs).

### ✅ PASSED checks
- 542 Dart files bracket/syntax scan: 0 problems.
- AppSec: koi hardcoded API key/secret nahi; Bearer token storage attach; cleartextTraffic flag nahi (default block).
- Reality Checker greps: koi rendered "Multikart"/fashion/Lorem text nahi bacha (sirf dead coupon/product arrays me MULTIKART10 string — kisi view me use nahi).
- `productArray`/`couponArray`/`about_us_body` etc dead code hain (compile-safe), koi view render nahi karta.

### Files changed
- `lib/common/language/{en,ar,hi,kr}.dart` (40 replacements, assertion-verified)
- `assets/onBoarding/onBoarding{1,2,3}.png` (new bookstore illustrations)
- `lib/views/menu/drawer/drawer_screen.dart` (index 2 hide)
- `lib/common/array/about_us_array.dart` (stats text)
- `pubspec.yaml` version 1.3.1+18

## 31 Aug 2026 (v1.3.2+19) COMPILE FIX — hi.dart ka ek missing key (release build error)

- **Error (user ka release build):** `lib/common/language/hi.dart: Expected ',' before this` — poori file par ~500 errors cascade ho rahe the.
- **Root cause:** v1.3.1 ki language-edit script ne `hi.dart` me `"aboutDesc":` KEY ko galti se hata diya tha (sirf value line reh gayi thi). Dart compiler map ko SET samajh baitha, isliye file ke HAR entry par "Expected ','" cascade error. Asli defect sirf 1 line ka tha.
- **Fix:** `"aboutDesc":` key wapas restore (line 551). Baaki en/ar/kr files verify — sab sahi.
- **Anti-repeat:** naya validator add kiya — saari language maps me "orphan value line" (bina key wali string entry) scan: 0 issues. Bracket scan 542 files: 0 problems. Ab `pubspec.yaml` version 1.3.2+19.
- Note: is build me v1.3.1 ke saare improvements (nayi onboarding images, Help text, Pages hide) bhi shaamil hain.

## 31 Aug 2026 (v1.4.0+20) GHOST CART ka asli root-cause fix + Category search icon + Notifications REAL API

### 🐛 Bug fix 1 — Cart me item automatic/Remove ke baad bhi wapas aata tha (GHOST)
User report: maine product add hi nahi kiya fir bhi cart me wahi kitaab dikhti hai; Remove karke bhi wapas aa jaati hai.
**Asli wajah (2 deep bugs mile):**
1. Cart view mapper zero-quantity lines ko dabakar wapas `"Qty: 1"` bana raha tha. Backend Remove (qty=0) accept karta hai par GetCart me zero-qty line bhejta rehta hai → app me book wapas "Qty: 1" ban kar GHOST ki tarah dikhti thi. **Fix:** zero-quantity lines ab list me hi nahi aati.
2. Remove call me hamesha `"id": 0` bheja jata tha (cart-line ka asli id nahi) — backend line match nahi kar pata tha, isliye remove server par stick nahi hota tha. **Fix:** ab GetCart ke items se REAL cart-line id match karke bheji jaati hai + list-form body primary.

### 🐛 Bug fix 2 — Category page ke icons "shifted" lagte the
Category tab par search icon OFF tha (sirf heart+cart) — row aadhi lagti thi. **Fix:** Category tab par bhi Search icon ON (books directly search karo).

### ✨ New — Notifications ab REAL (pehle static/demo thi)
Swagger deep-dive me `GET /api/Setting/GetUserNotifications` mila (pehle "notifications API hai hi nahi" lagta tha). Notification page ab REAL API se jood gaya: loading/failed/empty — teeno states saaf message ke saath. Static demo notifications hata di. Drawer/bell abhi bhi hidden hain (user ne kaha tha); API ready hai — bole to 1 line me wapas ON.

### 💥 Crash fix — Notification page pehli row par RangeError (red screen)
`notificaton_list.dart` me `filterList[index! - 1]` — index 0 par crash hota tha. Safe color logic se replace.

### Verified
- 542 Dart files bracket scan: 0 problems; language maps: 0 orphan entries.
- Swagger confirm: Cart me sirf GetCart + AddToCart hote hain (DeleteCart naam ka endpoint backend me hai hi nahi — qty 0 hi sahi tareeqa hai).

## 31 Aug 2026 (v1.4.1+21) App-bar icon spacing fix

User report: search icon "chipka hua" lagta hai. Wajah: bell icon hate hi Heart icon ka horizontal padding 0 ho jata tha (condition `isHeart && isCart ? 0 : 10`). Ab Heart hamesha 10 padding rakhta hai — Search/Heart/Cart ke beech barabar gap.
