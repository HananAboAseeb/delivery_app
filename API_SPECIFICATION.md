# API Specification

Based on the provided `swagger.json` file for the ECommerce microservice, here is the detailed breakdown.

## Authentication Method
The system uses **OAuth2 / OIDC** with **Bearer JWT Token**. 
- Security Schemes documented in Swagger indicate `oauth2`.
- Endpoints generally require `Authorization: Bearer <token>`.

## Base Endpoints Categorization
Based on the Swagger paths, the endpoints are primarily grouped as follows.

### 1. Auth & Users (Identity Integration)
*(Note: Full auth is usually on an AuthServer, but the ECommerce service uses `CurrentUserDto` for user context)*
- `GET /api/abp/application-configuration` - Returns `CurrentUserDto` which includes user details (`id`, `userName`, `email`, `roles`, etc.).

### 2. Products / Items
- `GET /api/ECommerce/items/by-name` (Params: `filter`)
- `GET /api/ECommerce/items-cache` (Get cached items list)
- `GET /api/ECommerce/items-cache/new/{MaxId}`
- `GET /api/ECommerce/offer-group` / `GET /api/ECommerce/offers`
- **Schemas**: `ItemCardCache`, `ItemsForViewDto`, `OffersForViewDto` containing price, sizes, colors, thumbnail, etc.

### 3. Cart & Orders
- `GET /api/ECommerce/checkout/master/{masterOrderId}`
- `POST /api/ECommerce/checkout/cancel-order/{OrderId}`
- `GET /api/ECommerce/merchant-orders/my-orders`
- **Schemas**: `CheckoutInputDto`, `CheckoutItemDto`, `MyOrderHead`, `OrderItem`. Order includes items, delivery fees, sub-totals, region info, coupon discounts.

### 4. Tracking / Delivery (Delivery App)
- `POST /api/ECommerce/delivery-app/fetch-orders`
- `POST /api/ECommerce/delivery-app/delivered-confirmation/{OrderId}`
- `POST /api/ECommerce/delivery-app/receipt-confirmation/{MerchantOrderId}`
- `POST /api/ECommerce/delivery-order-assignment/set-delivery`
- `GET /api/ECommerce/delivery-order-assignment/delivery-order`
- **Schemas**: `DeliveryOrderDto`, `DeliveryDashboarData`, `DeliveryInfo`.

### 5. Notification
- `POST /api/ECommerce/plat-from-notification-report/fetch-report`
- `POST /api/ECommerce/user-notification-report/set-readed/{Id}`
- **Schemas**: `UNotificationReport`, `NotificationType`.

### 6. Stores & Regions
- `POST /api/ECommerce/stores/get-all`
- `GET /api/ECommerce/stores/by-id/{Id}`
- `GET /api/ECommerce/regions`
- `POST /api/ECommerce/regions/find-by-point`
- **Schemas**: `StoresForViewDto`, `RegionForViewDto`, `StoreRegionDeliveryPriceForViewDto`.

## SignalR Real-Time Hub
The Swagger JSON does **not** document direct SignalR hubs (which is standard, as Swagger focuses on HTTP APIs). We will construct a `SignalRService` relying on standard Abp framework hub routing (likely `/signalr` or `/hubs/commerce`) to listen for `OrderStatusChanged` and `DriverLocationUpdated` events.
