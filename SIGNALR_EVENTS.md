# SignalR Events Specification

> **Target:** `.NET Core SignalR` processing real-time delivery and order tracking.
> **Package:** `signalr_core` 

## Hub Configuration
```dart
const hubUrl = 'https://erp.neosending.com/signalr-hubs/delivery'; // Assumed from standard Abp
```

## Setup & Reconnect Strategy
- Include `Authorization: Bearer <token>` in the transport options.
- Handle `onclose` with an exponential backoff.

## Server-to-Client Event Listeners

### 1. `ReceiveNotification`
Listens for generic system push notifications (replaces/augments FCM).
- Payload Map maps to `UNotificationReport`.

```dart
hubConnection.on('ReceiveNotification', (arguments) {
  // arguments[0] -> title
  // arguments[1] -> message
  // Trigger flutter_local_notifications display
});
```

### 2. `OrderStatusChanged`
Fired when `MyOrderHead` status changes.
- Syncs UI and local Drift DB status.

```dart
hubConnection.on('OrderStatusChanged', (arguments) {
  // arguments[0] -> orderId
  // arguments[1] -> newStatus (e.g. "Shipped")
});
```

### 3. `DriverLocationUpdate` (Active Tracking)
Continuous stream when an order is in transit or driver assigned.
- Lat/Lng map to `GeoPointDto`.

```dart
hubConnection.on('DriverLocationUpdate', (arguments) {
  // arguments[0] -> deliveryId
  // arguments[1] -> latitude
  // arguments[2] -> longitude
});
```

## Client-to-Server Invocations (Emit)

1. **`JoinOrderTrackingGroup`**
```dart
hubConnection.invoke('JoinGroup', args: ['Order_$orderId']);
```

2. **`LeaveOrderTrackingGroup`**
```dart
hubConnection.invoke('LeaveGroup', args: ['Order_$orderId']);
```
