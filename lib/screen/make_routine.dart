import 'package:flutter/material.dart';
import 'package:group_app/screen/my_routine_screen.dart';


class MakeRoutine extends StatelessWidget{
  MakeRoutine({super.key});
  final ScrollController _scrollController = ScrollController();
  void dispose(){
    _scrollController.dispose();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make your Routine',
        style: TextStyle(fontSize:30, fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Scrollbar(
            thickness: 8.0,

            radius: const Radius.circular(10),
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children:<Widget>[
                  SizedBox(

                    width: 135,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Recommend',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Icon(Icons.bookmark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Chest',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Back',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Shoulder',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Legs',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Arms',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: ElevatedButton(
                        onPressed:() {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ABS',
                            style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
                  ),
              ],
              ),
            ),
          ),
          const SizedBox(height: 300),

          Column(
            children: [
              SizedBox(
                width: 90,
                height: 50,
                child: ElevatedButton(
                    onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder:(context) => MyRoutineScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Finish',
                        style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, ))),
              )
            ],
          )
          ],
      ),
    );
  }
}