import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'todo_list.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  DateTime? _selectedDateTime;
  String _selectedPriority = 'Medium';
  final List<List<dynamic>> toDoList = [];
  final ConfettiController _confettiController =
  ConfettiController(duration: const Duration(seconds: 1));
  bool _hasShownConfetti = false;
  final Set<String> recentTasks = {};
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> quotes = [
    "You can do it!",
    "Stay focused and never give up!",
    "Make it happen!",
    "Progress, not perfection.",
    "Keep going, you're doing great!",
  ];

  void saveNewTask() {
    final taskText = _controller.text.trim();
    if (taskText.isEmpty) return;
    setState(() {
      final newTask = [
        taskText,
        false,
        _selectedDateTime,
        _selectedPriority,
      ];
      toDoList.insert(0, newTask);
      _listKey.currentState?.insertItem(0,
          duration: const Duration(milliseconds: 500));
      recentTasks.add(taskText);
      _controller.clear();
      _selectedDateTime = null;
      _selectedPriority = 'Medium';
      _hasShownConfetti = false;
    });
    Navigator.of(context).pop();
  }

  void deleteTask(int index) {
    final removedTask = toDoList[index];
    setState(() {
      toDoList.removeAt(index);
      _hasShownConfetti = false;
      _listKey.currentState?.removeItem(
        index,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: TodoList(
            taskName: removedTask[0],
            taskCompleted: removedTask[1],
            taskDateTime: removedTask[2],
            priority: removedTask[3],
            onChanged: (value) {},
            deleteFunction: (context) {},
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
      _hasShownConfetti = false;
    });
  }

  void deleteAllTasks() {
    if (toDoList.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Tasks"),
        content: const Text("Are you sure you want to delete all tasks?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (int i = toDoList.length - 1; i >= 0; i--) {
                  deleteTask(i);
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  void createTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setInnerState) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add a new task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(hintText: 'Task name'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Pick time: "),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setInnerState(() {
                              _selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: const Text('Select Date & Time'),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedPriority,
                  items: ['High', 'Medium', 'Low']
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text("Priority: $e")))
                      .toList(),
                  onChanged: (val) {
                    setInnerState(() {
                      _selectedPriority = val!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(onPressed: saveNewTask, child: const Text('Add Task')),
            ],
          );
        });
      },
    );
  }

  int get completedTasks =>
      toDoList.where((task) => task[1] == true).toList().length;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
    toDoList.isEmpty ? 0 : completedTasks / toDoList.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (toDoList.isNotEmpty &&
        completedTasks == toDoList.length &&
        !_hasShownConfetti) {
      _confettiController.play();
      _hasShownConfetti = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.teal.shade900 : Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              setState(() {
                themeNotifier.value =
                isDark ? ThemeMode.light : ThemeMode.dark;
              });
            },
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteAllTasks,
            tooltip: "Delete All Tasks",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTaskDialog,
        backgroundColor: isDark ? Colors.teal : Colors.green,
        child: const Text("+", style: TextStyle(fontSize: 24)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Center(
                  key: ValueKey<int>(DateTime.now().second),
                  child: Text(
                    quotes[DateTime.now().second % quotes.length],
                    style: const TextStyle(
                        fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Center(
                  key: ValueKey("$completedTasks/${toDoList.length}"),
                  child: Text(
                    "$completedTasks of ${toDoList.length} tasks done",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity:
                toDoList.isNotEmpty && completedTasks == toDoList.length
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "All tasks completed! Great job! 🎉",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.lightGreenAccent
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: toDoList.length,
                itemBuilder: (context, index, animation) {
                  final task = toDoList[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: TodoList(
                      taskName: task[0],
                      taskCompleted: task[1],
                      taskDateTime: task[2],
                      priority: task[3],
                      onChanged: (value) => checkBoxChanged(index),
                      deleteFunction: (context) => deleteTask(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 50,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
