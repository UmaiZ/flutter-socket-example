import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectsocket();
  }

  var chatList = [];

  late IO.Socket socket;

  void connectsocket() {
    try {
      // Configure socket transports must be sepecified
      socket = io('http://127.0.0.1:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      // Connect to websocket
      socket.connect();

      // Handle socket events
      socket.on('connect', (_) {
        print('connect: ${socket.id}');
        socket.emit('getRoomChats', {'roomid': "63772c5ff4048eea6899f437"});

        socket.emit('messageseen',
            {'roomid': "63772c5ff4048eea6899f437", "partner": "umaizid2"});

        socket.on('messagerecieved', (data) {
          setState(() {
            chatList = data;
          });
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: chatList.length,
                itemBuilder: (context, i) {
                  return Align(
                    alignment: chatList[i]['partner'] == "umaizid2"
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.blue),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "${chatList[i]['partner']} := ${chatList[i]['message']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        chatList[i]['lastSeen']
                            ? Icon(Icons.done_all)
                            : Icon(Icons.done),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red)),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Message",
                  suffixIcon: GestureDetector(
                      onTap: () {
                        socket.emit('sendMessage', {
                          'message': _messageController.text,
                          'partner': 'umaizid2',
                          'roomid': "63772c5ff4048eea6899f437"
                        });
                        _messageController.clear();
                      },
                      child: Icon(Icons.send)),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
