# Trip Status Management System

## Overview
This document explains the new trip status management system that integrates with the API for real-time trip status updates.

## Trip Statuses

### 1. SCHEDULED (Default)
- **Description**: Trip is created and assigned to driver
- **Display**: Shown in `CurrentTripsScreen`
- **Actions**: Driver can "Start Trip" when ready
- **API Status**: `SCHEDULED`

### 2. STARTED
- **Description**: Driver has started the trip
- **Display**: Shown in `CurrentTripsScreen` with progress tracking
- **Actions**: Driver can "Complete Trip" when finished
- **API Status**: `STARTED`
- **Triggered by**: Driver clicking "Start Trip" button

### 3. COMPLETED
- **Description**: Trip is finished successfully
- **Display**: Shown in `TripHistoryScreen`
- **Actions**: View details only
- **API Status**: `COMPLETED`
- **Triggered by**: Driver clicking "Complete Trip" button

### 4. CANCELLED
- **Description**: Trip was cancelled
- **Display**: Shown in `TripHistoryScreen`
- **Actions**: View details only
- **API Status**: `CANCELLED`

## Screen Flow

### CurrentTripsScreen
- Loads trips with status: `SCHEDULED` and `STARTED`
- Shows "Start Trip" button for SCHEDULED trips
- Shows "Complete Trip" button for STARTED trips
- Shows progress bar for STARTED trips

### TripHistoryScreen
- Loads trips with status: `COMPLETED` and `CANCELLED`
- API endpoint: `GET /trips/by-driver/{driverId}?status=COMPLETED`
- Shows trip completion details and statistics

## API Integration

### Endpoints Used

1. **Get Current Trips**
   ```
   GET /trips/by-driver/{driverId}?status=SCHEDULED
   GET /trips/by-driver/{driverId}?status=STARTED
   ```

2. **Get Trip History**
   ```
   GET /trips/by-driver/{driverId}?status=COMPLETED
   ```

3. **Update Trip Status** (for backend team to implement)
   ```
   PUT /trips/{tripId}/status
   Body: { "status": "STARTED" | "COMPLETED" | "CANCELLED" }
   ```

### Authentication
All API calls use Bearer token authentication:
```
Authorization: Bearer {token}
```

## Code Structure

### Events
- `LoadCurrentTrips`: Loads SCHEDULED + STARTED trips
- `LoadTripHistory`: Loads COMPLETED trips via API
- `LoadTripsByStatus`: Loads trips with specific status
- `UpdateTripStatus`: Updates trip status (STARTED/COMPLETED)

### States
- `CurrentTripsLoaded`: For SCHEDULED/STARTED trips
- `TripHistoryLoaded`: For COMPLETED/CANCELLED trips
- `TripStarted`: When trip status changes to STARTED
- `TripCompleted`: When trip status changes to COMPLETED
- `TripStatusUpdated`: Generic status update

### Use Cases
- `GetTripsByStatusUseCase`: Fetches trips by status from API
- `UpdateTripStatusUseCase`: Updates trip status
- `GetCurrentTripsUseCase`: Gets current trips (SCHEDULED + STARTED)
- `GetTripHistoryUseCase`: Gets completed trips

## Driver Workflow

1. **View Current Trips**: Driver sees SCHEDULED trips in CurrentTripsScreen
2. **Start Trip**: Driver clicks "Start Trip" → Status changes to STARTED
3. **Trip in Progress**: Trip shows in CurrentTripsScreen with progress tracking
4. **Complete Trip**: Driver clicks "Complete Trip" → Status changes to COMPLETED
5. **View History**: Completed trips appear in TripHistoryScreen

## Backend Integration Notes

### For Backend Team
1. **Status Values**: Use exactly these values in API responses:
   - `SCHEDULED` (default for new trips)
   - `STARTED`
   - `COMPLETED` 
   - `CANCELLED`

2. **Status Update Endpoint**: Implement endpoint to update trip status:
   ```
   PUT /trips/{tripId}/status
   Content-Type: application/json
   Authorization: Bearer {token}
   
   {
     "status": "STARTED"
   }
   ```

3. **Driver ID**: Extract from Bearer token or pass as parameter

### Current Implementation
- Status updates currently use existing `startTrip` and `completeTrip` endpoints
- Ready to switch to generic status update endpoint when available

## Testing

### API Testing
Use the provided examples in:
- `lib/features/driver/trips_management/examples/api_usage_examples.dart`
- `lib/features/driver/trips_management/presentation/view/screens/api_test_screen.dart`

### Test Scenarios
1. Load current trips (SCHEDULED + STARTED)
2. Load trip history (COMPLETED)
3. Start a trip (SCHEDULED → STARTED)
4. Complete a trip (STARTED → COMPLETED)

## Configuration

### API Settings
Update in `lib/core/shared/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://ec2-13-61-182-206.eu-north-1.compute.amazonaws.com';
```

### Authentication
Set Bearer token in `StorageService` for automatic API authentication.

## Error Handling

- **Network Errors**: Falls back to local data
- **Authentication Errors**: Shows error message
- **Invalid Status**: Validation with error feedback
- **API Timeouts**: Configurable timeout (10 seconds default)

## Future Enhancements

1. **Real-time Updates**: WebSocket support for live status changes
2. **Offline Support**: Cache status updates when offline
3. **Push Notifications**: Notify about trip status changes
4. **Batch Operations**: Update multiple trip statuses
5. **Status History**: Track all status changes with timestamps
