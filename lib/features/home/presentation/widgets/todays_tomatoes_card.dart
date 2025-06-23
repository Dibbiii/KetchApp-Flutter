import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return "less than a minute";
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    var parts = <String>[];
    if (hours > 0) {
      parts.add('$hours hour${hours > 1 ? 's' : ''}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }
    return parts.join(' and ');
  }

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
        elevation: 0,
        color: Theme.of(context).colorScheme.surface.withAlpha(0),
        child: FutureBuilder<List<Tomato>>(
          future: _tomatoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('You have no tomatoes scheduled for today.'));
            } else {
              final now = DateTime.now().toUtc();
              final tomatoes = snapshot.data!;
              tomatoes.sort((a, b) => a.startAt.compareTo(b.startAt));

              final nextTomato = tomatoes.isNotEmpty ? tomatoes.first : null;

              final isNextTomatoDelayed = now.isAfter(nextTomato!.startAt);
              final cardTitle = isNextTomatoDelayed ? "DELAYED" : "NEXT UP";
              final cardTitleColor = isNextTomatoDelayed
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary;

              final otherTomatoes =
                  tomatoes.where((t) => t.id != nextTomato.id).toList();
              final otherUpcoming =
                  otherTomatoes.where((t) => now.isBefore(t.startAt)).toList();
              final otherDelayed =
                  otherTomatoes.where((t) => now.isAfter(t.startAt)).toList();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final now = DateTime.now().toUtc();
                                final isEarly =
                                    now.isBefore(nextTomato.startAt);
                                final isLate =
                                    now.isAfter(nextTomato.startAt);

                                Duration difference;
                                if (isEarly) {
                                  difference =
                                      nextTomato.startAt.difference(now);
                                } else {
                                  difference =
                                      now.difference(nextTomato.startAt);
                                }

                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.timer_sharp),
                                      SizedBox(width: 10),
                                      Text('Confirm Start'),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                          'You are about to start the timer for:'),
                                      const SizedBox(height: 8),
                                      Text(
                                        nextTomato.subject,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      if (isEarly) ...[
                                        const SizedBox(height: 16),
                                        Text.rich(
                                          TextSpan(
                                            text: 'You are ',
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: _formatDuration(
                                                    difference),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.green),
                                              ),
                                              const TextSpan(text: ' early.'),
                                            ],
                                          ),
                                        ),
                                      ] else if (isLate) ...[
                                        const SizedBox(height: 16),
                                        Text.rich(
                                          TextSpan(
                                            text: 'You are ',
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: _formatDuration(
                                                    difference),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.orange),
                                              ),
                                              const TextSpan(text: ' late.'),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: const Text('Start Now'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context
                                            .go('/timer/${nextTomato.id}');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cardTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: cardTitleColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nextTomato.subject,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 20.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Starts at: ${DateFormat('HH:mm').format(nextTomato.startAt)} UTC',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                          'Delayed',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                      ...otherDelayed.map((tomato) => Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange),
                              title: Text(tomato.subject),
                              trailing: Text(
                                  '${DateFormat('HH:mm').format(tomato.startAt)} UTC'),
                            ),
                          )),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                          'Upcoming',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...otherUpcoming.map((tomato) => Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: const Icon(
                                  Icons.watch_later_outlined,
                                  color: Colors.blue),
                              title: Text(tomato.subject),
                              trailing: Text(
                                  '${DateFormat('HH:mm').format(tomato.startAt)} UTC'),
                            ),
                          )),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
