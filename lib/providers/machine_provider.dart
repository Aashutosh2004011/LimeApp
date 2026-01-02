import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/models/machine.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:shop_floor_lite/services/seed_data_service.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';

class MachineNotifier extends StateNotifier<List<Machine>> {
  final String tenantId;

  MachineNotifier(this.tenantId) : super([]) {
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    final box = DatabaseService.getMachineBox();

    if (box.isEmpty) {
      final machines = SeedDataService.getMachines(tenantId);
      for (var machine in machines) {
        await box.add(machine);
      }
    }

    state = box.values.where((m) => m.tenantId == tenantId).toList();
  }

  Future<void> updateMachineStatus(String machineId, String status) async {
    final box = DatabaseService.getMachineBox();
    final machine = box.values.firstWhere((m) => m.id == machineId);
    machine.status = status;
    await machine.save();

    state = box.values.where((m) => m.tenantId == tenantId).toList();
  }

  Machine? getMachineById(String machineId) {
    try {
      return state.firstWhere((m) => m.id == machineId);
    } catch (e) {
      return null;
    }
  }
}

final machineProvider = StateNotifierProvider<MachineNotifier, List<Machine>>((ref) {
  final user = ref.watch(authProvider);
  return MachineNotifier(user?.tenantId ?? '');
});