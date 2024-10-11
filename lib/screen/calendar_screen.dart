import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check your log"),
      ),
      body: Column(children: [
        TableCalendar(
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(
                  width: 2, // 가로줄 두께
                  color: Colors.grey, // 가로줄 색상
                  style: BorderStyle.solid,
                ),
                verticalInside: BorderSide(
                  width: 2, // 가로줄 두께
                  color: Colors.grey, // 가로줄 색상
                  style: BorderStyle.solid,
                ),
              ),
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child: Text('Exercise  log',
                              style: TextStyle(fontSize: 20))),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child:
                              Text('Diet log', style: TextStyle(fontSize: 20))),
                    ),
                  ],
                ),
              ],
            ))
      ]),
    );
  }
}
