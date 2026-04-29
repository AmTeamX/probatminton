import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../domain/models/court.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/empty_state.dart';

class ManageCourtsScreen extends ConsumerWidget {
  const ManageCourtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageCourtsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manage Courts'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: switch (state) {
        ManageCourtsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        ManageCourtsError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    ref.read(manageCourtsProvider.notifier).loadCourts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        ManageCourtsLoaded(:final courts) =>
          courts.isEmpty
              ? const EmptyState(
                  icon: Icons.sports_tennis,
                  title: 'No Courts',
                  subtitle: 'Add your first court to get started.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(manageCourtsProvider.notifier).loadCourts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: courts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      if (court is Court) return _CourtCard(court: court);
                      return ListTile(title: Text('$court'));
                    },
                  ),
                ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourtForm(context),
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCourtForm(BuildContext context, [Court? court]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CourtFormSheet(existingCourt: court),
    );
  }
}

class _CourtCard extends ConsumerWidget {
  final Court court;
  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sports_tennis, color: AppTheme.primary),
        ),
        title: Text(
          court.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              court.location,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  (court.avgRating ?? 0).toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  '${court.reviewCount ?? 0} reviews',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (action) async {
            if (action == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => _CourtFormSheet(existingCourt: court),
              );
            } else if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Court?'),
                  content: Text(
                    'Are you sure you want to delete "${court.name}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                final success = await ref
                    .read(manageCourtsProvider.notifier)
                    .deleteCourt(court.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Court deleted' : 'Failed to delete court',
                      ),
                      backgroundColor: success
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  );
                }
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppTheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtFormSheet extends ConsumerStatefulWidget {
  final Court? existingCourt;
  const _CourtFormSheet({this.existingCourt});

  @override
  ConsumerState<_CourtFormSheet> createState() => _CourtFormSheetState();
}

class _CourtFormSheetState extends ConsumerState<_CourtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
    text: widget.existingCourt?.name,
  );
  late final _locationCtrl = TextEditingController(
    text: widget.existingCourt?.location,
  );
  late final _descCtrl = TextEditingController(
    text: widget.existingCourt?.description,
  );
  late final _priceCtrl = TextEditingController(
    text: widget.existingCourt?.pricePerHour.toString() ?? '',
  );
  late final _latCtrl = TextEditingController(
    text: widget.existingCourt?.latitude?.toString() ?? '',
  );
  late final _lngCtrl = TextEditingController(
    text: widget.existingCourt?.longitude?.toString() ?? '',
  );
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCourt != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Court' : 'Add Court',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Court Name',
                  prefixIcon: Icon(Icons.sports_tennis),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Price per Hour (฿)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Valid price required'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(isEditing ? 'Update Court' : 'Create Court'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final body = {
      'name': _nameCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price_per_hour': double.parse(_priceCtrl.text),
      if (_latCtrl.text.isNotEmpty) 'latitude': double.tryParse(_latCtrl.text),
      if (_lngCtrl.text.isNotEmpty) 'longitude': double.tryParse(_lngCtrl.text),
    };

    final notifier = ref.read(manageCourtsProvider.notifier);
    bool success;
    if (widget.existingCourt != null) {
      success = await notifier.updateCourt(widget.existingCourt!.id, body);
    } else {
      success = await notifier.createCourt(body);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Court ${widget.existingCourt != null ? "updated" : "created"}'
                : 'Failed',
          ),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
      Navigator.pop(context);
    }
    setState(() => _isSubmitting = false);
  }
}
