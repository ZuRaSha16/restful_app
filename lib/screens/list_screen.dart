import 'package:flutter/material.dart';
import '../models/object_model.dart';
import '../services/api_service.dart';
import '../widgets/object_item.dart';
import '../widgets/skeleton_grid.dart';
import 'details_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ObjectModel> _allObjects = [];
  List<ObjectModel> _filtered = [];
  bool inProgress = false;
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    getObjectList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? List.from(_allObjects)
          : _allObjects
                .where(
                  (o) =>
                      o.name.toLowerCase().contains(query) ||
                      o.id.toLowerCase().contains(query),
                )
                .toList();
    });
  }

  void getObjectList() async {
    inProgress = true;
    setState(() {});

    try {
      final objects = await _api.getAll();
      _allObjects = objects;

      _nextId = 1;
      for (final obj in _allObjects) {
        final parsed = int.tryParse(obj.id);
        if (parsed != null && parsed >= _nextId) {
          _nextId = parsed + 1;
        }
      }

      _filtered = List.from(_allObjects);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    inProgress = false;
    setState(() {});
  }

  void deleteObject(String id) {
    setState(() {
      _allObjects.removeWhere((o) => o.id == id);
      _filtered.removeWhere((o) => o.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Object deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> openForm({ObjectModel? existing}) async {
    final result = await Navigator.push<ObjectModel>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailsScreen(
          existing: existing,
          nextId: existing == null ? '$_nextId' : null,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        final idx = _allObjects.indexWhere((o) => o.id == result.id);
        if (idx >= 0) {
          _allObjects[idx] = result;
        } else {
          _allObjects.add(result);
          _nextId++;
        }
        _onSearch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DeviceHub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: getObjectList,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => getObjectList(),
        child: inProgress
            ? const SkeletonGrid()
            : _filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.devices_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'No results for\n"${_searchController.text}"'
                          : 'No devices yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchController.text.isEmpty) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => openForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add your first device'),
                      ),
                    ],
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  return ObjectItem(
                    object: _filtered[index],
                    onPressDelete: deleteObject,
                    onPressEdit: (obj) => openForm(existing: obj),
                  );
                },
              ),
      ),
    );
  }
}
