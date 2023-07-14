import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/models/item.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Item> items;
  late TextEditingController newTaskCtrl;
  late bool isAddingTask;
  late IconData appBarIcon;

  @override
  void initState() {
    super.initState();
    items = [];
    newTaskCtrl = TextEditingController();
    isAddingTask = false;
    appBarIcon = Icons.add;
    load();
  }

  void toggleAddTask() {
    setState(() {
      if (isAddingTask) {
        if (newTaskCtrl.text.isNotEmpty) {
          items.add(Item(title: newTaskCtrl.text, done: false));
          save();
        }
        newTaskCtrl.text = "";
      }
      isAddingTask = !isAddingTask;
      appBarIcon = isAddingTask ? Icons.save : Icons.add;
    });
  }

  void remove(int index) {
    setState(() {
      items.removeAt(index);
      save();
    });
  }

  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable<dynamic> decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        items = result;
      });
    }
  }

  Future<void> save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isAddingTask
            ? TextFormField(
                autofocus: true,
                controller: newTaskCtrl,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
                decoration: const InputDecoration(
                  labelText: "Nova Tarefa",
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            : const Text("ToDo App"),
        actions: [
          IconButton(
            icon: Icon(appBarIcon),
            onPressed: toggleAddTask,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return Dismissible(
            key: Key(item.title!),
            background: Container(
              color: Colors.red.withOpacity(0.25),
            ),
            onDismissed: (direction) {
              remove(index);
            },
            child: CheckboxListTile(
              title: Text(item.title!),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value!;
                  save();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
