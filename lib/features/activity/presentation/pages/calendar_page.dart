import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hashiru/core/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/activity_bloc.dart';
import '../bloc/activity_event.dart';
import '../bloc/activity_state.dart';
import '../widgets/activity_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _load();
  }

  void _load() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      context.read<ActivityBloc>().add(ActivitiesLoadRequested(userId: uid));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  List _getActivitiesForDay(DateTime day, ActivityState state) {
    if (state is ActivitiesLoaded) {
      return state.activities.where((activity) {
        return isSameDay(activity.startTime, day);
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityError) {
            return Center(child: Text(state.message));
          }

          final selectedActivities =
              _getActivitiesForDay(_selectedDay ?? _focusedDay, state);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.mainred.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color:
                        colorScheme.primaryContainer, // or any color you'd like
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppTheme.lightOrange,
                  ),
                ),
                eventLoader: (day) => _getActivitiesForDay(day, state),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        // bottom: 4,
                        child: SvgPicture.asset(
                          'assets/icons/running.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            AppTheme.darkYellow,
                            BlendMode.srcIn,
                          ),
                        ),
                        // child: Container(
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     color: AppTheme.darkYellow,
                        //   ),
                        //   width: 18,
                        //   height: 18,
                        // ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: selectedActivities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy,
                                size: 64,
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No activities on this date',
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedActivities.length,
                        itemBuilder: (context, i) {
                          final act = selectedActivities[i];
                          return ActivityCard(
                            activity: act,
                            onTap: () async {
                              await context.push('/activity/${act.id}');
                              if (mounted) _load();
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
