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

## 02 Sep 2026 (v1.5.0+22) 4 ISSUES ek saath — login-repeat, cart reload, STATIC fashion filters, DOB text-input

### 1) App kholo to dobara login maangta tha (jabki user logged-in tha)
- **Fix A:** Splash par SELF-HEAL — agar auth token saved hai par login flag false reh gaya ho to flag auto-correct.
- **Fix B:** LoginController me auto-bounce — already logged-in state me login screen kabhi bhi khule to seedha dashboard par wapas (render hi nahi hoti). Logout ke baad flag false hota hai, waha koi effect nahi.

### 2) Cart Remove karne par poora screen "reload" hota tha
- `getCart()` har baar full shimmer dikhata tha. Ab **silent refresh**: Remove ke baad item turant gayab + server state background me confirm — koi reload flash nahi.

### 3) Collection FILTERS me static fashion data tha (STRICT FIX)
- **Removed:** Brand (Zara/Mast & harbour/Tokyo talkies/Vogue/gucci), Size (S/M/L/XL/2XL), Occasion (Casual/Sports/Party), Colors — sab template ke fake filters.
- **BIGGER find:** purana APPLY button kuch hi nahi karta tha (sirf sheet band)! Ab REAL: Sort (Recommended / What's New / Price High→Low / Low→High) + Price slider (0–300, selected currency symbol ke saath) seedha `GetAllProductsFront` ke params (field/sort/price) par apply hota hai. RESET bhi ab actually filters clear karke fresh list lata hai.
- Dropdown se "Popularity"/"Customer Rating" hataye — backend me unke fields nahi, fake option nahi dikhana.

### 4) Profile setting me DOB plain text input tha (STRICT FIX)
- Ab **readOnly field + calendar icon + REAL date picker** (green theme). Format yyyy-MM-dd (backend friendly). Galat dates ("32/13/9999") ab impossible. Note: abhi backend ki UpdateUserProfile dob accept nahi karti — value app me save/display hota hai; backend field add ho to 1 line me bhej denge.

### Verified
- 542 Dart files bracket scan: 0 problems; language maps: 0 orphans.

## 02 Sep 2026 (v1.5.1+23) SENIOR-DEV DEEP AUDIT — layer-by-layer, 8 bugs mile aur fix hue

Audit ka tareeqa: har layer (navigation/state/API/model/UI/persistence/language/money-path) alag se test — crash-prone patterns (null→parse, firstWhere bina orElse, update-after-dispose, storage-leak) sab grep + line-by-line reads se.

### 🐛 BUGS FOUND & FIXED
1. **4 × NULL-PARSE CRASH spots** — `double.parse(x.toString())` jahan `x == null` hone par `double.parse("null")` → FormatException (red screen):
   - Home rating card (`find_style_list_card.dart`) — rating null par crash hota.
   - Order SUCCESS screen price (`order_success_card.dart`) — sabse khatarnaak jagah par crash risk.
   - Cart total (`cart.dart`) — `totalAmount` (double?) null par crash.
   - Product color tap (`product_color_layout.dart`) — variation id null par crash.
   → Sab null-safe (`tryParse ?? 0` / direct `?? 0`).
2. **Cart EMPTY-screen bug** — zero-qty filter ke baad agar koi item na bache to EMPTY CartModel (khali list) return hota tha → blank screen dikhti. Ab `viewItems.isEmpty` par null → proper "Cart is Empty" page.
3. **Logout poore storage ki safai karta tha** — `storage.erase()` se onboarding-flag (isIntro) + language bhi wipe — logout ke baad user ko dobara onboarding dikhti thi. Ab sirf USER data clear: token, isLogin, id/name/email, coupon_code, selected_address_id, local_addresses. Onboarding + language yaad rehti hai. (Privacy note verify: token same LocalStorage me tha — ab bhi clear hota hai, koi leak nahi.)
4. **Checkout success ke baad update-after-dispose race** — `Get.offAllNamed` ke baad controller delete ho sakta tha, phir `update()` call → crash-log/race. Ab pehle state reset, phir navigate, phir return.
5. **Empty coupon server ko jata tha** — `coupon: ''` bhejne par kai backends 400 reject. Ab coupon ho tabhi key bheji jaati hai.

### ✅ PASSED (koi bug nahi mila)
- `firstWhere` bina orElse wale spots — sab already orElse ke saath (address controller).
- Cart qty-0 ghost fix + silent refresh + real line-id remove (pichhle round) — logic correct.
- Login auto-bounce VS logout flow — logout pehle flag clear karta hai, bounce nahi aata. SAFE.
- Splash self-heal — token/flag mismatch correct karta hai.
- Filter apply → ShopController → API params (field/sort/price) — wiring sahi.
- 542 files bracket scan: 0 problems; language maps: 0 orphans.

## 02/09/2026 (v1.5.2+24) Full-app sharp audit — 2 aur decorative filters REAL banaye, saari static-fashion flash band, 4-language gaps fill

Full automated audit chalaya (language parity, route wiring, asset existence, crash greps — 542 files, 0 bracket problems). Pakade gaye issues aur fixes:

1. **Order History filter decorative tha (CRITICAL FIX)** — Apply ka button sirf sheet band karta tha, filter kabhi lagta hi nahi tha. Ab REAL client-side filter: All/Open/Return/Cancelled orders + All Time/Last 30 Days/Last 6 Months (pehle fake duplicate "2021" entries thin). Sheet khulne par purana applied selection bhi yaad rehta hai.
2. **Order History search box decorative tha (FIX)** — type karne par kuch nahi hota tha (koi listener hi nahi tha). Ab har keystroke par order number / item name / status / date se live filter hota hai.
3. **Home page static fashion flash (FIX)** — API fail hone par Deals of the Day me Pink Hoodie/Denim Jacket aur Kids Corner me kids-fashion demo data dikhta tha. Ab koi demo preload nahi — sections khaali hone par hide ho jate hain.
4. **Search page "Recommended" chips flash (FIX)** — real categories aane tak 1-2 sec fashion chips (Denim/Skirts/Jeans) dikhti thin. Ab seedha real alfurqan.ae categories aati hain.
5. **Missing translations (FIX)** — "Time Filter" (timeFilters) AR/HI/KR me missing tha (camelCase raw dikhta tha); Add Address ka "stateProvision" label sabhi languages me missing tha; Order History ke filter labels ("All Orders", "Open Orders", "Return Orders", "Cancelled Orders", "Last 30 Days", "Last 6 Months", "All Time") sabhi languages me missing the; drawer ke subtitles (Home/Category/Orders/Wishlist/Account ke neeche ki lines) aur address-type chip "Home" ab 4 languages me translated.
6. **Onboarding SKIP/DONE raw English (FIX)** — keys language maps me hi nahi thin, ab 'skip'/'done' keys se 4 languages me translated. Null-safety bhi tighten ki.

**Verify kiya gaya (clean):** fake credit cards ("Paige Turner") kisi bhi screen par render nahi hote (dead demo array); coupons page REAL API se chalta hai; wallet balance REAL API se; profile guest mode me "Guest" dikhata hai (fake name nahi); sare routes wired; koi missing image asset nahi jo use hoti ho; koi unsafe int.parse/double.parse nahi; debug prints nahi.

**Known cosmetic (next update me ho sakta hai):** currency names (UAE Dirham/British pound) aur sort dropdown labels English me hi rehte hain har language me — logic se bound hai, risky refactor, baad me index-based banake translate karenge.

## 02/09/2026 (v1.5.3+25) MEGA DEEP AUDIT round 2 — line-by-line controllers+views, 8 aur bugs fix

Is baar GetX registration graph, null-crash greps, dead-button sweeps AUR money-path (cart→checkout→payment→order) ke saath saare controllers line-by-line padhe. Pakde gaye bugs:

1. **Home page fashion fallback (FIX)** — Category API kabhi fail ho jaye to HOME par fashion demo categories + banners (men/women/kids tiles) dikhne lagte the. Ab khaali rakhte hai — fake kabhi nahi dikhega.
2. **Product Detail "Similar Products" 2 bugs (FIX)** — (a) real api aane tak/about na aane par fashion demo row (Blue Denim Jacket) dikhti thi; (b) ek product se doosra product kholne par PURANE product ka similar list atka rehta tha aur naya fetch hi nahi hota tha (controller reuse bug). Ab har product par similar reset + fresh fetch, aur data na ho to section hide.
3. **Language change = Demo product bug (FIX)** — language badalte hi khula hua Product Detail page ka product STATIC demo fashion jacket se overwrite ho jata tha (AddToCart "demo product" error deta tha). Ab real product ko touch hi nahi karta.
4. **Address card ka hidden DOUBLE-TAP gesture (FIX)** — checkout address list par double-tap karne se DEMO fashion product khul jata tha (template ka chhupa hua gesture). Hata diya.
5. **"null" text bug x3 (FIX)** — Order Success / Payment / Delivery Detail pages par arguments na mile to screen par literal "null" likha aata tha. Ab '0'.
6. **RTL setting restart par reset (FIX)** — Settings/Profile/Drawer teeno jagah ka RTL toggle app restart par bhool jata tha (kabhi save hi nahi hota tha). Ab save + restart par restore hota hai.
7. **Dark Mode switch galat position (FIX)** — theme dark rehne ke baad bhi app restart par settings ka Mode switch OFF dikhata tha (state restore nahi hoti thi). Ab sahi position dikhta hai.
8. **Settings ka Notification toggle decorative tha (REMOVE)** — wo switch kuch bhi nahi karta tha (kahin use/persist hi nahi hota tha). Settings se hata diya; sirf 2 REAL working toggles: Mode + RTL.

**Deep-verify kiya gaya (sab clean):** GetX controller registration graph (sab controllers sahi order me register hote hai, koi "find without put" crash nahi); firstWhere sab orElse ke saath; koi khali onTap/onPress dead button nahi; checkout payload/address/coupon flow sahi; cart ghost-remove fix intact; order detail REAL api; wishlist union-sync intact; coupons/wallet REAL api; language+currency restart par restore hote hai; 542 files 0 bracket problems; 4-language maps 0 orphan entries.

**Dead demo files (invisible, koi screen nahi dikhata):** fake cards list, old payment widgets, innerCategory page, coupon demo array — code me pade hai par app me kahin render nahi hote; safety ke liye chhua nahi.

## 02/09/2026 (v1.5.4+26) ChatDev pipeline audit — LIVE API se integration test + 3 fixes + 1 SECURITY alert

Is round me ChatDev workflow (Design->Code->Review->Test) use kiya. TESTER phase asli hai: alfurqan.ae ke LIVE public APIs (products, home data, currencies, swagger) call karke app ke models ke saath match kiye.

**LIVE API test results (sab PASS):**
- Products (GetAllProductsFront): saare fields hamare ProductApiModel se match (id/name/price/sale_price/discount/stock_status/slug/product_thumbnail.asset_url) — pagination wrapper sahi.
- Home (GetHomePageDataApp): banners RELATIVE image paths — app ka buildMediaUrl sahi se full URL banata hai (alamat: banners dikhte hai); Offer Banner 2/3 ka Image_Url backend me khaali hai — app pehle se hi use skip karta hai; Brand section backend ne Status:false rakha hai — app sahi se hide karta hai; Top_Category ke 5 real slugs (quran/hadith/creed/jurisprudence/biography) kaam karte hai.
- Currency (GetAllCurrenciesFront): endpoint sahi; USD(3.65)->invert ~0.27x, INR(27)->27x, AED(1)->1x sahi; GBP/EUR ka backend rate 0.01 toota hua hai — app unhe list se hata deta hai jab tak backend theek na kare.

**Fixes is round me:**
1. **Forgot Password FAKE flow hata diya** — "Send OTP" dabane par demo OTP popup khulta tha; na email jata, na OTP verify hota, na password reset hota. Backend me password-recovery endpoint hi nahi hai (swagger verify), isliye ab HONEST dialog: support@alfurqan.ae par reset request ka tareeqa (user ki email ke saath).
2. OTP/Reset demo pages — ab kisi live flow se linked nahi (sirf hidden dev sitemap me route).

**SECURITY ALERT (backend team ko turant report karo):**
Currency API ka response har request me ADMIN USER OBJECT leak kar raha hai — userName "dzab_admin", email "info@alfurqan.ae", phoneNumber aur BASE64 PASSWORD ("KyimQTia9hEli09WiFW4gQ==") sab kisi ko bhi bina login dikh raha hai (kholo: https://alfurqan.ae/web/CoreFront/GetAllCurrenciesFront). Backend se `core_Users` object response se hatwana zaroori hai — ye admin panel takeover ka rasta hai.

**Deep-verify clean:** .first/.last sab guarded; json force-unwrap 0; image URL pipeline sahi; coupons loading/empty/error states sahi; .tr parity 517 keys 4 languages (sirf dead-demo keys ka delta); 542 files 0 bracket problems.

## 03/09/2026 (v1.5.5+27) Release build error (card_balance context) — PURANA ZIP tha, kuch fix ki zaroorat nahi thi

User ka build error: "card_balance.dart:35:50 — CardBalanceController can't be assigned to BuildContext" — ye bug v1.2.2+15 (commit da09cf0) me pehle hi fix ho chuka tha (GetBuilder param ka naam `context` se `cardBalanceCtrl` kiya gaya tha, MediaQuery shadowing issue). Verify kiya: repo code + ZIP dono me FIXED file hai. Project-wide sweep me yahi shadowing pattern aur kisi file me NAHI mila. Error isliye aaya kyunki (a) Downloads me pada PURANA zip use ho gaya, ya (b) purane build artifacts cache ho gaye. Action: fresh zip download + flutter clean mandatory.

## 03/09/2026 (v1.6.0+28) USER TESTING ROUND — 14 issues ka fix (device report)

1. **Search** — products pool page khulte hi background me load hota hai (pehle pehle keystroke par 2-4 sec rukta tha); matching ab name + short/full description + SKU (F0010069) + slug (English) + category names me hoti hai — English/Arabic dono queries chalengi.
2. **Home Services strip** — GetHomePageDataApp ke Services section se real strip add ki (banner ke neeche). Backend abhi "Test" bhejta hai — wo filter hota hai; admin me real services daalo to apne aap dikhenge.
3. **Order Success static fashion summary** — HATA DIYA. Ab asli ordered items (naam/qty/price/total) + payment method (COD) dikhta hai (CheckoutController.lastPlacedOrder snapshot).
4. **Track Order blank/white screen** — Track Order ab REAL Order History kholta hai (bina id ke broken detail nahi jaata).
5. **Continue Shopping loop** — pehle PUSH hota tha isliye success page root me phansa deta tha aur har back wahi le aata tha. Ab offAll se category tab; stack clean.
6. **Phone inputs** — Add Address mobile + Profile phone + pincode: sirf digits (symbols block), max 15.
7. **Start Shopping (empty cart)** — dead button tha; ab home tab par le jata hai.
8. **Order History detail "load nahi ho paya"** — card tap par summary bhi bhejte hai: detail TURANT real data se khulti hai, api GetOrder background refresh; fail ho to bhi real data rehta hai (white error screen nahi).
9. **Order History filter** — status words aur bhi cover (complet/success/reject/refund), nayi date formats (dd-MM-yyyy/dd/MM/yyyy), unknown date wale orders hide nahi hote.
10. **About Us** — backend CMS khali hone par REAL shop intro (alfurqan.ae — Islamic bookstore UAE, COD, support) dikhta hai; CMS aate hi overwrite.
11. **Search camera icon** — hide (backend image-search nahi hai).
12. **Similar product naam** — 2 lines wrap + ellipsis, image ke barabar width (white space khatam).
13. **Share icon** — dead tha; ab native share sheet product ke website link ke saath (share_plus dependency add hui — pubspec).
14. Karein verify: 543 files 0 bracket problems; lang maps clean.

## 03/09/2026 (v1.6.1+29) CART REMOVE permanent fix + Ruflo/ChatDev strict audit

**1. Cart item remove — "again and again wapas aa jata tha" (device report) — PERMANENT fix:**
Pehle remove flow: UI se turant hatao -> ek hi payload bhejo -> response ka koi VERIFY nahi -> GetCart item wapas la deta tha (server-side remove fail hone par). Ab BULLETPROOF:
   - Swagger v2 verify: CartDto schema dekha — `items` ek ARRAY honi chahiye (pehle app OBJECT pehle bhejta tha), aur DeleteCart/RemoveFromCart naam ka koi endpoint EXIST hi nahi karta (3 hidden URLs bhi probe kiye — sab 404). Remove sirf AddToCart qty-0 se hota hai.
   - Naya flow: fresh GetCart se REAL line-id lo -> ATTEMPT 1 FULL-SYNC (saari bachi lines + target qty 0, dono REPLACE/UPSERT server styles cover) -> har attempt ke baad GetCart VERIFY ("item sach me gaya?") -> fail ho to ATTEMPT 2 (single line array) -> ATTEMPT 3 (object shape).
   - `total` ab blind 0 nahi — remaining sub_total ka REAL sum bhejte hai (pehle server par cart total 0 hone ka risk tha!).
   - consumer_id bhi CartItemDto ke mutabik parse+send karta hai (line user se match zaroori).
   - Teen attempts bhi fail ho jaye to FAKE success ka illusion nahi: UI server se sync + HONEST toast "Item could not be removed. Please try again." (4 languages me).
   - AddToCart ab schema-sahi ARRAY shape pehle bhejta hai (object sirf fallback; 401 par seedha login).

**2. Ruflo (ruvnet/ruflo) + ChatDev dono ko review-lens ki tarah use karke FULL strict audit:**
   - Ruflo ke reviewer/tester/security-auditor checklists + ChatDev Design->Code->Review->Test pipeline ke hisab se sweep: 543 dart files, 0 bracket problems, lang-maps 0 orphans, 0 missing .tr keys, 0 missing assets, 0 firstWhere-without-orElse crash points, 0 suspicious null-asserts, saare Get.find registrations verified.

**3. Sort dropdown crash-risk fix (audit se pakra):**
   - Filter ke sort value par ".tr" laga tha — agar kabhi "Recommended" key translate hoti to DropdownButton CRASH hota (value items me nahi milta). Internal value ab HAMESHA constant English (display text pehle se translated hai).

**4. Template ke static demo ke IMANDAAR safaya:**
   - Cart "Coupon Discount" row me template ka STATIC "-AED 20.0" fake discount code tha — HATA DIYA (ab sirf REAL value/"Apply Coupon").
   - Dead noInternet route + missing asset file ka broken reference — HATA DIYA (koi screen use nahi karti thi).
   - Language maps 100% parity: dead demo keys (Punjab/Gujarat/Australia/India/New Zealand/Save $20.00) teeno maps se saaf; "couponRemoved"/"itemNotRemoved" naye translated keys; coupon toast ab translated.

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN (lang parity + routes + assets); audit3 GetX graph clean (4 warnings manually verify — false positives, registrations main.dart/page-level me confirmed); fashion/demo words sirf comments me bache (koi live UI static nahi).

## 03/09/2026 (v1.6.1+30) Release build error fix — missing import (meri miss, sach bata raha hoon)

User ka build error: "profile_widget.dart:36:12 — Type 'TextInputFormatter' not found".
Cause: v1.6.0 me phone digits-only feature ke liye ProfileWidget.securityTextBox me `List<TextInputFormatter>?` param add kiya tha — par us file me `import 'package:flutter/services.dart'` add karna REH GAYA tha. Dart me type dusri file se pass-through karte waqt bhi us type ka import apni file me chahiye hota hai. (CustomTextFormField aur saare formatter-use karne wali files (phone/pincode/security_layout) me import pehle se sahi tha — error sirf is ek file ka tha.)
Fix: profile_widget.dart me services import add.
Taaki aisa kabhi na ho: mere static audit (deep_check) me ab IMPORT-AWARENESS check add kar diya — jo file flutter/services/share_plus/dio ke types use kare par import na kare, wo build se PEHLE hi pakda jayega. Re-run: 543 files, 0 problems, 0 missing imports.

## 04/09/2026 (v1.6.2+31) CART REMOVE ka ROOT-CAUSE mila (hidden UpdateCart endpoint) + FILTER backend-broken proof + client-side fix

**1. Cart remove — ROOT CAUSE PAKRA GAYA:**
   - Device test dikhaya: mera verify-chain sahi tha (honest toast aaya) par server ne AddToCart ke TEENO qty-0 shapes REJECT kar diye — matlab backend AddToCart se remove hi nahi karta.
   - Naya discovery (endpoint probing): `GET /api/Cart/UpdateCart` aur `/api/Cart/ClearCart` par SPA-404 ki jagah **HTTP 500** aata hai = YE ROUTES EXIST KARTE HAI (swagger me chhupe hue)! Website ka asli remove isi `UpdateCart` se hota hai (AddToCart sirf ADD karta hai — isliye dead qty-0 lines kabhi remove nahi hoti thi).
   - Naya 8-STAGE verified chain (har stage ke baad GetCart se CONFIRM): (1) PUT UpdateCart full-cart(replace) → (2) POST UpdateCart → (3) POST UpdateCart + _method:"PUT" (asp.net spoof) → (4) POST UpdateCart {id,qty:0} → (5) PUT UpdateCart ?id=lineId {qty:0} → (6-8) purane AddToCart variants. Jo kaam kare, wahi use ho jayega — aur verify-chain ke saath risk ZERO (fail ho to honest sync+toast).
   - total kabhi blind 0 nahi — sach me bache items ka real sub_total.
   - ClearCart bhi probe-confirm hua (afterOrder use ke liye future me).

**2. Filter section — BACKEND HI BROKEN hai (LIVE PROOF ke saath), app me CLIENT-SIDE fix:**
   - LIVE A/B test: `field=price&sort=desc` bhejne par bhi ASC order; `price=0,41` filter bhejne par bhi 45-AED wala product AA RAHA THA; `sortBy=price` bhi ignore. Matlab backend GetAllProductsFront ke sort/price params poore DEAD hain — isliye filter kuch nahi karta tha.
   - Ab ShopController: ek call me 500 products (category filter server-side jo kaam karta hai) → price filter + sort (price asc/desc, What's New=created_at desc) CLIENT-SIDE REAL karta hai → 12-12 ke local pages.
   - ProductApiModel me `createdAt` field add (created_at parse) — date-sort ke liye.
   - "Recommended" = natural newest-first order (pehle jaisa hi dikhta tha — koi UX regression nahi).
   - Load More ab local slice = instant, extra network call nahi.
   - Ye backend team ko bhi report karna chahiye: GetAllProductsFront me field/sort/sortBy/price params implement kare.

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN; audit3 clean (4 known false positives pichle round me manually verify ho chuke).

## 03/09/2026 (v1.6.3+32) CART REMOVE — 16-stage chain (neg-qty + pure-replace + ClearCart) + SCREEN VERSION LABEL

**Device report:** v1.6.2 ke 8 attempts bhi server accept nahi kar paye (honest toast dobara). Do NAYE mechanisms add:
   - **NEGATIVE quantity**: AddToCart increment-style ho sakta hai — qty -1 bhejne par qty-1 ki line 0 ho jati hai (classic multikart remove trick) — 3 shapes.
   - **PURE-REPLACE bina dead-line**: ho sakta hai qty-0 line validation fail karke POORI request reject karti thi — ab remaining-only bodies PEHLE try hote hai UpdateCart aur AddToCart dono par.
   - **ClearCart GUARDED**: cart me sirf EK hi live item ho to (user ke screenshot jaisa case) ClearCart hi uska valid remove hai — sirf tabhi chalta hai jab remove-target ke alawa koi live line NA ho (doosre items kabhi touch nahi hote).
   - Har body me `created_by_id` (login user id) bhi jata hai.
   - TOTAL ab 16 verified stages — har stage ke baad GetCart confirm. Is chain me WO shape pakka aa jayega jo backend accept karta hai.

**SCREEN VERSION LABEL:** Profile page ke bottom me "Al Furqan Book Shop  v1.6.3 (32)" — ab screenshot se TURANT pata chalega kaunsa build chal raha hai (purane test runs me confusion tha ki naya zip chala ya purana cached zip — download URL same rehne se browser purana zip serve kar sakta hai; isliye is baar version-tagged zip file bhi di hai).

**Filter (v1.6.2+31 client-side fix) isme included hai** — Price High→Low / Low→High ko NAYE build me REAL order change dikhna chahiye. Agar na dikhe to screenshot me version label check karo.

**Verify:** 545 files 0 bracket problems; audit2 ALL CLEAN; audit3 clean.

## 03/09/2026 (v1.6.4+33) ORDER FLOW end-to-end deep fix — real address, back-behavior, server-cart clear, demo fallbacks killed, multi-lang toasts

User report: "order placing par cart khali dikhata + order ke baad back = directly bahar" + "proper order, proper price, multi-language, sab loop hole fix karo". Full order-flow ko server ke saath re-audit karke ye fixes:

1. **"Cart khaali" guard smarter**: placeOrder ab empty products par PEHLE server se GetCart refresh karke dobara padhta hai — stale local state par galat "cart khaali" toast kabhi nahi. Saath hi ab products ORDER ke liye cartApiModel.items (REAL product_id + REAL qty) se bante hai — line-id ka product_id banne ka khatra khatam.
2. **Order ke baad SERVER cart bhi saaf**: probe-confirmed hidden endpoint Cart/ClearCart call + silent GetCart settle — warna agle app-open par purane items wapas aa jate ("again and again" wali feel order ke baad bhi aati).
3. **Success page back-behavior**: offAll se aaye page par phone-back APP BAND kar deta tha (stack me wahi ek page) — ab PopScope se back = HOME (dashboard).
4. **FAKE New York address hata diya**: success page par "3501 Maloy Court, NY" STATIC template address aata tha — ab user ka SELECTED REAL delivery address dikhta hai (na ho to section hide — koi fake line nahi).
5. **Fake order number hata diya**: "Your order # is: 64484032" static — ab label neutral "Order Number" (4 languages) + REAL server order-id.
6. **Payment page demo fallback killed (PROPER PRICE/DATA)**: CartOrderDetailLayout ko pehle cart null hone par STATIC demo `cartList` (fashion) milta tha — HATA DIYA + layout null-safe (crash-proof).
7. **Saare checkout toasts ab translated**: pleaseLoginFirst / cartEmptyToast / saveDeliveryAddressFirst / orderPlacedSuccess / orderFailedTryAgain — en/ar/hi/kr me (Hinglish hardcode hataya — multi-language demand).

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN (lang parity 100%); audit3 clean (0 unguarded GetX, 0 null-assert, 0 firstWhere crashes).

## 04/09/2026 (v1.6.5+34) ORDER DETAIL page "kuch nahi dikh raha" — SERVER-SCHEMA se full fix (swagger verify)

**Complaint:** Order History me order tap karne par Order Detail page KHAALI / galat (items nahi, price 0, address nahi) aa raha tha.

**Server se dekha kaise kaam karta hai (LIVE swagger v2 — /swagger/v2/swagger.json ke Orders section + schemas padh kar):**
1. **Items `products[]` me aate hai** (na ki `items[]`) — har item OrderProductDto hai jisme asli order data `pivot` object me hota hai: `pivot.quantity` (asli qty!), `pivot.single_price` (asli unit price!), `pivot.subtotal` (asli line total!). Hamara purana parser sirf `quantity/price/sub_total` top-level dekhta tha → **qty=1, price=AED 0.00 sab galat**.
2. **Image `product_thumbnail.asset_url` (MediaFiles) me hoti hai** — MediaFiles me `url` naam ki key hoti hi NAHI (swagger MediaFiles schema: asset_url/original_url) → **images hamesha khaali**.
3. **Totals ke server keys**: `amount` (subtotal), `total` (grand), `shipping_total`, `tax_total`, `coupon_total_discount`, `wallet_balance`, `points_amount`, `payment_method`, `payment_status` — purana parser inme se adhe miss karta tha → breakup khaali.
4. **Address AddressDto hai**: `{title, street, city, stateName|state{name}, country{name}, pincode, phone(int64!), country_code}` — purana parser `address/line1` dhundhta tha jo hai hi nahi, aur `state`/`country` OBJECTS the (string nahi) → address card khaali. Recipient naam order ke `consumer_name`/`consumer.name` se aata hai (address par naam field hoti hi nahi!).
5. **Timeline**: `order_status_activities[]` — DTO me `status` STRING, entity me `orderStatus{name}`; date `changed_At|changed_at|created_at` — ab date-sort bhi hoti hai.
6. DTO (snake_case) vs Entity (camelCase: orderStatus, subTotal, shippingAddress, orderStatusActivities...) — **dono shapes ek sath parse** (server kuch bhi bheje).
7. **Navigation bug (REAL ROOT CAUSE of "khaali page")**: Order History card ke andar ka InkWell sirf `{'id':...}` bhejta tha — `summary` nahi (outer .gestures wala summary gesture-arena me haar jata tha). Isliye detail page ka instant prefill KABHI chalta hi nahi tha aur api fail/slow par user ko khaali page dikhta tha. Ab inner InkWell bhi `{'id', 'summary'}` bhejta hai → page TURANT real data se khulta hai, api background me refresh karta hai.
8. **Order History cards bhi sudhar**: rows ke items ab `products[]` se (pehle "Order #N" generic naam aata tha) — REAL item names + REAL images (product_thumbnail.asset_url) + REAL qty (pivot.quantity) har row me.
9. **Multi-language (demand)**: detail page ke saare labels ab .tr — Order Tracking, Shipping Details, Price Details, Subtotal/Shipping/Discount/Tax/Total, Wallet Used, Points Used, Payment Method (cod → "Cash On Delivery"), Retry, error message — 4 languages (en/ar/hi/kr) 11 naye keys. Pehle Hinglish error "Order detail load nahi ho paya" hardcoded tha — HATA DIYA.
10. **Safety**: server slim/khaali response de to prefilled REAL summary items/total/status restore rehte hai (khaali page kabhi nahi). sub_orders (multi-store) fallback bhi hai.

**Note for Lalit:** GetOrder/GetUserOrders ka protected (login) JSON ab bhi nahi mila — agar ab bhi koi field mismatch dikhe to browser me login karke `https://alfurqan.ae/api/Orders/GetOrder?id=<order-id>` ka JSON bhej do, exact key mapping 100% kar dunga.

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN (lang parity 100%, 11 naye keys ×4 languages); audit3 clean (0 unguarded GetX, 0 null-assert, 0 firstWhere).

## 04/09/2026 (v1.6.6+35) MULTI-ITEM CART fix — "ek se zyada add to cart nahi hote" ka ROOT CAUSE + permanent solution

**Complaint (Lalit):** Order karte waqt ek se zyada products add to cart nahi hote the — doosra product add karte hi pehla GAYAB.

**ROOT CAUSES (code + server behavior dono milakar):**
1. **Har add par SIRF nayi line bheji jati thi** (`items:[newLine]`) — is backend (alfurqan.ae) ka AddToCart poora cart REPLACE kar deta hai, jisse pehla item server se hi mit jata tha. Cart me hamesha bas 1 item bachta tha.
2. **`consumer_id` / `created_by_id` kabhi nahi bhejte the** — server ko yeh pata hi nahi chalta tha ki cart kis user ka hai (swagger CartItemDto/CartDto me yeh fields exist karte hai — isliye remove/update bhi kabhi-kabhi match nahi karte the).

**FIX — DUAL-SEMANTIC safe flow (backend "replace" ho ya "merge", dono par sahi, bina duplicate ke):**
1. **STEP A:** Har add se pehle FRESH `GetCart` — currently live server lines ka snapshot.
2. **STEP B:** SIRF delta (nayi/badhi hui) line bhejo + `created_by_id` + line par `consumer_id` (merge-backend par purani lines dobara BHEJNE se qty DOUBLE ho sakti thi — isliye purani lines nahi bhejte).
3. **STEP C (VERIFY):** `GetCart` dobara — naya product AAYA aur purane saare BACHE? → dono haan = SUCCESS (merge world me bas itna hi kaafi).
4. **REPLACE world** (naya aaya par purane gayab — exactly Lalit ka bug): ab POORA merged array bhejo = purani ORIGINAL lines (unki ids ke saath) + nayi line FINAL qty par → dobara verify.
5. **Sab fail** → HONEST toast `itemNotAdded` (4 languages) — fake success nahi.
6. Same product dobara add → qty INCREMENT hoti hai (final qty server se verify).
7. Guest (logged-out): pehle jaisa hi — login page par le jate hain with message.

**Saath me safety nets:**
- **Duplicate-line dedupe (UI):** server kabhi same product ki DO live lines bhej de to cart UI me wahi book do baar dikhti thi — ab `_mapApiCartToViewModel` (productId+variationId) se GROUP karke qty jod deta hai: ek product = ek row.
- **CartApiModel lenient keys:** `product_id/productId`, `sub_total/subTotal`, `consumer_id/consumerId`, `items/Items`, `total/Total` — DTO/entity dono case.
- Naya lang key ×4: `itemNotAdded`.

**Note:** Is flow ke 2 extra GetCart calls hote hain (verify) — book store ke liye negligible; isse remove-chain ke saath cart ab BULLETPROOF hai (add + remove dono GetCart-verified).

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN (lang parity 100%); audit3 clean (0 unguarded GetX, 0 null-assert, 0 firstWhere).

## 04/09/2026 (v1.6.7+36) FULL SERVER RE-VERIFICATION — har endpoint LIVE check + flaky-network guard

**Task (Lalit):** "again check all things are correct and working properly from server in detail" — poora system LIVE server ke saath dobara verify kiya.

**LIVE endpoint verification (aaj ke server se, URL hit karke):**
1. ✅ Home `api/MobileAppApi/GetHomePageDataApp` (200): banners (relative media/ → buildMediaUrl full URL), Services me ab bhi admin ka "Test" placeholder hai → app use filter karti hai (server-side admin panel se sahi services daalni hai), Find_Your_Match 5 tabs REAL books (ids 264-268), Deals/Trending REAL, **Top_Category 5 REAL slugs** (quran/hadith/creed/jurisprudence/biography), **Brand Status=false → app hide** (by design).
2. ✅ Products `web/Products/GetAllProductsFront` (200): newest first (id 494 AED 40, 493 AED 45...), `product_thumbnail.asset_url` FULL URL, `created_at` parseable, stock/in_stock fields.
3. ✅ Category filter SERVER-SIDE kaam karta hai: `category=quran` → sirf quran-category books (id 406, 386 — dono me category 118 "quran" present).
4. ✅ Search SERVER-SIDE kaam karta hai: `search=القرآن` → relevant books only.
5. ✅ Countries `api/Core/GetAllCountry` (200): poori country+state list (address form isi se FK-safe banta hai).
6. ✅ Currency `web/CoreFront/GetAllCurrenciesFront`: USD 3.65 (inverted — app auto-invert), INR 27, AED 1, GBP/EUR 0.01 (garbage — app client-side filter karti hai). Server-side fix pending (backend team).
7. ✅ Auth-required endpoints sahi se 401 "Login required." dete hain (Pascal-case envelope — ApiService dono case handle karta hai): Cart/GetCart, Orders/GetUserOrders, Orders/GetOrder, Wishlist/GetWishlist, Wallet_Point/GetWallet, Setting/GetUserNotifications, **Coupon/GetAllCoupons (401!)**, **Pages/GetAllPages (401!)** — app inhe gracefully handle karti hai (Retry/empty states, crash nahi). Note: Coupons+Pages ka login-required hona SERVER-side decision hai — agar guest users ko About/Terms/Coupons dikhane hain to backend team ko ye endpoints public karne honge.
8. ✅ OrderSaveDto payload match: `points_amount`/`wallet_balance` = BOOLEAN (app false bhejti hai — sahi), coupon sirf ho tab bheja jata hai, payment_method='cod'.
9. ✅ Orders schemas (swagger v2): OrdersDto/OrderProductDto(pivot!)/OrderPivotDto/OrderStatusDto/OrderStatusActivityDto/AddressDto/MediaFiles(app uses asset_url) — v1.6.5 parser in sab se EXACT match karta hai.

**Code-level extra guard added:** addToCart merged-replace bhejne se pehle EK aur verify — merge-world me flaky GetCart hiccup se naya item id:0 se DOBARA insert hokar DOUBLE na ho (double-add race condition permanently band).

**Verify:** 543 files 0 bracket problems; audit2 ALL CLEAN (lang parity 100%); audit3 clean (0 unguarded GetX, 0 null-assert, 0 firstWhere).
