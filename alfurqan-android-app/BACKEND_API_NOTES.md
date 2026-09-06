# AL FURQAN BOOK SHOP — App ↔ Backend API Notes (06/09/2026)

Backend team ke liye (Entwino) — app abhi kaunsa request kounse endpoint
par bhejta hai, kya observe kiya, aur kya improvements chahiye.

---

## 1) Aapka sawaal: "Add to Cart ka current interface batao" ✅

**Endpoint:** `POST {base}/api/Cart/AddToCart` (Bearer token)

**Jo app abhi bhejta hai** (har add-to-cart par):

```json
{
  "items": [
    {
      "product_id": 264,
      "variation_id": null,
      "quantity": 2,
      "consumer_id": 81,
      "created_by_id": 81,
      "sub_total": 130.0,
      "wholesale_price": 0
    }
  ]
}
```

**⚠️ Sabse zaroori baat (live-tested):** is server ka AddToCart **poora
cart REPLACE** karta hai — sirf nayi line bhejne par purani lines DELETE
ho jaati hain (user ka "ek se zyada item add nahi hote" bug isi ne banaya
tha). Isliye app ab har baar **poori merged items array** bhejta hai,
phir GetCart se verify karta hai.

**App ko aage ke liye chahiye (any ONE kaafi hai):**
1. Ya to per-line **append** endpoint (sirf `{product_id, variation_id,
   quantity}` — baqi cart untouched rahe), **ya**
2. Confirm kar do ki AddToCart hamesha full-replace hi karega, taki hum
   yahi flow rakhen (abhi app dono semantics handle karta hai).

**Aur cart endpoints ko swagger me officially laa do** (abhi hidden hai,
probe se mile — kaam karte hai):
- `Cart/UpdateCart` (qty change / line remove)
- `Cart/ClearCart` (order place hone ke baad clear)

DTO se app sirf ye fields USE karta hai: `product_id, variation_id,
quantity` (per line) + `consumer_id/created_by_id` (user ki id).
`sub_total, wholesale_price` hum server ke snapshot se echo karte hai —
agar zaroori nahi to hata sakte ho, app bina inke bhi bhej lega.

---

## 2) 06/09 ko diye gaye naye endpoints — app me INTEGRATE ho gaye ✅

| Endpoint | App me use |
|---|---|
| `GET Orders/GetOrder?id=` | Order detail page (pehle se) |
| `GET Orders/GetOrderStatus` | **NEW v1.6.9** — dynamic status flow (order detail timeline) + history filter ka "Status" dropdown ab isi se |
| `POST Orders/CheckOut` | **NEW v1.6.9** — payment screen ka grand total server se confirm + place-order se pehle preview |
| `POST Orders/OrderPlace` | Final order place (pehle se) |
| `GET Coupon/GetAllCoupons` | Coupons page (params optional rakhe — app bina params bhejta hai) |

Note: ye endpoints `alfurqan.ae/api` par bhi maujood hain (401 login-
required = route exists), isliye app alfurqan.ae se hi chal raha hai.

---

## 3) entwino.in par switch? — LIVE probe ka result ⚠️

Humne 06/09 ko live check kiya:

| Check | entwino.in ka result |
|---|---|
| `GetHomePageDataApp` | `{"slug":"jewellery_three","contentApp":{}}` — **khaali home** |
| `GetAllCurrenciesFront` | sirf USD (rate 95!) aur INR (1.00) — **AED currency hai hi nahi** |
| `GetAllProductsFront` | **Computer parts** (SMPS Power Supply, HDD — "Entwino" brand) |

Matlab entwino.in = aapka apna alag/demo store hai — Al Furqan ka data
(books, banners, categories, orders, AED) wahan nahi hai. App wahan
point karte hi kitabon ki jagah computer parts dikhne lagenge.

**→ App tab alfurqan.ae par hi rahega.** Agar aap chahte ho ki app
entwino.in use kare, to wahan Al Furqan ka poora store data (products,
home content, AED currency, users/orders) migrate karna hoga — fir hum
2 line ka switch kar denge.

---

## 4) Chhote requests (agli release me ho jaye to badhiya)

1. `Orders/GetUserOrders` ki rows me `products[]` (name, thumbnail,
   pivot.quantity/subtotal) include kar do — abhi slim rows aate hai,
   isliye history list me item naam/photo nahi dikh paate.
2. `Coupon/GetAllCoupons` aur `Pages/GetAllPages` ko guest (bina login)
   ke liye public kar do — About/Terms/Coupons login ke pehle bhi
   dikhne chahiye.
3. `GetAllProductsFront` ke `field/sort/price` query params ignore ho
   rahe hain (live A/B test se confirm) — sort/filter server-side kaam
   nahi karta. (Abhi app client-side handle karta hai.)
4. Currency rates: GBP/EUR ka exchange_rate 0.01 hai (galat) — ya to
   sahi rate daalo ya disable karo.
5. Home `Services` section me "Test" placeholder entry pada hai —
   admin se hata do.

## 5) NAYA (06/09 shaam) — Address delete + order_number timing ⚠️

6. **`Location/DeleteAddress` har shape par fail ho raha hai** user ke
   account se (DELETE `?id=<int>` — swagger exact, + 14 aur shapes:
   capital `Id`, POST/PUT/body `{id}`/`{Id}`, raw-int body,
   `DeleteAllAddress` query/body). Har attempt ke baad fresh
   `GetAllAddress` se verify kiya — address nahi hatta. Andhaaz:
   **order-linked addresses par DB FK restrict** hai (saare test
   addresses kisi-na-kisi order me use ho chuke hai). Options:
   (a) soft-delete (`is_active=0`) implement kar do, ya
   (b) DeleteAddress ko FK ke bawajood chalne do (orders me address
   snapshot already pada hona chahiye), ya
   (c) confirm karo delete order-linked par allowed hi nahi — to app
   honest message dikhati rahegi (abhi bhi dikhati hai).
7. **`GetUserOrders` rows me `order_number` TURANT assign nahi hota** —
   OrderPlace ke turant baad latest row pehle number ke BINA aati hai,
   number kuch der baad lagta hai. Isliye app ko snapshot-poll karke
   nayi row identify karni padi. Best: OrderPlace RESPONSE me hi
   `order_number` return kar do (abhi `data` null/only-id aata hai) —
   phir app ko poll hi nahi karna padega.

---

*App side contact: Lalit (project owner) — build v1.6.14+43 (06/09/2026).*
