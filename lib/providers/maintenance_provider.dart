import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/models/maintenance.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:shop_floor_lite/services/seed_data_service.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';

class MaintenanceNotifier extends StateNotifier<List<MaintenanceTask>> {
  final String tenantId;

  MaintenanceNotifier(this.tenantId) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final box = DatabaseService.getMaintenanceBox();

    if (box.isEmpty) {
      final tasks = SeedDataService.getMaintenanceTasks(tenantId);
      for (var task in tasks) {
        await box.add(task);
      }
    }

    state = box.values.where((t) => t.tenantId == tenantId).toList();
  }

  Future<void> completeTask(String taskId, String completedBy, String note) async {
    final box = DatabaseService.getMaintenanceBox();
    final task = box.values.firstWhere((t) => t.id == taskId);

    task.status = 'done';
    task.completedBy = completedBy;
    task.completionNote = note;
    task.completedAt = DateTime.now();
    task.isSynced = false;
    await task.save();

    state = box.values.where((t) => t.tenantId == tenantId).toList();
  }

  List<MaintenanceTask> getTasksForMachine(String machineId) {
    return state.where((t) => t.machineId == machineId).toList();
  }
}

final maintenanceProvider = StateNotifierProvider<MaintenanceNotifier, List<MaintenanceTask>>((ref) {
  final user = ref.watch(authProvider);
  return MaintenanceNotifier(user?.tenantId ?? '');
});