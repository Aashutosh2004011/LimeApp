import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:shop_floor_lite/providers/maintenance_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';
import 'package:shop_floor_lite/models/maintenance.dart';
import 'package:intl/intl.dart';

class MaintenanceListScreen extends ConsumerWidget {
  final String machineId;

  const MaintenanceListScreen({super.key, required this.machineId});

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.done:
        return Colors.green;
      case MaintenanceStatus.overdue:
        return Colors.red;
      case MaintenanceStatus.due:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machine = ref.watch(machineProvider.notifier).getMachineById(machineId);
    final tasks = ref.watch(maintenanceProvider.notifier).getTasksForMachine(machineId);

    if (machine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Machine Not Found')),
        body: const Center(child: Text('Machine not found')),
      );
    }

    final pendingTasks = tasks.where((t) => t.status != 'done').toList();
    final completedTasks = tasks.where((t) => t.status == 'done').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance - ${machine.name}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (pendingTasks.isNotEmpty) ...[
              Text(
                'Pending Tasks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...pendingTasks.map((task) => _TaskCard(
                    task: task,
                    statusColor: _getStatusColor(task.maintenanceStatus),
                    onComplete: () => _showCompleteDialog(context, ref, task),
                  )),
            ],
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Completed Tasks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...completedTasks.map((task) => _TaskCard(
                    task: task,
                    statusColor: _getStatusColor(task.maintenanceStatus),
                  )),
            ],
            if (tasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No maintenance tasks',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCompleteDialog(
      BuildContext context, WidgetRef ref, MaintenanceTask task) async {
    final controller = TextEditingController();
    final user = ref.read(authProvider);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Completion Note',
                hintText: 'Enter notes about the completed task',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await ref.read(maintenanceProvider.notifier).completeTask(
            task.id,
            user!.email,
            controller.text,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed successfully')),
        );
      }
    }

    controller.dispose();
  }
}

class _TaskCard extends StatelessWidget {
  final MaintenanceTask task;
  final Color statusColor;
  final VoidCallback? onComplete;

  const _TaskCard({
    required this.task,
    required this.statusColor,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 12,
          height: double.infinity,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Due: ${dateFormat.format(task.dueDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (task.completedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${dateFormat.format(task.completedAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
            if (task.completionNote != null) ...[
              const SizedBox(height: 4),
              Text(
                'Note: ${task.completionNote}',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: task.status == 'done'
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: onComplete,
                tooltip: 'Mark as complete',
              ),
      ),
    );
  }
}
