import 'package:get_it/get_it.dart';
import 'package:pdm_fatec_1/controller/auth/auth_controller.dart';
import 'package:pdm_fatec_1/controller/meal/meal_controller.dart';
import 'package:pdm_fatec_1/controller/settings/user_settings_controller.dart';
import 'package:pdm_fatec_1/controller/shopping_list/shopping_list_controller.dart';
import 'package:pdm_fatec_1/services/auth_service.dart';
import 'package:pdm_fatec_1/services/firestore_service.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Serviços
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  await getIt<StorageService>().init();

  // Controllers
  getIt.registerSingleton<AuthController>(
    AuthController(
      getIt<StorageService>(),
      getIt<AuthService>(),
      getIt<FirestoreService>(),
    ),
  );
  getIt.registerSingleton<MealController>(
    MealController(getIt<StorageService>(), getIt<FirestoreService>()),
  );
  getIt.registerSingleton<ShoppingListController>(
    ShoppingListController(getIt<StorageService>(), getIt<FirestoreService>()),
  );
  getIt.registerSingleton<UserSettingsController>(
    UserSettingsController(getIt<StorageService>(), getIt<FirestoreService>()),
  );
}
