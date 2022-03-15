import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habit_tracker_flutter/models/task.dart';
import 'package:habit_tracker_flutter/ui/animations/animation_controller_state.dart';
import 'package:habit_tracker_flutter/ui/animations/custom_fade_transition.dart';
import 'package:habit_tracker_flutter/ui/animations/staggered_scale_animated_widget.dart';
import 'package:habit_tracker_flutter/ui/common_widgets/edit_task_button.dart';
import 'package:habit_tracker_flutter/ui/task/add_task_item.dart';
import 'package:habit_tracker_flutter/ui/task/task_with_name_loader.dart';

class TasksGrid extends StatefulWidget {
  const TasksGrid({Key? key, required this.tasks, this.onAddOrEditTask})
      : super(key: key);
  final List<Task> tasks;
  final VoidCallback? onAddOrEditTask;

  @override
  TasksGridState createState() => TasksGridState();
}

class TasksGridState extends State<TasksGrid>
    with SingleTickerProviderStateMixin {
  // * By declaring the [AnimationController] explicitly here, we ensure it does
  // * not get disposed when the [TasksGrid] is disposed (as it would be the
  // * case if we used the [AnimationControllerState] helper).
  // * This is necessary when the page flip effect takes place, as the parent
  // * widget still holds onto a GlobalKey, meaning that the animationController
  // * will be needed again later (hence it should **not** be disposed).
  late final animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 300));

  void enterEditMode() {
    animationController.forward();
  }

  void exitEditMode() {
    animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisSpacing = constraints.maxWidth * 0.05;
        final taskWidth = (constraints.maxWidth - crossAxisSpacing) / 2.0;
        const aspectRatio = 0.82;
        final taskHeight = taskWidth / aspectRatio;
        // Use max(x, 0.1) to prevent layout error when keyword is visible in modal page
        final mainAxisSpacing =
            max((constraints.maxHeight - taskHeight * 3) / 2.0, 0.1);
        final tasksLength =
            min(6, widget.tasks.length + 1); // 6 または length + 1を返す
        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            if (index == widget.tasks.length) {
              return CustomFadeTransition(
                animation: animationController,
                child: AddTaskItem(
                  onCompleted: () => print('Add New Item'),
                ),
              );
            }
            final task = widget.tasks[index];
            return TaskWithNameLoader(
              task: task,
              isEditing: false,
              editTaskButtonBuilder: (_) => StaggeredScaleAnimatedWidget(
                animation: animationController,
                index: index,
                child: EditTaskButton(
                  onPressed: () => print('Edit Item'),
                ),
              ),
            );
          },
          itemCount: tasksLength,
        );
      },
    );
  }
}
