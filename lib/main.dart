import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/controller/auth/auth_controller.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/controller/settings/user_settings_controller.dart';
import 'package:pdm_fatec_1/controller/shopping_list/shopping_list_controller.dart';
import 'package:pdm_fatec_1/services/service_locator.dart';
import 'package:pdm_fatec_1/view/home/home_view.dart';
import 'package:provider/provider.dart';

// Chave global para o navegador
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa as dependências
  await setupDependencies();

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(
          value: getIt<AuthController>(),
        ),
        ChangeNotifierProvider<MealController>.value(
          value: getIt<MealController>(),
        ),
        ChangeNotifierProvider<ShoppingListController>.value(
          value: getIt<ShoppingListController>(),
        ),
        ChangeNotifierProvider<UserSettingsController>.value(
          value: getIt<UserSettingsController>(),
        ),
      ],
      child: MaterialApp(
        title: 'MealPlanner',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
      ),
    );
  }
}
