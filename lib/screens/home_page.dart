import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ParseObject> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final q = QueryBuilder(ParseObject('Expense'))..orderByDescending('date');
    final res = await q.query();
    if (res.success && res.results != null) {
      _items = res.results as List<ParseObject>;
    }
    setState(() => _loading = false);
  }

  Future<void> _addOrEdit({ParseObject? obj}) async {
    final desc = TextEditingController(text: obj?.get<String>('description'));
    final amt  = TextEditingController(text: obj?.get<num>('amount')?.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(obj == null ? 'Add Expense' : 'Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: amt, decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final d = desc.text.trim();
              final a = double.tryParse(amt.text);
              if (d.isEmpty || a == null) return; // rudimentary validation
              final exp = obj ?? ParseObject('Expense');
              exp
                ..set('description', d)
                ..set('amount', a)
                ..set('date', DateTime.now());
              await exp.save();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
    _refresh();
  }

  Future<void> _delete(ParseObject obj) async {
    await obj.delete();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Your Expenses'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Log out',
      onPressed: _logout,
    ),
  ],
),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) {
                  final e = _items[i];
                  return ListTile(
                    title: Text(e.get<String>('description') ?? ''),
                    subtitle: Text('₹${e.get<num>('amount')?.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(e),
                    ),
                    onTap: () => _addOrEdit(obj: e),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _logout() async {
  // 1) Grab the currently logged‐in user
  final currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser != null) {
    // 2) Call logout() on that instance
    await currentUser.logout();
  }

  // 3) Navigate back to LoginPage
  if (!mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

}
