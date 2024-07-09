import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import '../controller/task_controller.dart';
import '../model/task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> taskList = [];

  TextEditingController taskController = TextEditingController();
  TextEditingController taskController2 = TextEditingController();

  var _db = TaskController();


  @override
  void initState() {
    super.initState();
    getTasks();
  }

  /*Future<String> readFile() async {
    final file = await getFile();
    return file.readAsString();
  }*/

  Widget listItemBuild(BuildContext context, int index){

    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()), 
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        print("Direction: ${direction.toString()}");

        var lastRemovedTask;

        if (direction == DismissDirection.startToEnd) {
          //Atualizar Tarefa
          taskController2.text = taskList[index].title!;

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Atualizar Tarefa"),
                content: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Digite sua tarefa"
                  ),
                  controller: taskController2
                ),
                actions: [
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Atualizar"),
                    onPressed: (){
                      Task task = taskList[index];
                      String taskStr = taskController2.text;
                      task.title = taskStr;
                      updateTask(task);

                      Navigator.pop(context);
                    },
                  )
                ]    
              );
            }
          );
        } else if (direction == DismissDirection.endToStart) {
          // Excluindo a Tarefa
          lastRemovedTask = taskList[index];
          taskList.removeAt(index);
          bool isExecuted = false;  

          
          final snackBar = SnackBar(
            content: Text("Tarefa excluída!"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                isExecuted = true;
                setState((){
                  taskList.insert(index, lastRemovedTask);
                });
                //_saveFile();
              },
            )
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Timer(Duration(seconds: 5), () {
            print("After 5 seconds: $isExecuted");
            if (!isExecuted) deleteTask(lastRemovedTask.id!);
          });
        }
      },
      background: Container(
        color: Colors.green,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.edit, color: Colors.white,)
          ],
        )
      ),  
      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white,)
          ],
        )
      ),    
      child: CheckboxListTile(
            title: Text(taskList[index].title!),
            value: taskList[index].done == 1,
            onChanged: (bool? val) {
              Task task = taskList[index];
              task.done = val! ? 1 : 0;
              updateTask(task);
              setState((){});
              //_saveFile();
            }
          )
    );
  }
  
  void _insertTask() async {
    String taskStr = taskController.text;

    Task task = Task(taskStr, 0);
    int result = await _db.insertTask(task);
    print("Inserted: $result");

    getTasks();  
  }

  void getTasks() async {
    List tasks = await _db.getTasks();
    print("tasks: ${tasks.toString()}");

    taskList.clear();
    for (var taskMap in tasks) {
      Task task = Task.fromMap(taskMap);
      taskList.add(task);
    }

    setState((){});

  }

  void updateTask(Task task) async {
    int result = await _db.updateTask(task);

    print("Updated: $result");
    getTasks();
  }

  void deleteTask(int id) async {
    int result = await _db.deleteTask(id);
    print("Deleted: $id");
    getTasks();
  }
  /*void _updateTask(int index) {
    String taskStr = taskController2.text;
    
    setState((){
      taskList[index]["title"] = taskStr;
    });  

    _saveFile();
  }

  void _saveFile() async {
    final file = await getFile();
    String dataJson = jsonEncode(taskList);
    file.writeAsString(dataJson);
  }

  Future<File> getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    String pathFile = dir.path + "/task.json";
    return File(pathFile);
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){
          taskController.clear();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Digite sua tarefa"
                  ),
                  controller: taskController
                ),
                actions: [
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Salvar"),
                    onPressed: (){
                      _insertTask();
                      Navigator.pop(context);
                    },
                  )
                ]    
              );
            }
          );

        },
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: listItemBuild,
              )
            )
          ],
        )
      )
    );
  }
}