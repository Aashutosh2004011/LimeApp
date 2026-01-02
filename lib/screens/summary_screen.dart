import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/downtime_provider.dart';
import 'package:shop_floor_lite/providers/maintenance_provider.dart';
import 'package:shop_floor_lite/providers/alert_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downtimes = ref.watch(downtimeProvider);
    final maintenanceTasks = ref.watch(maintenanceProvider);
    final alerts = ref.watch(alertProvider);
    final machines = ref.watch(machineProvider);

    // Calculate shift statistics (last 8 hours)
    final shiftStart = DateTime.now().subtract(const Duration(hours: 8));
    final shiftDowntimes = downtimes.where((d) => d.startTime.isAfter(shiftStart));
    final completedDowntimes = shiftDowntimes.where((d) => d.endTime != null);

    // KPI Calculations
    final totalDowntimeMinutes = completedDowntimes.fold<int>(
      0,
      (sum, d) => sum + (d.durationMinutes ?? 0),
    );

    final runningMachines = machines.where((m) => m.status == 'run').length;
    final machineUtilization = machines.isEmpty
        ? 0.0
        : (runningMachines / machines.length) * 100;

    final pendingMaintenance =
        maintenanceTasks.where((t) => t.status != 'done').length;
    final overdueMaintenance = maintenanceTasks
        .where((t) => t.status != 'done' && DateTime.now().isAfter(t.dueDate))
        .length;

    final criticalAlerts =
        alerts.where((a) => a.severity == 'critical' && a.status == 'created').length;
    final activeAlerts =
        alerts.where((a) => a.status == 'created').length;

    final avgDowntimePerEvent = completedDowntimes.isEmpty
        ? 0.0
        : totalDowntimeMinutes / completedDowntimes.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Report'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Current Shift Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last 8 hours',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _KPICard(
              title: 'Machine Utilization',
              value: '${machineUtilization.toStringAsFixed(1)}%',
              subtitle: '$runningMachines of ${machines.length} machines running',
              icon: Icons.precision_manufacturing,
              color: machineUtilization >= 80 ? Colors.green : Colors.orange,
              explanation: 'Percentage of machines currently in production mode',
            ),
            _KPICard(
              title: 'Total Downtime',
              value: '$totalDowntimeMinutes min',
              subtitle: '${completedDowntimes.length} downtime events',
              icon: Icons.schedule,
              color: totalDowntimeMinutes < 60 ? Colors.green : Colors.red,
              explanation: 'Total unplanned downtime during the current shift',
            ),
            _KPICard(
              title: 'Avg Downtime per Event',
              value: '${avgDowntimePerEvent.toStringAsFixed(1)} min',
              subtitle: completedDowntimes.isEmpty
                  ? 'No events'
                  : 'Based on ${completedDowntimes.length} events',
              icon: Icons.analytics,
              color: avgDowntimePerEvent < 15 ? Colors.green : Colors.orange,
              explanation:
                  'Average duration of each downtime event - lower is better',
            ),
            _KPICard(
              title: 'Maintenance Status',
              value: '$pendingMaintenance pending',
              subtitle: overdueMaintenance > 0
                  ? '$overdueMaintenance overdue tasks'
                  : 'All tasks on schedule',
              icon: Icons.build,
              color: overdueMaintenance > 0 ? Colors.red : Colors.green,
              explanation: 'Outstanding maintenance tasks requiring attention',
            ),
            _KPICard(
              title: 'Alert Status',
              value: '$activeAlerts active',
              subtitle: criticalAlerts > 0
                  ? '$criticalAlerts critical alerts'
                  : 'No critical alerts',
              icon: Icons.notification_important,
              color: criticalAlerts > 0 ? Colors.red : Colors.blue,
              explanation:
                  'Unacknowledged alerts requiring supervisor attention',
            ),
            _KPICard(
              title: 'MTBF (Mean Time Between Failures)',
              value: completedDowntimes.isEmpty
                  ? 'N/A'
                  : '${(480 / completedDowntimes.length).toStringAsFixed(0)} min',
              subtitle: 'Based on 8-hour shift',
              icon: Icons.trending_up,
              color: Colors.purple,
              explanation:
                  'Average operating time between failures - higher is better',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'KPI Explanation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These Key Performance Indicators help shop floor managers make data-driven decisions:\n\n'
                    '• Machine Utilization: Monitors production efficiency\n'
                    '• Downtime Metrics: Identifies bottlenecks and improvement areas\n'
                    '• Maintenance Status: Prevents unplanned downtime\n'
                    '• Alert Tracking: Enables proactive issue resolution\n'
                    '• MTBF: Measures equipment reliability',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String explanation;

  const _KPICard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
