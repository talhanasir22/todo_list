import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/tasks_provider.dart';

class CompletedTasks extends StatefulWidget {
  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  bool isDeleteVisible = false;
  int? selectedTaskIndex;

  // Function to toggle task completion status
  void _toggleTaskCompletion(int index) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    tasksProvider.moveTaskBack(index, context);
  }

  // Function to delete task
  void _deleteTask(int index) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    tasksProvider.removeCompletedTask(index, context);
    setState(() {
      selectedTaskIndex = null;
      isDeleteVisible = false;
    });
  }

  // Function to delete all tasks
  void _deleteAllTasks() {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    tasksProvider.removeAllCompletedTasks(context);
    setState(() {
      selectedTaskIndex = null;
      isDeleteVisible = false;
    });
  }

  // Show confirmation dialog for single task deletion
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTask(index); // Delete the task if confirmed
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  // Show confirmation dialog for deleting all tasks
  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete All"),
          content: const Text("Are you sure you want to delete all completed items?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAllTasks(); // Delete all tasks if confirmed
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete All", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF38b6ff),
        title: const Text(
          'Completed items',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _showDeleteAllConfirmationDialog,
          ),
        ],
      ),
      body: Consumer<TasksProvider>(
        builder: (context, taskModel, child) => Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: taskModel.completeList.isEmpty
              ? Center(
            child: Text(
              'No completed item',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
              : ListView.builder(
            itemCount: taskModel.completeList.length,
            itemBuilder: (context, index) {
              final task = taskModel.completeList[index];
              bool isSelected = selectedTaskIndex == index;

              return Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8.0, left: 12.0, right: 12.0),
                child: Container(
                  height: 70,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue,
                  ),
                  child: ListTile(
                    onLongPress: () {
                      setState(() {
                        selectedTaskIndex = index;
                        isDeleteVisible = true;
                      });
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        task,
                        style: const TextStyle(color: Colors.white),maxLines: 2,overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: isSelected && isDeleteVisible
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        _showDeleteConfirmationDialog(index);
                      },
                    )
                        : Checkbox(
                      value: true, // Checkbox should be checked because tasks are completed
                      onChanged: (bool? value) {
                        if (value != null && !value) {
                          _toggleTaskCompletion(index);
                        }
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
