import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Todo {
  Todo({required this.name, required this.checked});
  final String name;
  bool checked;
}

class TodoItem extends StatelessWidget {
  TodoItem({
    required this.todo,
    required this.onTodoChanged,
  }) : super(key: ObjectKey(todo));

  final Todo todo;
  final onTodoChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Icon(
          todo.checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: todo.checked ? Colors.blue : Colors.grey),
      title: Text(todo.name, style: _getTextStyle(todo.checked)),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos = <Todo>[];
  final Controller controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Obx(() => Text(
            "Todos: ${controller.closedTodosCount}/${controller.todosCount}")),
      ),
      body: Obx(() => ListView(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            children: controller.list.map((Todo todo) {
              return TodoItem(
                todo: todo,
                onTodoChanged: handleTodoChange,
              );
            }).toList(),
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: () => displayDialog(context),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  void handleTodoChange(Todo todo) {
    todo.checked = !todo.checked;
    controller.setClosedTodos();
    controller.list.refresh();
  }

  void addTodoItem(String name) {
    controller.list.add(Todo(name: name, checked: false));
    controller.setTodos();
    controller.textController.clear();
  }

  Future<void> displayDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar nova tarefa'),
          content: TextField(
            controller: controller.textController,
            decoration: const InputDecoration(hintText: 'Escreva sua tarefa'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Get.back();
                addTodoItem(controller.textController.text);
              },
            ),
          ],
        );
      },
    );
  }
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GetMaterialApp(
      title: "Todos",
      home: new TodoList(),
    );
  }
}

void main() => runApp(new TodoApp());

class Controller extends GetxController {
  final TextEditingController textController = TextEditingController();
  Rx<int> closedTodosCount = 0.obs;
  Rx<int> todosCount = 0.obs;
  RxList<Todo> list = <Todo>[].obs;

  setClosedTodos() => closedTodosCount.value =
      list.where((todo) => todo.checked == true).toList().length;
  setTodos() => todosCount.value = list.length;
}
