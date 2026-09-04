import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/navigation/navigation.gr.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/network/service.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/feature/health/view/add_data_menu_sheet.dart';
import 'package:flutter_healthkit/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _SettingsAction { logout }

Future<void> _handleLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to log in again to continue.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  await AuthService().logout();
  appRouter.replace(const LoginView());
}

@RoutePage()
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final collectorsState = ref.watch(dataCollectorsNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          _TopAppBar(
            colorScheme: colorScheme,
            onLogout: () => _handleLogout(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(dataCollectorsNotifierProvider.notifier).refresh(),
              child: _CollectorsBody(colorScheme: colorScheme, state: collectorsState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDataMenuSheet(context),
        tooltip: 'Add health data',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CollectorsBody extends StatelessWidget {
  const _CollectorsBody({required this.colorScheme, required this.state});

  final ColorScheme colorScheme;
  final AsyncValue<List<GeneralDataCollectorResponseModel>> state;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _MessageState(
        colorScheme: colorScheme,
        icon: Icons.cloud_off,
        title: 'Could not load data collectors.',
        subtitle: 'Pull down to try again.',
      ),
      data: (collectors) {
        if (collectors.isEmpty) {
          return _MessageState(
            colorScheme: colorScheme,
            icon: Icons.inbox_outlined,
            title: 'No data collectors yet.',
            subtitle: 'Tap + to create one.',
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
          itemCount: collectors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _DataCollectorCard(collector: collectors[index], colorScheme: colorScheme),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DataCollectorCard extends StatelessWidget {
  const _DataCollectorCard({required this.collector, required this.colorScheme});

  final GeneralDataCollectorResponseModel collector;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final collectorId = collector.collectorId;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: collectorId == null
            ? null
            : () => appRouter.push(DataCollectorDetailView(collectorId: collectorId)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.sensors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collector.collectorName ?? collectorId ?? 'Unknown collector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collector.collectorDataType?.name ?? collector.collectorType ?? '-',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.colorScheme, required this.onLogout});

  final ColorScheme colorScheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Collectors',
              style: TextStyle(
                fontSize: 24,
                height: 32 / 24,
                letterSpacing: -0.24,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Row(
              children: [
                PopupMenuButton<_SettingsAction>(
                  icon: Icon(Icons.settings_outlined, color: colorScheme.onSurfaceVariant),
                  tooltip: 'Settings',
                  onSelected: (action) {
                    if (action == _SettingsAction.logout) onLogout();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _SettingsAction.logout,
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.person, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

