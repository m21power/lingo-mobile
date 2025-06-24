import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lingo/core/constant/cache_manager.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetRemoteUserEvent(userId: widget.userId));
    context.read<UserBloc>().add(
      GetRemoteUserRanksEvent(userId: widget.userId),
    );
    context.read<UserBloc>().add(
      GetRemoteUserConsistencyEvent(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, userState) {},
      builder: (context, userState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          body: RefreshIndicator(
            onRefresh: () async {
              // Trigger the bloc events to refresh data
              context.read<UserBloc>().add(
                GetRemoteUserEvent(userId: widget.userId),
              );
              context.read<UserBloc>().add(
                GetRemoteUserRanksEvent(userId: widget.userId),
              );
              context.read<UserBloc>().add(
                GetRemoteUserConsistencyEvent(userId: widget.userId),
              );
            },
            child: userState is UserInitial
                ? Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: userState.user != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        userState.user?.photoUrl ??
                                        'https://res.cloudinary.com/dl6vahv6t/image/upload/v1750591236/profile_2309847305_kfm5r6.jpg',
                                    cacheManager:
                                        MyCacheManager(), // ✅ correct usage
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: imageProvider,
                                        ),
                                    placeholder: (context, url) => CircleAvatar(
                                      radius: 50,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                          radius: 50,
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundImage: AssetImage(
                                      "assets/naruto.jpg",
                                    ),
                                  ),
                          ),

                          // const SizedBox(height: 10),
                          // Text(
                          //   userState.user?.username ?? 'Unknown',
                          //   style: TextStyle(color: Colors.white, fontSize: 18),
                          // ),
                          const SizedBox(height: 20),

                          /// Nickname Field (read-only)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: TextField(
                              controller: TextEditingController(
                                text: userState.user?.nickname ?? "Unknown",
                              ),
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.tealAccent,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Nickname",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.tealAccent.shade200,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                _buildCalendar(userState),

                                const SizedBox(height: 15),
                                _buildStats(userState.user),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildRankTable(
                              userState.ranks,
                              userState.user,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar(UserState userState) {
    return TableCalendar(
      availableGestures: AvailableGestures.none,
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white70),
        weekendTextStyle: const TextStyle(color: Colors.white54),
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.redAccent),
        weekdayStyle: TextStyle(color: Colors.white70),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          Map<DateTime, int> practiceData = {
            for (var consistency in userState.consistencies)
              DateTime.utc(
                consistency.date.year,
                consistency.date.month,
                consistency.date.day,
              ): consistency.score,
          };
          int? practice =
              practiceData[DateTime.utc(day.year, day.month, day.day)];
          if (practice != null) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: practice == 0 ? Colors.redAccent : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: practice == 0
                    ? Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      )
                    : Icon(
                        FontAwesomeIcons.fire,
                        color: Colors.orange,
                        size: 16,
                      ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStats(User? user) {
    double score =
        (user?.attendance ?? 0) * 5 +
        (user?.participatedCount ?? 0) * 2 -
        (user?.missCount ?? 0) * 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Attendance: ${user != null ? user.attendance : 0}",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(width: 2),
            Icon(FontAwesomeIcons.fire, color: Colors.orange, size: 14),
          ],
        ),
        SizedBox(width: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Missed: ${user != null ? user.missCount : 0}",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(width: 2),
            Icon(Icons.close, color: Colors.redAccent, size: 14),
          ],
        ),
        SizedBox(width: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Score: ${score.toStringAsFixed(0)}",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(width: 2),
            Icon(Icons.star, color: Colors.orangeAccent, size: 14),
          ],
        ),
      ],
    );
  }

  Widget _buildRankTable(List<RankEntities> rankData, User? user2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rank Table",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 10),

        Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(), // Rank
            1: FlexColumnWidth(), // Username + Avatar
            2: IntrinsicColumnWidth(), //  score
          },
          children: rankData.map((user) {
            return TableRow(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: user.userId != user2?.id
                    ? Colors.transparent
                    : Colors.tealAccent.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(color: Colors.white24, width: 0.5),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "${user.rank}.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),

                  child: GestureDetector(
                    onTap: () {
                      // Navigate to user profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(userId: user.userId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  user.photoUrl,
                                  cacheManager: MyCacheManager(),
                                )
                              : AssetImage("assets/naruto.jpg"),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            user.nickname,
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${user.score.toStringAsFixed(0)}",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.star, color: Colors.orangeAccent, size: 14),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
