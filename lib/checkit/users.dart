import 'package:check31/checkit/provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../AppLocalizations.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UsersProvider>(context, listen: false);
    provider.loadUsers();
    _scrollController.addListener(() {
      final provider = Provider.of<UsersProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.loadUsers();
      }
    });
  }

  Future<void> _confirmAndDelete(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.red,
            title: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Supprimer cet utilisateur ?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    if (confirmed ?? false) {
      await Provider.of<UsersProvider>(
        context,
        listen: false,
      ).deleteUser(userId);
    }
  }

  void _showSignalementsList(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SignalementsListSheet(userId: user['firebase_id']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UsersProvider>(
        builder:
            (context, provider, _) => CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      '${provider.users.length} ${AppLocalizations.of(context).translate('user')}',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "${AppLocalizations.of(context).translate('userList')}",
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= provider.users.length) {
                        return provider.isLoading
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      int reversedIndex = provider.users.length - 1 - index;
                      final user = provider.users[index];
                      return _buildUserCard(user, reversedIndex);
                    },
                    childCount:
                        provider.users.length + (provider.hasMore ? 1 : 0),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          _showSignalementsList(context, user);
        },
        onLongPress: () => _confirmAndDelete(context, user['id']),
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(
          user['full_name'] ?? 'Nom inconnu',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user['email']}', overflow: TextOverflow.ellipsis),
            if (user['phone'] != null) Text('Téléphone : ${user['phone']}'),
            Text(
              user['created_at'] != null
                  ? timeago.format(
                    DateTime.parse(user['created_at']).toLocal(),
                    locale: 'fr',
                  )
                  : 'N/A',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: FutureBuilder<int>(
          future: Provider.of<UsersProvider>(
            context,
            listen: false,
          ).getSignalementsCount(user['firebase_id']),
          builder: (context, snapshot) {
            return Text(
              '${snapshot.data ?? 0}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SignalementsListSheet extends StatefulWidget {
  final String userId;

  const SignalementsListSheet({Key? key, required this.userId})
    : super(key: key);

  @override
  State<SignalementsListSheet> createState() => _SignalementsListSheetState();
}

class _SignalementsListSheetState extends State<SignalementsListSheet> {
  List<Map<String, dynamic>> _signalements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSignalements();
  }

  Future<void> _loadSignalements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('signalements')
          .select()
          .eq('user', widget.userId)
          .order('date', ascending: false);

      setState(() {
        _signalements = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Numéros signalés',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_signalements.length} signalements',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _signalements.isEmpty
                        ? const Center(
                          child: Text(
                            'Aucun numéro signalé par cet utilisateur',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: _signalements.length,
                          itemBuilder: (context, index) {
                            final signalement = _signalements[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  '0' + signalement['numero'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Motif: ${signalement['motif'] ?? ''}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (signalement['description'] != null)
                                      Text(
                                        'Description: ${signalement['description']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    Text(
                                      signalement['date'] != null
                                          ? timeago.format(
                                            DateTime.parse(
                                              signalement['date'],
                                            ).toLocal(),
                                            locale: 'fr',
                                          )
                                          : 'Date inconnue',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  'Gravité: ${signalement['gravite'] ?? ''}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
