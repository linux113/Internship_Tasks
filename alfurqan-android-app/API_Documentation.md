# Al Furqan Mobile App — API Documentation

> Source: Google Doc shared by project owner
> (`https://docs.google.com/document/d/1RqD8YPsdxD0uNmvpa8s9TqCYum5UWh3g`)
> Base URL: **https://alfurqan.ae**

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
