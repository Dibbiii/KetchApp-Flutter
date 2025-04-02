import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> todos = ["Demo"];

  @override
  void initState() {
    todos.add("Compare il latte");
    todos.add("Compare il pane");
    todos.add("Fare colazione");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: todos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ElevatedButton(
            onPressed: () {
              setState(() {
                todos = [...todos, "New item"];
              });
            },
            child: Text("Aggiungi elemento"),
          );
        } else {
          return Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(todos[index - 1], style: TextStyle(color: Colors.black)),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.delete),
                  ),
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Attenzione"),
                          content: Text(
                            "Sei sicuro di voler eliminare l'elemento?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Annulla",
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  todos =
                                      todos
                                          .where(
                                            (item) => item != todos[index - 1],
                                          )
                                          .toList();
                                });
                              },
                              child: Text(
                                "Conferma",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    /**/
                  },
                ),
              ],
            ),
          );
        }
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }
}
