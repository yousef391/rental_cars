import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rentra/presentation/screens/home_screen.dart';
import 'package:rentra/presentation/blocs/vehicle_bloc.dart';
import 'package:rentra/presentation/blocs/customer_bloc.dart';
import 'package:rentra/presentation/blocs/rental_bloc.dart';
import 'package:rentra/presentation/blocs/expense_bloc.dart';
import 'package:rentra/presentation/blocs/company_settings_bloc.dart';
import 'package:rentra/data/repositories/vehicle_repository.dart';
import 'package:rentra/data/repositories/customer_repository.dart';
import 'package:rentra/data/repositories/rental_repository.dart';
import 'package:rentra/data/repositories/expense_repository.dart';
import 'package:rentra/data/repositories/company_settings_repository.dart';
import 'package:rentra/data/services/localization_service.dart';
import 'package:rentra/data/services/notification_service.dart';
import 'package:rentra/data/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization service
  final localizationService = LocalizationService();
  await localizationService.initialize();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Print data location when app starts
  await printDataLocation();
  runApp(MyApp(localizationService: localizationService));
}

Future<void> printDataLocation() async {
  try {
    final appDataDir = await getApplicationSupportDirectory();
    final dataPath = '${appDataDir.path}/rentcardata';

    print('🔍 DATA LOCATION:');
    print('📁 Your car rental data is stored at:');
    print('   $dataPath');
    print('');
    print('📂 Data structure:');
    print('   $dataPath/');
    print('   ├── vehicles/     (Vehicle information)');
    print('   ├── customers/    (Customer information)');
    print('   ├── rentals/      (Rental agreements)');
    print('   └── expenses/     (Expense records)');
    print('');
    print('💾 Each item is stored as a separate JSON file');
    print('🔍 You can open these files with any text editor');
    print(
        '🚀 Quick access: Press Windows+R, type: %APPDATA%\\offline_rent_car\\rentcardata');
    print('');
  } catch (e) {
    print('❌ Error getting data location: $e');
  }
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;

  const MyApp({
    super.key,
    required this.localizationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<VehicleRepository>(
          create: (context) => VehicleRepository(),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(),
        ),
        RepositoryProvider<RentalRepository>(
          create: (context) => RentalRepository(),
        ),
        RepositoryProvider<ExpenseRepository>(
          create: (context) => ExpenseRepository(),
        ),
        RepositoryProvider<CompanySettingsRepository>(
          create: (context) => CompanySettingsRepository(
            StorageService()..initialize(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<VehicleBloc>(
            create: (context) => VehicleBloc(
              vehicleRepository: context.read<VehicleRepository>(),
            )..add(LoadVehicles()),
          ),
          BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
              customerRepository: context.read<CustomerRepository>(),
            )..add(LoadCustomers()),
          ),
          BlocProvider<RentalBloc>(
            create: (context) => RentalBloc(
              rentalRepository: context.read<RentalRepository>(),
              vehicleRepository: context.read<VehicleRepository>(),
            )..add(LoadRentals()),
          ),
          BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(
              expenseRepository: context.read<ExpenseRepository>(),
            )..add(LoadExpenses()),
          ),
          BlocProvider<CompanySettingsBloc>(
            create: (context) => CompanySettingsBloc(
              context.read<CompanySettingsRepository>(),
            )..add(LoadCompanySettings()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(1920, 1080),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return ListenableBuilder(
              listenable: localizationService,
              builder: (context, child) {
                return MaterialApp(
                  title: localizationService.translate('app_title'),
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    useMaterial3: true,
                    fontFamily: localizationService.isRTL ? 'Roboto' : null,
                  ),
                  builder: (context, child) {
                    return Directionality(
                      textDirection: localizationService.textDirection,
                      child: child!,
                    );
                  },
                  home: const HomeScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
