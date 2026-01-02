import 'package:shop_floor_lite/models/machine.dart';
import 'package:shop_floor_lite/models/maintenance.dart';
import 'package:shop_floor_lite/models/reason_tree.dart';
import 'package:shop_floor_lite/models/alert.dart';
import 'package:uuid/uuid.dart';

class SeedDataService {
  static const _uuid = Uuid();

  static List<Machine> getMachines(String tenantId) {
    return [
      Machine(
        id: 'M-101',
        name: 'Cutter 1',
        type: 'cutter',
        status: 'run',
        tenantId: tenantId,
      ),
      Machine(
        id: 'M-102',
        name: 'Roller A',
        type: 'roller',
        status: 'idle',
        tenantId: tenantId,
      ),
      Machine(
        id: 'M-103',
        name: 'Packing West',
        type: 'packer',
        status: 'run',
        tenantId: tenantId,
      ),
    ];
  }

  static List<ReasonNode> getReasonTree() {
    return [
      ReasonNode(
        code: 'POWER',
        label: 'Power',
        children: [
          ReasonNode(code: 'GRID', label: 'Grid'),
          ReasonNode(code: 'INTERNAL', label: 'Internal'),
        ],
      ),
      ReasonNode(
        code: 'CHANGEOVER',
        label: 'Changeover',
        children: [
          ReasonNode(code: 'TOOLING', label: 'Tooling'),
        ],
      ),
    ];
  }

  static List<MaintenanceTask> getMaintenanceTasks(String tenantId) {
    final now = DateTime.now();
    return [
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-101',
        title: 'Blade Inspection',
        description: 'Check blade sharpness and alignment',
        dueDate: now.add(const Duration(days: 2)),
        tenantId: tenantId,
      ),
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-101',
        title: 'Lubrication Check',
        description: 'Apply lubricant to moving parts',
        dueDate: now.subtract(const Duration(days: 1)),
        status: 'overdue',
        tenantId: tenantId,
      ),
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-102',
        title: 'Belt Tension',
        description: 'Check and adjust belt tension',
        dueDate: now.add(const Duration(days: 5)),
        tenantId: tenantId,
      ),
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-102',
        title: 'Roller Cleaning',
        description: 'Clean roller surface',
        dueDate: now.subtract(const Duration(days: 3)),
        status: 'overdue',
        tenantId: tenantId,
      ),
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-103',
        title: 'Safety Check',
        description: 'Verify all safety mechanisms',
        dueDate: now.add(const Duration(days: 1)),
        tenantId: tenantId,
      ),
      MaintenanceTask(
        id: _uuid.v4(),
        machineId: 'M-103',
        title: 'Conveyor Inspection',
        description: 'Inspect conveyor belt for wear',
        dueDate: now.add(const Duration(days: 7)),
        tenantId: tenantId,
      ),
    ];
  }

  static List<Alert> getSampleAlerts(String tenantId) {
    final now = DateTime.now();
    return [
      Alert(
        id: _uuid.v4(),
        machineId: 'M-101',
        title: 'High Temperature',
        message: 'Machine temperature exceeding normal range',
        severity: 'high',
        status: 'created',
        createdAt: now.subtract(const Duration(minutes: 15)),
        tenantId: tenantId,
      ),
      Alert(
        id: _uuid.v4(),
        machineId: 'M-102',
        title: 'Low Speed Warning',
        message: 'Roller speed below optimal level',
        severity: 'medium',
        status: 'acknowledged',
        createdAt: now.subtract(const Duration(hours: 2)),
        acknowledgedBy: 'supervisor@example.com',
        acknowledgedAt: now.subtract(const Duration(hours: 1)),
        tenantId: tenantId,
      ),
      Alert(
        id: _uuid.v4(),
        machineId: 'M-103',
        title: 'Vibration Detected',
        message: 'Unusual vibration pattern detected',
        severity: 'critical',
        status: 'created',
        createdAt: now.subtract(const Duration(minutes: 5)),
        tenantId: tenantId,
      ),
    ];
  }
}