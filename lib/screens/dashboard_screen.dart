import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';
import 'package:shop_floor_lite/providers/sync_provider.dart';
import 'package:shop_floor_lite/screens/machine_detail_screen.dart';
import 'package:shop_floor_lite/screens/alert_management_screen.dart';
import 'package:shop_floor_lite/screens/summary_screen.dart';
import 'package:shop_floor_lite/models/machine.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Color _getStatusColor(MachineStatus status) {
    switch (status) {
      case MachineStatus.run:
        return Colors.green;
      case MachineStatus.idle:
        return Colors.orange;
      case MachineStatus.off:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(MachineStatus status) {
    switch (status) {
      case MachineStatus.run:
        return Icons.play_circle_filled;
      case MachineStatus.idle:
        return Icons.pause_circle_filled;
      case MachineStatus.off:
        return Icons.stop_circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final machines = ref.watch(machineProvider);
    final syncService = ref.watch(syncServiceProvider);
    final pendingItemsAsync = ref.watch(pendingItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop Floor Lite'),
            Text(
              '${user?.role.toUpperCase()} - ${user?.email}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Sync indicator
          pendingItemsAsync.when(
            data: (count) {
              if (count > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cloud_upload),
                      onPressed: () => syncService.syncPendingItems(),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.cloud_done),
                onPressed: () {},
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const Icon(Icons.cloud_off),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'summary',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Summary Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (user?.role == 'supervisor')
                const PopupMenuItem(
                  value: 'alerts',
                  child: ListTile(
                    leading: Icon(Icons.notification_important),
                    title: Text('Alert Management'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).logout();
              } else if (value == 'alerts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlertManagementScreen(),
                  ),
                );
              } else if (value == 'summary') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SummaryScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Machine Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: machines.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: machines.length,
                        itemBuilder: (context, index) {
                          final machine = machines[index];
                          return _MachineCard(
                            machine: machine,
                            statusColor: _getStatusColor(machine.machineStatus),
                            statusIcon: _getStatusIcon(machine.machineStatus),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  final Color statusColor;
  final IconData statusIcon;

  const _MachineCard({
    required this.machine,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MachineDetailScreen(machineId: machine.id),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                size: 48,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              machine.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              machine.type.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                machine.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}