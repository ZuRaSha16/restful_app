import 'package:flutter/material.dart';
import '../models/object_model.dart';

class DetailsScreen extends StatefulWidget {
  final ObjectModel? existing;
  final ObjectModel? viewOnly;
  final String? nextId;

  const DetailsScreen({super.key, this.existing, this.viewOnly, this.nextId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<_Entry> _entries = [];

  bool get _isViewMode => widget.viewOnly != null;
  bool get _isEditMode => widget.existing != null;

  static const List<String> _allowedKeys = [
    'color',
    'capacity',
    'capacity GB',
    'price',
    'generation',
    'year',
    'CPU model',
    'Hard disk size',
    'Strap Colour',
    'Case Size',
    'Screen size',
    'Description',
    'Qty',
  ];

  @override
  void initState() {
    super.initState();
    final obj = widget.existing ?? widget.viewOnly;
    if (obj != null) {
      _nameController.text = obj.name;
      obj.data?.forEach((k, v) {
        _entries.add(
          _Entry(
            key: TextEditingController(text: k),
            value: TextEditingController(text: v?.toString() ?? ''),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final e in _entries) {
      e.key.dispose();
      e.value.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{};
    for (final e in _entries) {
      final k = e.key.text.trim();
      if (k.isNotEmpty) data[k] = e.value.text.trim();
    }

    final payload = ObjectModel(
      id: widget.existing?.id ?? widget.nextId ?? '0',
      name: _nameController.text.trim(),
      data: data.isEmpty ? null : data,
    );

    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isViewMode
              ? 'Details'
              : _isEditMode
              ? 'Update Object'
              : 'Add New Object (ID: ${widget.nextId})',
        ),
      ),
      body: _isViewMode ? _buildViewMode(widget.viewOnly!) : _buildFormMode(),
    );
  }

  Widget _buildViewMode(ObjectModel obj) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      obj.name.isNotEmpty ? obj.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obj.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${obj.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (obj.data != null && obj.data!.isNotEmpty) ...[
            const Text(
              'Properties',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...obj.data!.entries.map(
              (e) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          e.key,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value?.toString() ?? '—',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('No additional properties'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormMode() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Name *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Apple MacBook Pro',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name is required';
              }
              if (v.trim().length < 2) {
                return 'Min 2 characters';
              }
              if (v.trim().length > 100) {
                return 'Max 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Data Fields',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () => setState(
                  () => _entries.add(
                    _Entry(
                      key: TextEditingController(),
                      value: TextEditingController(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Field'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No fields added.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._entries.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: entry.key.text.isEmpty
                            ? null
                            : entry.key.text,
                        decoration: const InputDecoration(
                          hintText: 'Key',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: _allowedKeys
                            .map(
                              (k) => DropdownMenuItem(
                                value: k,
                                child: Text(
                                  k,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => entry.key.text = val);
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          final duplicates = _entries
                              .where(
                                (e) =>
                                    e.key.text.trim().toLowerCase() ==
                                    v.trim().toLowerCase(),
                              )
                              .length;
                          if (duplicates > 1) {
                            return 'Duplicate key';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Value field
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: entry.value,
                        decoration: const InputDecoration(
                          hintText: 'Value',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (v.trim().length > 100) {
                            return 'Max 100 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Remove button
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => setState(() => _entries.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _submit,
              child: Text(_isEditMode ? 'UPDATE' : 'ADD'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Entry {
  final TextEditingController key;
  final TextEditingController value;
  _Entry({required this.key, required this.value});
}
