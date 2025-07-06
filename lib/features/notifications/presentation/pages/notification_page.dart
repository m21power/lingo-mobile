import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingo/features/home/presentation/pages/home_page.dart';
import 'package:lingo/features/notifications/presentation/bloc/notification_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(MarkNotificationAsSeenEvent());
    context.read<NotificationBloc>().add(GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    String? currentLabel;
    bool isWaitingState = false;
    return RefreshIndicator(
      onRefresh: () async {
        print("Refreshing notifications...");
        context.read<NotificationBloc>().add(GetNotificationsEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),

        body: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            print("Notification state: $state");
            if (state is PairMeFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is PairMeSuccessState) {
              if (state.isWaiting) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You are now waiting for a pair!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pairing successful!"),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<NotificationBloc>().add(GetNotificationsEvent());
              }
            }
          },
          builder: (context, state) {
            print("Building NotificationPage with state: $state");
            if (state is NotificationInitial) {
              return Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }
            if (state is PairMeSuccessState) {
              isWaitingState = state.isWaiting;
            } else if (state is NotificationLoadedState) {
              isWaitingState = state.notificationReponse.isWaiting;
            } else if (state is PairMeFailureState) {
              isWaitingState = false;
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pair Me Button or Waiting Message
                  if (!isWaitingState)
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<NotificationBloc>().add(PairMeEvent());
                      },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Pair Me",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  else
                    Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.hourglass_top,
                              color: Colors.tealAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Looking for your partner...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "You can leave this page — once we find someone interested, we’ll pair you automatically. Come back later or pull down to refresh!",

                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Notifications List
                  Expanded(
                    child: state.notificationReponse!.notifications.isEmpty
                        ? ListView(
                            children: [
                              Center(
                                child: Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : // Add this above your ListView.separated:
                          ListView.separated(
                            itemCount:
                                state.notificationReponse!.notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final notif = state
                                  .notificationReponse!
                                  .notifications[index];

                              // Parse or set a fallback date for each notification:
                              final notifDate = DateTime.parse(notif.createdAt);
                              final label = getDateLabel(notifDate);

                              // Check if label changed for header display
                              final showHeader = label != currentLabel;
                              currentLabel = label;

                              final isSystem = notif.type == 'system';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showHeader) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.tealAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSystem
                                          ? const Color(0xFF1E1E1E)
                                          : const Color(0xFF263238),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSystem
                                            ? Colors.white12
                                            : Colors.teal.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.5,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (!isSystem) ...[
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const HomePage(
                                                        initialIndex: 1,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent
                                                  .withOpacity(0.5),
                                            ),
                                            child: Text(
                                              "Go to Chat",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String getDateLabel(DateTime notifDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(notifDate.year, notifDate.month, notifDate.day);

    final diffDays = today.difference(notifDay).inDays;

    if (diffDays == 0) return "Today";

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = endOfWeek.subtract(const Duration(days: 7));

    if (notifDay.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        notifDay.isBefore(endOfWeek.add(const Duration(days: 1)))) {
      // Notification is in this week (but not today)
      // Show weekday name e.g. "Monday"
      return DateFormat.E().format(notifDay);
    } else if (notifDay.isAfter(
          startOfLastWeek.subtract(const Duration(seconds: 1)),
        ) &&
        notifDay.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
      return "Last Week";
    } else if (notifDate.year == now.year && notifDate.month == now.month) {
      return "This Month";
    } else {
      return DateFormat('MMM d, yyyy').format(notifDay);
    }
  }
}
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      "type": "dailyPair",
      "message": "Your pair for today is @Sara_98. Click below to start chatting!",
      "buttonLabel": "Go to Chat",
      "date": "2025-06-29T14:30:00Z",
    },
    {
      "type": "system",
      "message": "Pairing starts at 9:00 AM daily. Make sure to be active!",
      "date": "2025-06-28T08:00:00Z",
    },
    {
      "type": "dailyPair",
      "message": "Your pair for Monday is @JohnDoe. Click below to start chatting!",
      "buttonLabel": "Go to Chat",
      "date": "2025-06-23T10:00:00Z",
    },
    {
      "type": "system",
      "message": "We will be performing maintenance next week.",
      "date": "2025-06-20T12:00:00Z",
    },
    {
      "type": "dailyPair",
      "message": "Your pair for last week was @EmmaW.",
      "buttonLabel": "Go to Chat",
      "date": "2025-06-18T09:00:00Z",
    },
  ];

  // Grouping logic function
  String getDateLabel(DateTime notifDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(notifDate.year, notifDate.month, notifDate.day);

    final diffDays = today.difference(notifDay).inDays;

    if (diffDays == 0) return "Today";

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = endOfWeek.subtract(const Duration(days: 7));

    if (notifDay.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        notifDay.isBefore(endOfWeek.add(const Duration(days: 1)))) {
      return DateFormat.E().format(notifDay); // Monday, Tuesday etc.
    } else if (notifDay.isAfter(startOfLastWeek.subtract(const Duration(seconds: 1))) &&
               notifDay.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
      return "Last Week";
    } else if (notifDate.year == now.year && notifDate.month == now.month) {
      return "This Month";
    } else {
      return DateFormat('MMM d, yyyy').format(notifDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort notifications descending by date
    notifications.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    String? currentLabel;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final date = DateTime.parse(notif['date']);
                final label = getDateLabel(date);

                // Show header if label changed
                final showHeader = label != currentLabel;
                currentLabel = label;

                final isSystem = notif['type'] == 'system';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['message'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('hh:mm a').format(date.toLocal()),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (!isSystem) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Navigate to chat
                                },
                                child: Text(notif['buttonLabel']),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }
}


*/