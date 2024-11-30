import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/tasks_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController updatetextController = TextEditingController();
  List<String> filteredList = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      onSearch(searchController.text);
    });
  }

  // Updated checkbox logic
  Widget checkbox(String task) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        bool isCompletedTask = tasksProvider.completeList.contains(task);
        bool isPendingTask = tasksProvider.taskList.contains(task);

        return Checkbox(
          value: isCompletedTask,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                if (isPendingTask) {
                  int taskIndex = tasksProvider.taskList.indexOf(task);
                  tasksProvider.toggleTaskCompletion(taskIndex,context);
                } else if (isCompletedTask) {
                  int taskIndex = tasksProvider.completeList.indexOf(task);
                  tasksProvider.toggleTaskCompletion(taskIndex, isCompleted: true, context);
                }
              });
            }
          },
          checkColor: Colors.white,
          activeColor: Colors.blue,
          side: const BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        );
      },
    );
  }

  // Search function for both taskList and completeList
  void onSearch(String query) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    final allTasks = [...tasksProvider.taskList, ...tasksProvider.completeList];

    setState(() {
      filteredList = allTasks
          .where((task) => task.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    });
  }

  Widget updateDialog(String task, int index, {bool isCompleted = false}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit To-do',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: updatetextController,
                autofocus: true,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add an To-do item',
                  hintStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      updatetextController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Update the task in the appropriate list
                  if (isCompleted) {
                    Provider.of<TasksProvider>(context, listen: false)
                        .updateTask(index, updatetextController.text, isCompleted: true,context);
                  } else {
                    Provider.of<TasksProvider>(context, listen: false)
                        .updateTask(index, updatetextController.text,context);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          cursorColor: Colors.white,
          autofocus: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF38b6ff),
      ),
      body: Consumer<TasksProvider>(
        builder: (context, taskModel, child) => Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: ListView.builder(
            itemCount: searchController.text.isEmpty ? taskModel.taskList.length : filteredList.length,
            itemBuilder: (context, index) {
              final task = searchController.text.isEmpty
                  ? taskModel.taskList[index]
                  : filteredList[index];
              bool isCompletedTask = taskModel.completeList.contains(task);
              int taskIndex = isCompletedTask
                  ? taskModel.completeList.indexOf(task)
                  : taskModel.taskList.indexOf(task);

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
                    onTap: () {
                      if (!isCompletedTask) { // Only show dialog if the task is not completed
                        updatetextController.text = task; // Pre-fill with the task content
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return updateDialog(task, taskIndex, isCompleted: isCompletedTask);
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Editing is not allowed for completed items.'),
                            duration:  Duration(milliseconds: 600),
                          ),
                        );
                      }
                    },

                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(task, style: const TextStyle(color: Colors.white),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    ),
                    trailing: checkbox(task), // Pass the task here
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
