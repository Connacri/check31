import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _limit = 20;


  @override
  void initState() {
    super.initState();
  _loadUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _loadUsers();
      }
    });
  }





  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .order('created_at', ascending: false)
        .range(_page * _limit, (_page + 1) * _limit - 1);

    if (response.isEmpty) {
      _hasMore = false;
    } else {
      _users.addAll(List<Map<String, dynamic>>.from(response));
      _page++;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    await Supabase.instance.client.from('users').delete().eq('id', id);
    setState(() {
      _users.removeWhere((user) => user['id'] == id);

    });
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(user['full_name'] ?? 'Nom inconnu',  overflow: TextOverflow.ellipsis
          ,  style: const TextStyle(fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user['email']}', overflow: TextOverflow.ellipsis,),
            if (user['phone'] != null)
              Text('Téléphone : ${user['phone']}'),
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
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirmer'),
                content: const Text('Supprimer cet utilisateur ?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer')),
                ],
              ),
            );
            if (confirm ?? false) {
              await _deleteUser(user['id']);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
           SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 100,

            flexibleSpace: FlexibleSpaceBar(
              title: Text('${_users.length} utilisateurs'),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "La Liste des utilisateurs",

                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= _users.length) {
                  return _isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const SizedBox.shrink();
                }
                final user = _users[index];
                return _buildUserCard(user, index);
              },
              childCount: _users.length + (_hasMore ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }
}
