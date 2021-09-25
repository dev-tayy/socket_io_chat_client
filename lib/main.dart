import 'package:flutter/material.dart';
import 'chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegScreen(),
    );
  }
}

class RegScreen extends StatefulWidget {
  RegScreen({Key key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  void startChat() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      username: _nameController.text.trim(),
                    )));
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEAEFF2),
          height: size.height,
          width: size.width,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    width: size.width * 0.80,
                    child: TextField(
                      controller: _nameController,
                      cursorColor: Colors.black,
                      autofocus: false,
                      style: const TextStyle(fontSize: 18),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your username',
                        hintStyle: const TextStyle(fontSize: 15),
                        labelStyle: const TextStyle(
                            fontSize: 15, color: const Color(0xFF271160)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: const Color(0xFF271160))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: const Color(0xFF271160))),
                        disabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: const Color(0xFF271160))),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  width: size.width * 0.80,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF271160)),
                    onPressed: startChat,
                    child: _isLoading
                        ? Transform.scale(
                            scale: 0.7,
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.5),
                          )
                        : Text('Start Chat',
                            style: const TextStyle(
                                fontSize: 17, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
