import 'package:flutter/material.dart';
import 'package:flutter_healthkit/feature/health/view/create_data_collector_sheet.dart';
import 'package:flutter_healthkit/feature/health/view/insert_health_records_sheet.dart';
import 'package:flutter_healthkit/feature/health/view/update_data_collector_sheet.dart';
import 'package:flutter_healthkit/feature/health/view/upload_sample_data_sheet.dart';

Future<void> showAddDataMenuSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const AddDataMenuSheet(),
  );
}

class AddDataMenuSheet extends StatelessWidget {
  const AddDataMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Add health data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.add_box_outlined,
              title: 'Create data collector',
              subtitle: 'Register a new data collector',
              onTap: () => _open(context, const CreateDataCollectorSheet()),
            ),
            _MenuTile(
              icon: Icons.playlist_add,
              title: 'Insert health records',
              subtitle: 'Add a health record to an existing collector',
              onTap: () => _open(context, const InsertHealthRecordsSheet()),
            ),
            _MenuTile(
              icon: Icons.upload_outlined,
              title: 'Upload sample data',
              subtitle: 'Upload a sample point into a sample set',
              onTap: () => _open(context, const UploadSampleDataSheet()),
            ),
            _MenuTile(
              icon: Icons.edit_outlined,
              title: 'Update data collector',
              subtitle: 'Edit an existing data collector',
              onTap: () => _open(context, const UpdateDataCollectorSheet()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget sheet) {
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => sheet,
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
