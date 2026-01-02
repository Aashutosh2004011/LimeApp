import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:shop_floor_lite/providers/alert_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';
import 'package:shop_floor_lite/models/alert.dart';
import 'package:intl/intl.dart';

class AlertManagementScreen extends ConsumerWidget {
  const AlertManagementScreen({super.key});

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.deepOrange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertProvider);
    final createdAlerts =
        alerts.where((a) => a.status == 'created').toList();
    final acknowledgedAlerts =
        alerts.where((a) => a.status == 'acknowledged').toList();
    final clearedAlerts = alerts.where((a) => a.status == 'cleared').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Management'),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Active (${createdAlerts.length})',
                    icon: const Icon(Icons.notification_important),
                  ),
                  Tab(
                    text: 'Acknowledged (${acknowledgedAlerts.length})',
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                  Tab(
                    text: 'Cleared (${clearedAlerts.length})',
                    icon: const Icon(Icons.done_all),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAlertList(context, ref, createdAlerts),
                    _buildAlertList(context, ref, acknowledgedAlerts),
                    _buildAlertList(context, ref, clearedAlerts),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertList(
      BuildContext context, WidgetRef ref, List<Alert> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No alerts',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _AlertCard(
          alert: alert,
          severityColor: _getSeverityColor(alert.alertSeverity),
          onAcknowledge: alert.status == 'created'
              ? () => _acknowledgeAlert(context, ref, alert)
              : null,
          onClear: alert.status == 'acknowledged'
              ? () => _clearAlert(context, ref, alert)
              : null,
        );
      },
    );
  }

  Future<void> _acknowledgeAlert(
      BuildContext context, WidgetRef ref, Alert alert) async {
    final user = ref.read(authProvider);
    await ref.read(alertProvider.notifier).acknowledgeAlert(
          alert.id,
          user!.email,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert acknowledged')),
      );
    }
  }

  Future<void> _clearAlert(
      BuildContext context, WidgetRef ref, Alert alert) async {
    await ref.read(alertProvider.notifier).clearAlert(alert.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert cleared')),
      );
    }
  }
}

class _AlertCard extends ConsumerWidget {
  final Alert alert;
  final Color severityColor;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onClear;

  const _AlertCard({
    required this.alert,
    required this.severityColor,
    this.onAcknowledge,
    this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machine = ref.watch(machineProvider.notifier).getMachineById(alert.machineId);
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: severityColor,
                        ),
                      ),
                      Text(
                        machine?.name ?? alert.machineId,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${dateFormat.format(alert.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (alert.acknowledgedAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Acknowledged: ${dateFormat.format(alert.acknowledgedAt!)} by ${alert.acknowledgedBy}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
                if (alert.clearedAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.done_all, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Cleared: ${dateFormat.format(alert.clearedAt!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ],
                if (onAcknowledge != null || onClear != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onAcknowledge != null)
                        FilledButton.icon(
                          onPressed: onAcknowledge,
                          icon: const Icon(Icons.check),
                          label: const Text('Acknowledge'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      if (onClear != null)
                        FilledButton.icon(
                          onPressed: onClear,
                          icon: const Icon(Icons.done_all),
                          label: const Text('Clear'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
