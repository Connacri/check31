import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fi;
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../checkit/providerF.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class EnhancedCallScreen extends StatefulWidget {
  const EnhancedCallScreen({super.key});

  @override
  State<EnhancedCallScreen> createState() => _EnhancedCallScreenState();
}

class _EnhancedCallScreenState extends State<EnhancedCallScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _loadingStates = {};
  final int _pageSize = 20;
  fi.User? _user;
  List<CallLogEntry> _calls = [];
  Set<String> _reportedNumbers = {};
  List<String> _cachedNumbers = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _permissionGranted = false;
  Timer? _searchDebounce;



  @override
  void initState() {
    super.initState();
    _user = fi.FirebaseAuth.instance.currentUser;
    _initialize();

  }

  Future<void> _initialize() async {
    await _checkPermissions();
    if (_permissionGranted) {
      // await _loadCache();
      await _fetchReportedNumbers(); // New method
      _loadCallLog();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await Permission.phone.status;
      setState(() => _permissionGranted = status.isGranted);

      if (!_permissionGranted) {
        final result = await Permission.phone.request();
        setState(() => _permissionGranted = result.isGranted);
      }
    } catch (e) {
      _showError('Erreur de permissions: ${e.toString()}');
    }
  }

  Future<void> _updateCache(String number) async {
    if (!_cachedNumbers.contains(number)) {
      _cachedNumbers.add(number);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('reported_cache', _cachedNumbers);
    }
  }

  Future<void> _loadCallLog({bool loadMore = false}) async {
    if (!_permissionGranted) return;

    try {
      if (!loadMore) {
        _currentPage = 1;
        _calls.clear();
      }

      final result = await CallLog.query(
        dateTimeFrom: DateTime.now().subtract(const Duration(days: 30)),
        dateTimeTo: DateTime.now(),
      );

      final List<CallLogEntry> resultList = result.toList();
      final filtered = _applySearchFilter(resultList);

      setState(() {
        if (filtered.length > _pageSize) {
          _calls = loadMore
              ? [..._calls, ...filtered.sublist(0, _pageSize)]
              : filtered.sublist(0, _pageSize);
          _hasMore = true;
        } else {
          _calls = loadMore ? [..._calls, ...filtered] : filtered;
          _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      _showError('Erreur de chargement: ${e.toString()}');
    }
  }

  List<CallLogEntry> _applySearchFilter(List<CallLogEntry> entries) {
    if (_searchController.text.isEmpty) return entries;

    return entries.where((entry) {
      final number = entry.number ?? '';
      return number.contains(_searchController.text);
    }).toList();
  }

  Future<void> _reportNumber(String normalizedNumber) async {
    final number =
        Provider.of<SignalementProviderSupabase>(context, listen: false)
            .normalizeAndValidateAlgerianPhone(normalizedNumber);
    print(number);
    if (number!.isEmpty || _reportedNumbers.contains(number)) return;

    setState(() => _loadingStates[number] = true);

    try {
      await _supabase.from('signalements').insert({
        'numero': number,
        'motif': 'Spam', // Valeur par défaut
        'gravite': 1, // Valeur par défaut
        'date': DateTime.now().toIso8601String(),
        'signalePar': '${_user!.displayName ?? "Utilisateur"}',
        'user': _user!.uid,
      });

      setState(() {
        _reportedNumbers.add(number);
        _cachedNumbers.add(number);
      });
      _updateCache(number);
      // setState(() => _reportedNumbers.add(number));
      _updateCache(number);
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() => _loadingStates.remove(number));
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////
  Future<void> _fetchReportedNumbers() async {
    try {
      final response = await _supabase.from('signalements').select('numero');
      final List<Map<String, dynamic>> data = response;
      setState(() {
        _reportedNumbers = data.map((e) => e['numero'] as String).toSet();
        _cachedNumbers = _reportedNumbers.toList();
      });
    } catch (e) {
      _showError('Erreur de récupération des signalements: $e');
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final signalementProvider =
    Provider.of<SignalementProviderSupabase>(context);
    if (!_permissionGranted) {
      return Scaffold(body: Center(child: _buildPermissionDenied()));
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un numéro...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _loadCallLog,
            ),
          ),
          onChanged: (value) {
            _searchDebounce?.cancel();
            _searchDebounce =
                Timer(const Duration(milliseconds: 500), _loadCallLog);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCallLog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _calls.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _calls.length) {
                  return _hasMore
                      ? _buildLoadMoreButton()
                      : const SizedBox.shrink();
                }


                return _buildCallItem(_calls[index],signalementProvider );
              },
            ),
    );


  }

  Widget _buildCallItem(CallLogEntry entry,signalementProvider) {
    final number = entry.number ?? 'Inconnu';
    //WidgetsBinding.instance.addPostFrameCallback((_) => _checkNumber(number));
    final normalizedNumber =
        Provider.of<SignalementProviderSupabase>(context, listen: false)
            .normalizeAndValidateAlgerianPhone(number);


    return ListTile(
      leading: const Icon(Icons.phone),
      //  leading: buildCallTypeIcon(_getCallType(entry.callType)),

      title: Text('${entry.name ?? 'Inconnu'}'),

      subtitle: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: '$number'));
          // Optionnel : afficher une confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$number Copié dans le presse-papiers')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  number,
                  style: TextStyle(fontSize: 18, color : _reportedNumbers.contains(normalizedNumber)
                      ? Colors.red : null ),
                ),
                SizedBox(
                  width: 5,
                ),
                buildCallTypeIcon(_getCallType(entry.callType)),

              ],
            ),
            Text('Type: ${_getCallType(entry.callType)}'),
            Text('Date: ${_formatDate(entry.timestamp)}'),
          ],
        ),
      ),
      trailing: _loadingStates[normalizedNumber] ?? false
          ? const CircularProgressIndicator(strokeWidth: 2)
          :
      IconButton(
        icon: signalementProvider.nombreSignalements(normalizedNumber) == 0
            ? Icon(
          Icons.report,
          color: Colors.grey,
        )
            : FutureBuilder<int>(
          future: Future.value(signalementProvider.nombreSignalements(normalizedNumber)),
          builder: (context, snapshot) {
            // Gestion du chargement
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(
                _reportedNumbers.contains(normalizedNumber)
                    ? Icons.block
                    : Icons.report,
                color: _reportedNumbers.contains(normalizedNumber)
                    ? Colors.red
                    : Colors.grey,
              );
            }

            final count = snapshot.data ?? 0;
            if (count == 0) {
              return Icon(
                Icons.report,
                color: Colors.grey,
              );
            }

            return Badge.count(
              count: count,
              child: Icon(
                _reportedNumbers.contains(normalizedNumber)
                    ? Icons.block
                    : Icons.report,
                color: _reportedNumbers.contains(normalizedNumber)
                    ? Colors.red
                    : Colors.grey,
              ),
            );
          },
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmation du Signal'),
              content: Text(
                _reportedNumbers.contains(normalizedNumber)
                    ? 'Ce numéro a déjà été signalé.'
                    : 'Voulez-vous vraiment signaler ce numéro ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  // Ferme la boîte
                  child: const Text('Annuler'),
                ),
                _reportedNumbers.contains(normalizedNumber)
                    ? SizedBox.shrink()
                    : TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme la boîte
                    _reportNumber(normalizedNumber!);
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            ),
          );
        },
      ),
        // IconButton(
        //         icon: Icon(
        //           _reportedNumbers.contains(normalizedNumber)
        //               ? Icons.block
        //               : Icons.report,
        //           color: _reportedNumbers.contains(normalizedNumber)
        //               ? Colors.red
        //               : Colors.grey,
        //         ),
        //         onPressed: () {
        //           showDialog(
        //             context: context,
        //             builder: (context) => AlertDialog(
        //               title: const Text('Confirmation du Signal'),
        //               content: Text(
        //                 _reportedNumbers.contains(normalizedNumber)
        //                     ? 'Ce numéro a déjà été signalé.'
        //                     : 'Voulez-vous vraiment signaler ce numéro ?',
        //               ),
        //               actions: [
        //                 TextButton(
        //                   onPressed: () => Navigator.of(context).pop(),
        //                   // Ferme la boîte
        //                   child: const Text('Annuler'),
        //                 ),
        //                 _reportedNumbers.contains(normalizedNumber)
        //                     ? SizedBox.shrink()
        //                     : TextButton(
        //                         onPressed: () {
        //                           Navigator.of(context).pop(); // Ferme la boîte
        //                           _reportNumber(normalizedNumber!);
        //                         },
        //                         child: const Text('Confirmer'),
        //                       ),
        //               ],
        //             ),
        //           );
        //         },
        //       ),

    );
  }



  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Permission requise pour accéder aux appels'),
          ElevatedButton(
            onPressed: _checkPermissions,
            child: const Text('Autoriser l\'accès'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _currentPage++;
          _loadCallLog(loadMore: true);
        },
        child: const Text('Charger plus'),
      ),
    );
  }

  String _getCallType(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return 'Entrant';
      case CallType.outgoing:
        return 'Sortant';
      case CallType.missed:
        return 'Manqué';
      default:
        return 'Inconnu';
    }
  }

  Widget buildCallTypeIcon(String callType) {
    switch (callType.toLowerCase()) {
      case 'entrant':
        return const Icon(Icons.call_received, color: Colors.green);
      case 'sortant':
        return const Icon(Icons.call_made, color: Colors.blue);
      case 'manqué':
        return const Icon(Icons.call_missed, color: Colors.red);
      case 'bloqué':
        return const Icon(Icons.block, color: Colors.black54);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _formatDate(int? timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0),
    );
  }
}
