# Offline Car Rental Management System

A comprehensive desktop application for managing car rental operations offline, built with Flutter using MVVM architecture and Cubit state management.

## Features

### 🚗 Vehicle Management
- Add, edit, and delete vehicles
- Track vehicle details (make, model, year, license plate, color, daily rate)
- Manage vehicle status (Available, Rented, Under Maintenance)
- Comprehensive maintenance tracking with service history
- Search and filter vehicles by various criteria

### 👥 Customer Management
- Add, edit, and delete customer information
- Store customer details (name, phone, email, driver license, address)
- Search customers by name, license number, or contact information

### 📋 Rental Management
- Create new rental agreements
- Select available vehicles and existing customers
- Automatic cost calculation based on daily rates and duration
- Track rental status (Active, Completed)
- Complete rentals and update vehicle availability

### 📊 Dashboard & Analytics
- Real-time statistics overview
- Vehicle availability status
- Active rental count
- Upcoming returns (next 48 hours)
- Visual status indicators

### 📅 Calendar View
- Visual calendar showing vehicle availability
- Filter by specific vehicles
- View rental periods and status
- Interactive day selection for detailed information

## Architecture

This application follows the **MVVM (Model-View-ViewModel)** architectural pattern:

- **Model**: Data classes for Vehicle, Customer, Rental, and MaintenanceRecord
- **View**: Flutter UI components and screens
- **ViewModel**: BLoC (Business Logic Component) classes for state management

### State Management
- Uses **Cubit** from the `flutter_bloc` package
- Separate BLoCs for Vehicles, Customers, and Rentals
- Reactive UI updates based on state changes

### Data Storage
- **100% Offline**: All data stored locally on the user's machine
- **File-based Storage**: JSON files organized in dedicated folders
- **Data Location**: `rentcardata` folder in application support directory
- **No Authentication Required**: Direct access based on local machine permissions

## Technical Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **State Management**: flutter_bloc (Cubit)
- **Data Serialization**: dart:convert (JSON)
- **File System**: path_provider, dart:io
- **Calendar Widget**: table_calendar
- **UI Components**: Material Design 3

## Installation & Setup

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Windows, macOS, or Linux for desktop support

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd offline_rent_car
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d windows  # For Windows
   flutter run -d macos    # For macOS
   flutter run -d linux    # For Linux
   ```

### Building for Production

**Windows:**
```bash
flutter build windows
```

**macOS:**
```bash
flutter build macos
```

**Linux:**
```bash
flutter build linux
```

## Data Storage Structure

The application creates a `rentcardata` folder in the system's application support directory:

```
rentcardata/
├── vehicles/
│   ├── vehicle_id_1.json
│   ├── vehicle_id_2.json
│   └── ...
├── customers/
│   ├── customer_id_1.json
│   ├── customer_id_2.json
│   └── ...
└── rentals/
    ├── rental_id_1.json
    ├── rental_id_2.json
    └── ...
```

Each entity is stored as a separate JSON file with a unique ID, ensuring data integrity and easy backup/restore operations.

## Usage Guide

### Getting Started
1. Launch the application
2. Start by adding vehicles to your fleet
3. Register customers in the system
4. Create rental agreements as needed

### Vehicle Management
- **Add Vehicle**: Click "Add Vehicle" and fill in all required details
- **Edit Vehicle**: Use the edit option from the vehicle list
- **Maintenance**: Add maintenance records to track service history
- **Status Management**: Change vehicle status as needed

### Customer Management
- **Add Customer**: Enter complete customer information
- **Search**: Use the search bar to find specific customers
- **Edit**: Update customer details as needed

### Rental Operations
- **Create Rental**: Select available vehicle and customer, set dates
- **Automatic Calculation**: Total cost is calculated automatically
- **Complete Rental**: Mark rentals as completed when vehicles are returned
- **Status Tracking**: Monitor active and completed rentals

### Dashboard
- **Overview**: View key statistics at a glance
- **Upcoming Returns**: See vehicles due for return in the next 48 hours
- **Quick Actions**: Access main functions from the dashboard

### Calendar View
- **Availability**: Visual representation of vehicle availability
- **Filter**: Select specific vehicles to view their schedule
- **Details**: Click on dates to see rental information

## Features in Detail

### Maintenance Tracking
- Record maintenance type (oil change, brake check, etc.)
- Track service dates and next due dates
- Add detailed notes for each service
- View complete maintenance history per vehicle

### Search & Filter
- **Vehicles**: Search by make, model, or license plate
- **Customers**: Search by name, license number, or contact info
- **Rentals**: Filter by status (active/completed)
- **Status Filtering**: Filter vehicles by availability status

### Cost Calculation
- Automatic calculation based on daily rates
- Duration calculation (start date to end date)
- Real-time updates when changing dates or vehicle selection

## Data Backup & Security

### Backup Recommendations
- Regularly backup the `rentcardata` folder
- Store backups in secure, separate locations
- Consider automated backup solutions

### Security Considerations
- Data is stored locally without encryption
- Access is based on local machine permissions
- No network connectivity required
- Physical access to machine implies access to data

## Troubleshooting

### Common Issues

**Application won't start:**
- Ensure Flutter SDK is properly installed
- Check that all dependencies are installed (`flutter pub get`)
- Verify desktop support is enabled

**Data not persisting:**
- Check application permissions
- Verify the `rentcardata` folder exists
- Ensure sufficient disk space

**Performance issues:**
- Large datasets may affect performance
- Consider archiving old rental records
- Regular maintenance of the data folder

## Future Enhancements

Potential features for future releases:
- Data export/import functionality
- Advanced reporting and analytics
- Multi-user support with authentication
- Integration with external calendar systems
- Backup and restore functionality
- Advanced search and filtering options
- Rental agreement printing
- Revenue tracking and reporting

## Contributing

This is a standalone application designed for offline use. For modifications or enhancements:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions:
- Check the troubleshooting section
- Review the code documentation
- Ensure all dependencies are properly installed

---

**Note**: This application is designed for offline use and stores all data locally. Ensure regular backups of your data folder to prevent data loss. 