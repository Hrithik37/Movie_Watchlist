// lib/screens/movie_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';

enum WatchFilter { all, watched, unwatched }

class MovieListPage extends StatefulWidget {
  const MovieListPage({Key? key}) : super(key: key);

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<ParseObject> _movies = [];
  bool _loading = true;
  WatchFilter _filter = WatchFilter.all;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _loading = true);

    final currentUser = await ParseUser.currentUser() as ParseUser?;
    final builder = QueryBuilder(ParseObject('Movie'))
      ..orderByAscending('movie_title');
    if (currentUser != null) {
      builder.whereEqualTo('owner', currentUser);
    }
    if (_filter == WatchFilter.watched) {
      builder.whereEqualTo('watched', true);
    } else if (_filter == WatchFilter.unwatched) {
      builder.whereEqualTo('watched', false);
    }

    final res = await builder.query();
    _movies = (res.success && res.results != null)
        ? res.results as List<ParseObject>
        : [];
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditSheet({ParseObject? movie}) {
    final isNew = movie == null;
    final titleCtl = TextEditingController(
        text: movie?.get<String>('movie_title') ?? '');
    final ratingCtl = TextEditingController(
        text: movie?.get<num>('rating')?.toString() ?? '');
    bool watched = movie?.get<bool>('watched') ?? false;
    double rating = movie?.get<num>('rating')?.toDouble() ?? 0.0;
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    isNew ? 'Add Movie' : 'Edit Movie',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: titleCtl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Watched switch
                  SwitchListTile(
                    title: const Text('Watched'),
                    value: watched,
                    onChanged: (v) => setState(() => watched = v),
                  ),

                  // Rating input & stars
                  if (watched) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ratingCtl,
                      decoration: const InputDecoration(
                        labelText: 'Rating (1–5)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Rating is required';
                        }
                        final val = int.tryParse(v);
                        if (val == null || val < 1 || val > 5) {
                          return 'Enter a number between 1 and 5';
                        }
                        return null;
                      },
                      onChanged: (v) {
                        final val = int.tryParse(v);
                        if (val != null && val >= 1 && val <= 5) {
                          setState(() => rating = val.toDouble());
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: theme.colorScheme.primary,
                          size: 32,
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isNew)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          onPressed: () async {
                            await movie!.delete();
                            if (!mounted) return;
                            Navigator.of(ctx).pop();
                            _loadMovies();
                          },
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final obj = movie ?? ParseObject('Movie');
                          obj
                            ..set('movie_title', titleCtl.text.trim())
                            ..set('watched', watched);

                          if (watched) {
                            obj.set('rating', int.parse(ratingCtl.text));
                          } else {
                            obj.unset('rating');
                          }

                          final currentUser =
                              await ParseUser.currentUser() as ParseUser?;
                          if (currentUser != null) {
                            obj.set('owner', currentUser);
                          }

                          final res = await obj.save();
                          if (res.success && mounted) {
                            Navigator.of(ctx).pop();
                            _loadMovies();
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Save failed: ${res.error?.message ?? 'unknown'}'),
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('My Watchlist', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: WatchFilter.values.map((f) {
                final label = switch (f) {
                  WatchFilter.all => 'All',
                  WatchFilter.watched => 'Watched',
                  WatchFilter.unwatched => 'Unwatched',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: f == _filter,
                    onSelected: (_) {
                      setState(() => _filter = f);
                      _loadMovies();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // movie list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMovies,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _movies.length,
                      itemBuilder: (_, i) {
                        final m = _movies[i];
                        final title = m.get<String>('movie_title') ?? '';
                        final watched = m.get<bool>('watched') ?? false;
                        final rating = m.get<num>('rating')?.toInt() ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            leading: Icon(
                              watched ? Icons.check_circle : Icons.movie,
                              color: watched
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            title:
                                Text(title, style: theme.textTheme.titleMedium),
                            subtitle: watched
                                ? Row(children: List.generate(5, (j) {
                                    return Icon(
                                      j < rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }))
                                : null,
                            onTap: () => _showEditSheet(movie: m),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add Movie'),
      ),
    );
  }
}
