import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

class TodaysTomatoesCard extends StatefulWidget {
  const TodaysTomatoesCard({super.key});

  @override
  State<TodaysTomatoesCard> createState() => _TodaysTomatoesCardState();
}

class _TodaysTomatoesCardState extends State<TodaysTomatoesCard> {
  late Future<List<Tomato>> _tomatoesFuture;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _tomatoesFuture = ApiService().getTodaysTomatoes(authState.userUuid);
    } else {
      // Handle the case where the user is not authenticated when the widget is first built.
      _tomatoesFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a BlocListener to react to auth changes after the initial build
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // If the user authenticates while this widget is on screen, fetch their tomatoes.
          setState(() {
            _tomatoesFuture = ApiService().getTodaysTomatoes(state.userUuid);
          });
        }
      },
      child: Card(
        child: FutureBuilder<List<Tomato>>(
          future: _tomatoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tomatoes for today.'));
            } else {
              final tomatoes = snapshot.data!;
              return ListView.builder(
                itemCount: tomatoes.length,
                itemBuilder: (context, index) {
                  final tomato = tomatoes[index];
                  return ListTile(
                    title: Text(tomato.subject),
                    subtitle: Text('Created: ${DateFormat('dd/MM/yyyy HH:mm').format(tomato.createdAt)}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
