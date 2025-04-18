import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TodoList extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final DateTime? taskDateTime;
  final String? priority; // Optional field
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  const TodoList({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.taskDateTime,
    this.priority,
    required this.onChanged,
    required this.deleteFunction,
  });

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = taskCompleted
        ? (isDarkMode ? Colors.black : Colors.teal)
        : (isDarkMode ? Colors.teal.shade700 : Colors.white);
    final textColor = taskCompleted ? Colors.white : (isDarkMode ? Colors.white : Colors.black);

    final formattedDate = taskDateTime != null
        ? DateFormat.yMMMd().add_jm().format(taskDateTime!.toLocal())
        : 'No time set';

    final isDueSoon = taskDateTime != null &&
        taskDateTime!.difference(DateTime.now()).inHours < 3 &&
        !taskCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(taskName),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onChanged?.call(!taskCompleted),
              icon: taskCompleted ? Icons.undo : Icons.check,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: taskCompleted ? 'Undo' : 'Complete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged?.call(!taskCompleted);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: taskCompleted,
                  onChanged: onChanged,
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          decoration: taskCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: textColor.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isDueSoon ? Colors.redAccent : textColor.withOpacity(0.7),
                              fontWeight: isDueSoon ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      if (priority != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Priority: $priority',
                            style: TextStyle(
                              color: _getPriorityColor(priority),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
