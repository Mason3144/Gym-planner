import 'dart:async';
import 'dart:html';

import 'package:gymming/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}



class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();

  int seconds = 0, minutes = 0;
  String digitSeconds ="00", digitMinutes ="00";
  Timer? timer;
  bool started = false;



  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gym planner"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,

            //Day Changed
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },

            eventLoader: _getEventsfromDay,

            //To style the Calendar
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          ..._getEventsfromDay(selectedDay).map(
                (Event event) => ListTile(
              title: Text(
                event.title,
              ),
            ),
          ),
        ],
      ),


        floatingActionButton: Stack(

          children: <Widget>[

            Padding(padding: EdgeInsets.only(left:31),
              child: Align(


                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: ()=>{
                    showDialog(
                        barrierDismissible: false,
                    context:context,
                    builder:(context)=> StatefulBuilder(builder: (context, setState)=>
                        AlertDialog(

                      title:Text("Set the timer"),
                      content:Text("$digitMinutes:$digitSeconds", textAlign: TextAlign.center,style: TextStyle(fontSize: 50.0),),
                      actions:[
                        TextButton(
                          child: Text("Return"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text("Reset"),
                          onPressed: () {
                            timer!.cancel();
                            setState((){
                              seconds = 0;
                              minutes = 0;

                              digitSeconds ="00";
                              digitMinutes ="00";

                              started = false;
                            });
                          },
                        ),
                        TextButton(
                          onPressed: () {

                            if(!started){
                              timer = Timer.periodic(Duration(seconds:1), (timer){
                                int localSeconds = seconds+1;
                                int localMinutes = minutes;
                                if(localSeconds > 59){
                                  localMinutes++;
                                  localSeconds=0;
                                }
                                setState((){
                                  seconds = localSeconds;
                                  minutes = localMinutes;
                                  digitSeconds = (seconds >=10)?"$seconds":"0$seconds";
                                  digitMinutes = (minutes >=10)?"$minutes":"0$minutes";
                                });
                              });
                              setState((){
                                started=true;
                              });
                            }else{
                              timer!.cancel();
                              setState((){
                                started=false;
                              });
                            }

                          },
                          child: Text(
                              (!started)?"Start":"Pause"
                          ),
                        )
                      ]
                    ))
                  ),},
                  child: Icon(Icons.timer),),
              ),),




            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: ()=> showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Name of exercise, Number of cicles, Number of sets"),
                    content: TextFormField(
                      controller: _eventController,
                    ),
                    actions: [
                      TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                      if (_eventController.text.isEmpty) {

                      } else {
                      if (selectedEvents[selectedDay] != null) {
                      selectedEvents[selectedDay]!.add(
                      Event(title: _eventController.text),
                      );
                      } else {
                      selectedEvents[selectedDay] = [
                      Event(title: _eventController.text)
                      ];
                      }

                      }
                      Navigator.pop(context);
                      _eventController.clear();
                      setState((){});
                      return;
                  },
                  ),
                  ],
                  ),
                  ),
                label: Text("Describe your workout"),
                icon: Icon(Icons.add),),
            ),
        //       ))],
        // )

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: Text("Name of exercise, Number of cicles, Number of sets"),
      //       content: TextFormField(
      //         controller: _eventController,
      //       ),
      //       actions: [
      //         TextButton(
      //           child: Text("Cancel"),
      //           onPressed: () => Navigator.pop(context),
      //         ),
      //         TextButton(
      //           child: Text("Ok"),
      //           onPressed: () {
      //             if (_eventController.text.isEmpty) {
      //
      //             } else {
      //               if (selectedEvents[selectedDay] != null) {
      //                 selectedEvents[selectedDay]!.add(
      //                   Event(title: _eventController.text),
      //                 );
      //               } else {
      //                 selectedEvents[selectedDay] = [
      //                   Event(title: _eventController.text)
      //                 ];
      //               }
      //
      //             }
      //             Navigator.pop(context);
      //             _eventController.clear();
      //             setState((){});
      //             return;
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      //   label: Text("Describe your workout"),
      //   icon: Icon(Icons.add),
      // ),



  ]));
  }
}