import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../screen/first_screen.dart';
import '../screen/home_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 175,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SpotU', style: TextStyle(fontSize: 70, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
                  SizedBox(width: 25), // 텍스트와 아이콘 사이의 간격
                  Icon(FontAwesomeIcons.dumbbell, size: 60.0,),
                ]
            ),
              const SizedBox(height: 30,),
              const TextField(
                  decoration: InputDecoration(
                  labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)), // 둥근 모서리 설정
                    ),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                  decoration: InputDecoration(
                  labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)), // 둥근 모서리 설정
                    ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  const HomeScreen();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(450, 60),
                ),
                child: const Text('Sign In',style: TextStyle(fontSize: 20,),),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    // 잘못된 비밀번호 텍스트 클릭 시 동작
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FirstScreen()),
                    );
                  },
                  child: const Text(
                    'Forget Password?',
                    style: TextStyle(fontSize: 18,decoration: TextDecoration.underline),
                ),
              ),
            ),
              const SizedBox(height: 120,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("I'VE GOT YOUR", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900))
                ],
              ),
              Container(
                color: Colors.black,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("BACK", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white))
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}