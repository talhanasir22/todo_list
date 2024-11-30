import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/search_screen.dart';
import 'package:todo_list/tasks_provider.dart';

import 'completed_tasks_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController taskController = TextEditingController();
  TextEditingController updatetextController = TextEditingController();
  bool istickmarkVisible = false;

  Widget checkbox(int index) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        return Checkbox(
          value: tasksProvider.taskCompletionStatus[index],
          onChanged: (bool? value) {
            if (value != null) {
              tasksProvider.toggleTaskCompletion(index,context);
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
                minLines: 1,
                maxLines: 5,
                autofocus: true,
                controller: updatetextController,
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
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                        .updateTask(index, updatetextController.text,context,
                        isCompleted: true);
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
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
        backgroundColor: const Color(0xFF38b6ff),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundImage: AssetImage('assets/Images/Logo.png')),
                SizedBox(width: 8),
                Text('ToDo Nest', style: TextStyle(color: Colors.white)),
              ],
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()));
              },
              icon: const Icon(Icons.search),
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Consumer<TasksProvider>(
        builder: (context, taskModel, child) => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: taskModel.taskList.isEmpty
                  ? Center(
                child: Text(
                  'Nothing to do',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: taskModel.taskList.length,
                itemBuilder: (context, index) {
                  String task = taskModel.taskList[index];
                  bool isCompletedTask = taskModel.taskCompletionStatus[index];

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
                          updatetextController.text = task; // Pre-fill the task
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return updateDialog(task, index,
                                  isCompleted: isCompletedTask);
                            },
                          );
                        },
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(taskModel.taskList[index],
                              style: const TextStyle(color: Colors.white,),overflow: TextOverflow.ellipsis,maxLines: 2,),
                        ),
                        trailing: checkbox(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF38b6ff),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onSubmitted: (value) {
                    String text = value.trim();
                    if (text.isNotEmpty) {
                      taskModel.add(text, context);
                      taskController.clear();
                      setState(() {
                        istickmarkVisible = false;
                      });
                    }
                  },

                  cursorColor: Colors.white,
                  controller: taskController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Add an To-do item here...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.task, color: Colors.white),
                    suffixIcon: istickmarkVisible
                        ? IconButton(
                      onPressed: () {
                        String text = taskController.text.toString();
                        if (text.isNotEmpty) {
                          taskModel.add(text, context);
                          taskController.clear();
                          setState(() {
                            istickmarkVisible = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.done, color: Colors.white),
                    )
                        : null,
                  ),
                  onChanged: (text) {
                    setState(() {
                      istickmarkVisible = text.isNotEmpty;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    child:  CompletedTasks(),
                    type: PageTransitionType.rightToLeft));
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF38b6ff),
          child: const Icon(Icons.forward_rounded, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
