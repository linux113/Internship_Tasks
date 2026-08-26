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
