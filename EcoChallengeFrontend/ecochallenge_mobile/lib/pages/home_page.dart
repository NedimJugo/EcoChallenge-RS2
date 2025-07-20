import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EventProvider _eventProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<Event> _events = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize provider and load events once
    _eventProvider = Provider.of<EventProvider>(context, listen: false);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // Check if widget is still mounted before calling setState
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _eventProvider.get();
      if (!mounted) return; // Check again after async operation
      
      setState(() {
        _events = result.items ?? [];
      });

      // Print events to console to verify
      for (var e in _events) {
        print('Event: ${e.title}, Date: ${e.eventDate}');
      }
    } catch (e) {
      if (!mounted) return; // Check again after async operation
      
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoChallenge Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _events.isEmpty
                  ? const Center(child: Text('No events found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                                ? Image.network(event.imageUrl!, width: 50, fit: BoxFit.cover)
                                : const Icon(Icons.event),
                            title: Text(event.title ?? 'No Title'),
                            subtitle: Text('Date: ${event.eventDate.toLocal().toString().split(" ")[0]}'),
                          ),
                        );
                      },
                    ),
    );
  }
}