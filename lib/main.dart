import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: Colors.deepPurple[900],
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDocontroller = TextEditingController();
  // ignore: unused_field
  var _lastRemove = {};
  // ignore: unused_field
  var _lastRemovePosition = 0;

  var _task = [];

  void addlist() {
    setState(() {
      _task.add({
        "title": _toDocontroller.text,
        "ok": false,
      });

      _saveData();
      _toDocontroller.text = "";
    });
  }

  Widget _buildItem(context, index) {
    var item = _task[index];
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10.0),
        color: Colors.pink[700],
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: CheckboxListTile(
        title: Text(item["title"]),
        value: item["ok"],
        secondary: CircleAvatar(
          child: Icon(item["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (ok) {
          setState(() {
            item["ok"] = ok;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemove = Map.from(item);
          _lastRemovePosition = index;

          _task.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["title"]}\" removida!"),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _task.insert(_lastRemovePosition, _lastRemove);
                    _saveData();
                  });
                }),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<Null> _refresh() async {
    setState(() {
      _task.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });

      _task.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
  }

  // ignore: unused_element
  Future<File> _saveData() async {
    String data = json.encode(_task);
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/data.json");
    return file.writeAsString(data);
  }

  // ignore: unused_element
  Future<String> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/data.json");

      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData().then((data) {
      setState(() {
        _task = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          title: Text("Todo App"),
          backgroundColor: Colors.deepPurple[700],
          centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.deepPurple[400])),
                  controller: _toDocontroller,
                )),
                TextButton(
                  child: Text(
                    "ADD",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepPurple[600])),
                  onPressed: addlist,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _task.length,
                  itemBuilder: _buildItem),
            ),
          ),
        ],
      ),
    ));
  }

  getApplicationDocumentsDirectory() {}
}
