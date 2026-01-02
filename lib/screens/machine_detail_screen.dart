import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';
import 'package:shop_floor_lite/providers/downtime_provider.dart';
import 'package:shop_floor_lite/providers/maintenance_provider.dart';
import 'package:shop_floor_lite/screens/downtime_capture_screen.dart';
import 'package:shop_floor_lite/screens/maintenance_list_screen.dart';

class MachineDetailScreen extends ConsumerWidget {
  final String machineId;

  const MachineDetailScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final machine = ref.watch(machineProvider.notifier).getMachineById(machineId);
    final downtimes = ref.watch(downtimeProvider.notifier).getDowntimesForMachine(machineId);
    final maintenanceTasks = ref.watch(maintenanceProvider.notifier).getTasksForMachine(machineId);

    if (machine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Machine Not Found')),
        body: const Center(child: Text('Machine not found')),
      );
    }

    final activeDowntime = downtimes.where((d) => d.isActive).firstOrNull;
    final pendingTasks = maintenanceTasks.where((t) => t.status != 'done').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(machine.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                machine.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Type: ${machine.type}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            machine.status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${downtimes.where((d) => d.endTime != null).length}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Downtime Events'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$pendingTasks',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Pending Tasks'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (user?.role == 'operator') ...[
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.warning_amber, color: Colors.orange),
                      title: const Text('Downtime Management'),
                      subtitle: activeDowntime != null
                          ? const Text('Active downtime in progress')
                          : const Text('No active downtime'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DowntimeCaptureScreen(machineId: machineId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.checklist, color: Colors.blue),
                      title: const Text('Maintenance Checklist'),
                      subtitle: Text('$pendingTasks pending tasks'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaintenanceListScreen(machineId: machineId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (user?.role == 'supervisor') ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Recent Downtimes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...downtimes.take(5).map((downtime) {
                final duration = downtime.durationMinutes;
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.pause_circle, color: Colors.orange),
                    title: Text(downtime.reasonCode),
                    subtitle: Text(
                      duration != null
                          ? 'Duration: $duration minutes'
                          : 'Active',
                    ),
                    trailing: Text(
                      '${downtime.startTime.hour}:${downtime.startTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
