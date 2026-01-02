import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/providers/auth_provider.dart';
import 'package:shop_floor_lite/providers/downtime_provider.dart';
import 'package:shop_floor_lite/providers/machine_provider.dart';
import 'package:shop_floor_lite/services/seed_data_service.dart';
import 'package:shop_floor_lite/services/image_service.dart';
import 'package:shop_floor_lite/models/reason_tree.dart';

class DowntimeCaptureScreen extends ConsumerStatefulWidget {
  final String machineId;

  const DowntimeCaptureScreen({super.key, required this.machineId});

  @override
  ConsumerState<DowntimeCaptureScreen> createState() => _DowntimeCaptureScreenState();
}

class _DowntimeCaptureScreenState extends ConsumerState<DowntimeCaptureScreen> {
  final List<ReasonNode> _reasonTree = SeedDataService.getReasonTree();
  ReasonNode? _selectedParentReason;
  ReasonNode? _selectedSubReason;
  String? _photoPath;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final machine = ref.watch(machineProvider.notifier).getMachineById(widget.machineId);
    final activeDowntime = ref.watch(downtimeProvider.notifier)
        .getActiveDowntimeForMachine(widget.machineId);

    if (machine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Machine Not Found')),
        body: const Center(child: Text('Machine not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Downtime - ${machine.name}'),
      ),
      body: SafeArea(
        child: activeDowntime != null
            ? _buildActiveDowntimeView(activeDowntime.id)
            : _buildStartDowntimeView(),
      ),
    );
  }

  Widget _buildStartDowntimeView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.warning_amber, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  'Start Downtime Capture',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a reason to record machine downtime',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '1. Select Primary Reason',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._reasonTree.map((reason) {
          final isSelected = _selectedParentReason?.code == reason.code;
          return Card(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
            child: ListTile(
              leading: Icon(
                Icons.radio_button_checked,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              title: Text(reason.label),
              onTap: () {
                setState(() {
                  _selectedParentReason = reason;
                  _selectedSubReason = null;
                });
              },
            ),
          );
        }),
        if (_selectedParentReason != null && _selectedParentReason!.children != null) ...[
          const SizedBox(height: 24),
          Text(
            '2. Select Sub-Reason',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._selectedParentReason!.children!.map((subReason) {
            final isSelected = _selectedSubReason?.code == subReason.code;
            return Card(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              child: ListTile(
                leading: Icon(
                  Icons.subdirectory_arrow_right,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                title: Text(subReason.label),
                onTap: () {
                  setState(() {
                    _selectedSubReason = subReason;
                  });
                },
              ),
            );
          }),
        ],
        if (_selectedSubReason != null) ...[
          const SizedBox(height: 24),
          Text(
            '3. Photo (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_photoPath != null)
            Card(
              child: Column(
                children: [
                  Image.file(
                    File(_photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: const Text('Photo attached'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _photoPath = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Add Photo'),
                subtitle: const Text('Compressed to ≤200KB'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _capturePhoto,
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isLoading ? null : _startDowntime,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow),
            label: const Text('Start Downtime'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveDowntimeView(String downtimeId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timelapse,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Downtime Active',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Downtime is being recorded for this machine',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _isLoading ? null : () => _endDowntime(downtimeId),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.stop),
              label: const Text('End Downtime'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    final photoPath = await ImageService.pickAndCompressImage();
    if (photoPath != null) {
      setState(() {
        _photoPath = photoPath;
      });
    }
  }

  Future<void> _startDowntime() async {
    if (_selectedParentReason == null || _selectedSubReason == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(authProvider);
      await ref.read(downtimeProvider.notifier).startDowntime(
            machineId: widget.machineId,
            reasonCode: _selectedParentReason!.code,
            reasonSubCode: _selectedSubReason!.code,
            operatorEmail: user!.email,
            photoPath: _photoPath,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downtime started successfully')),
        );
        setState(() {
          _selectedParentReason = null;
          _selectedSubReason = null;
          _photoPath = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _endDowntime(String downtimeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(downtimeProvider.notifier).endDowntime(downtimeId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downtime ended successfully')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
