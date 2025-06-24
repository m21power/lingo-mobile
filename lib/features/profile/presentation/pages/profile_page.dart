import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/core/constant/cache_manager.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:lingo/features/profile/presentation/pages/user_profile_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  bool get wantKeepAlive => true;
  String? originalNickname;
  bool isEdited = false;
  bool _isListenerAttached = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super to ensure keep alive works
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, profileState) {
        if (profileState.user != null) {
          _nicknameController.text = profileState.user!.nickname ?? "Unknown";
          originalNickname = profileState.user!.nickname;

          if (!_isListenerAttached) {
            _nicknameController.addListener(() {
              final current = _nicknameController.text;
              setState(() {
                isEdited = current != originalNickname;
              });
            });
            _isListenerAttached = true;
          }
        }

        if (profileState is ProfileErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileState.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        if (profileState is ProfileUpdateNicknameState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileState.message),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            originalNickname = _nicknameController.text;
            isEdited = false;
          });
        }
      },

      builder: (context, profileState) {
        if (profileState.user != null &&
            _nicknameController.text.isEmpty &&
            !_isListenerAttached) {
          _nicknameController.text = profileState.user!.nickname ?? "Unknown";
          originalNickname = profileState.user!.nickname;

          _nicknameController.addListener(() {
            final current = _nicknameController.text;
            setState(() {
              isEdited = current != originalNickname;
            });
          });
          _isListenerAttached = true;
        }
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: RefreshIndicator(
            onRefresh: () async {
              // Trigger the bloc events to refresh data
              context.read<ProfileBloc>().add(GetUserEvent());
              context.read<ProfileBloc>().add(GetRanksEvent());
              context.read<ProfileBloc>().add(GetConsistencyEvent());
            },
            child: profileState is GetProfileLoadingState
                ? Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: profileState.user != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        profileState.user?.photoUrl ??
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

                          const SizedBox(height: 10),
                          Text(
                            profileState.user?.username ?? 'Unknown',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 20),

                          /// Nickname Field
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: TextField(
                              controller: _nicknameController,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.tealAccent,
                              decoration: InputDecoration(
                                labelText: "Nickname",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),

                                enabledBorder:
                                    InputBorder.none, // 🔹 hide when idle
                                border: InputBorder
                                    .none, //   (also removes default)
                                focusedBorder: UnderlineInputBorder(
                                  // 🔹 show on focus
                                  borderSide: BorderSide(
                                    color: Colors.tealAccent.shade200,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// Save Button (only when edited)
                          if (isEdited)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_nicknameController.text.isEmpty) {
                                    setState(() {
                                      _nicknameController.text = "Unknown";
                                      originalNickname = "Unknown";
                                      isEdited = false;
                                    });
                                  } else {
                                    context.read<ProfileBloc>().add(
                                      UpdateNicknameEvent(
                                        _nicknameController.text,
                                      ),
                                    );
                                  }
                                },
                                icon: profileState is ProfileUpdateLoadingState
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Icon(Icons.save),
                                label: const Text("Save"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.tealAccent.shade700,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                _buildCalendar(profileState),

                                const SizedBox(height: 15),
                                _buildStats(profileState.user),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildRankTable(profileState.ranks),
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

  Widget _buildCalendar(ProfileState profileState) {
    return TableCalendar(
      availableGestures: AvailableGestures.none,
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
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
            for (var consistency in profileState.consistencies)
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

  Widget _buildRankTable(List<RankEntities> rankData) {
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
                color: user.nickname != originalNickname
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
                      if (user.nickname == originalNickname) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UserProfilePage(userId: user.userId);
                          },
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
