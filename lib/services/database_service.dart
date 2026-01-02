import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_floor_lite/models/user.dart';
import 'package:shop_floor_lite/models/machine.dart';
import 'package:shop_floor_lite/models/downtime.dart';
import 'package:shop_floor_lite/models/maintenance.dart';
import 'package:shop_floor_lite/models/alert.dart';

class DatabaseService {
  static const String userBox = 'userBox';
  static const String machineBox = 'machineBox';
  static const String downtimeBox = 'downtimeBox';
  static const String maintenanceBox = 'maintenanceBox';
  static const String alertBox = 'alertBox';
  static const String syncQueueBox = 'syncQueueBox';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(MachineAdapter());
    Hive.registerAdapter(DowntimeAdapter());
    Hive.registerAdapter(MaintenanceTaskAdapter());
    Hive.registerAdapter(AlertAdapter());

    // Open boxes
    await Hive.openBox<User>(userBox);
    await Hive.openBox<Machine>(machineBox);
    await Hive.openBox<Downtime>(downtimeBox);
    await Hive.openBox<MaintenanceTask>(maintenanceBox);
    await Hive.openBox<Alert>(alertBox);
    await Hive.openBox(syncQueueBox);
  }

  static Box<User> getUserBox() => Hive.box<User>(userBox);
  static Box<Machine> getMachineBox() => Hive.box<Machine>(machineBox);
  static Box<Downtime> getDowntimeBox() => Hive.box<Downtime>(downtimeBox);
  static Box<MaintenanceTask> getMaintenanceBox() => Hive.box<MaintenanceTask>(maintenanceBox);
  static Box<Alert> getAlertBox() => Hive.box<Alert>(alertBox);
  static Box getSyncQueueBox() => Hive.box(syncQueueBox);

  static Future<void> clearAll() async {
    await getUserBox().clear();
    await getMachineBox().clear();
    await getDowntimeBox().clear();
    await getMaintenanceBox().clear();
    await getAlertBox().clear();
    await getSyncQueueBox().clear();
  }
}