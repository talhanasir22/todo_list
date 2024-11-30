import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksProvider extends ChangeNotifier {
  List<String> _taskList = [];
  List<String> _completeList = [];
  List<bool> _taskCompletionStatus = [];

  List<String> get taskList => _taskList;
  List<String> get completeList => _completeList;
  List<bool> get taskCompletionStatus => _taskCompletionStatus;

  TasksProvider() {
    loadTasks();
  }

  // Add a new task
  void add(String task, BuildContext context) async {
    _taskList.add(task);
    _taskCompletionStatus.add(false);
    showSnackBar(context, 'Added successfully');
    await saveTasks();
    notifyListeners();
  }

  // Toggle task completion
  void toggleTaskCompletion(int index, BuildContext context, {bool isCompleted = false}) async {
    if (!isCompleted) {
      // Marking task as complete
      _completeList.add(_taskList[index]);
      _taskList.removeAt(index);
      _taskCompletionStatus.removeAt(index);
      showSnackBar(context, 'Marked as completed');
    } else {
      // Marking task as incomplete
      _taskList.add(_completeList[index]);
      _completeList.removeAt(index);
      _taskCompletionStatus.add(false);
      showSnackBar(context, 'Marked as incomplete');
    }

    await saveTasks();
    notifyListeners();
  }

  // Remove completed task
  void removeCompletedTask(int index, BuildContext context) async {
    if (index >= 0 && index < _completeList.length) {
      _completeList.removeAt(index);
      showSnackBar(context, 'Deleted successfully');
      await saveTasks();
      notifyListeners();
    }
  }
  void removeAllCompletedTasks(BuildContext context) async{
    completeList.clear();
    await saveTasks();
    notifyListeners(); // Notify listeners to update UI
  }

  // Move task back to incomplete list
  void moveTaskBack(int index, BuildContext context) async {
    if (index >= 0 && index < _completeList.length) {
      String task = _completeList[index];
      _taskList.add(task);
      _taskCompletionStatus.add(false);
      _completeList.removeAt(index);
      showSnackBar(context, 'Marked as incomplete');
      await saveTasks();
      notifyListeners();
    }
  }

  // Update task
  void updateTask(int index, String newTask, BuildContext context, {bool isCompleted = false}) async {
    if (!isCompleted) {
      // Update task in the task list (incomplete tasks)
      if (index >= 0 && index < _taskList.length) {
        _taskList[index] = newTask;
        showSnackBar(context, 'Updated successfully');
        await saveTasks();
        notifyListeners();
      }
    } else {
      // Update task in the complete list (completed tasks)
      if (index >= 0 && index < _completeList.length) {
        _completeList[index] = newTask;
        showSnackBar(context, 'Updated successfully');
        await saveTasks();
        notifyListeners();
      }
    }
  }

  // Add completed tasks
  void addCompleteTasks(String task) async {
    if (!_completeList.contains(task)) {
      _completeList.add(task);
      await saveTasks();
      notifyListeners();
    }
  }

  // Clear all tasks
  void clearAllTasks() async {
    _taskList.clear();
    _completeList.clear();
    _taskCompletionStatus.clear();
    await saveTasks();
    notifyListeners();
  }

  // Save tasks to SharedPreferences
  Future<void> saveTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('taskList', _taskList);
      await prefs.setStringList('completeList', _completeList);
      await prefs.setStringList('taskCompletionStatus',
          _taskCompletionStatus.map((status) => status.toString()).toList());
    } catch (e) {
      print("Error saving tasks: $e");
      // Optionally show a message to the user
    }
  }

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _taskList = prefs.getStringList('taskList') ?? [];
      _completeList = prefs.getStringList('completeList') ?? [];
      _taskCompletionStatus = (prefs.getStringList('taskCompletionStatus') ?? [])
          .map((status) => status == 'true')
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error loading tasks: $e");

    }
  }

  // Show SnackBar
  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 600),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
