import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator.pop()을 사용하기 위함

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 20.0),
            child: const Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(  // ScrollView 추가
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: <Widget>[
                const Center(
                  child: Text(
                    'User Data',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildUserStatus(
                      label: 'Weight',
                      imagePath: 'assets/images/weight.png',
                      unitlabel: 'KG',
                    ),
                    const SizedBox(width: 20),
                    buildUserStatus(
                      label: 'Muscle Mass',
                      imagePath: 'assets/images/muscle mass.png',
                      unitlabel: 'KG',
                    ),
                    const SizedBox(width: 20),
                    buildUserStatus(
                      label: 'Body Fat',
                      imagePath: 'assets/images/body fat.png',
                      unitlabel: '%',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        children:[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor : Colors.grey
                              ),
                              onPressed: (){
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.bold),
                              )
                          )
                        ]
                    )
                  ],
                ),
                const SizedBox(height: 200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/exit.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onDoubleTap: (){
                            SystemNavigator.pop();
                          },
                          child: const Text(
                            'Exit app',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 30),
                        const Text(
                          'Change Password',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserStatus({
    required String label,
    required String imagePath,
    required String unitlabel,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Image.asset(
          imagePath,
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 5),
        NumberInputBox(labelText: unitlabel),
      ],
    );

  }
}

class NumberInputBox extends StatelessWidget {
  final String labelText;
  const NumberInputBox({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,  // 정사각형 너비
      height: 50, // 정사각형 높이
      decoration: BoxDecoration(
        color: Colors.white, // 박스 내부 색상
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(
            child : NumberInputField(),
          ),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                labelText,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              )
          )

        ],// 숫자 입력 필드 추가
      ),
    );
  }
}
class NumberInputField extends StatelessWidget {
  const NumberInputField({super.key});


  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      // 숫자 입력만 허용
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능하도록 필터링
      ],
      textAlign: TextAlign.center,
      // 숫자를 가운데 정렬
      style: const TextStyle(color: Colors.black, fontSize: 12),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
    );
  }
}