
import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

const navy = Color(0xFF253248);
const muted = Color(0xFF778397);
const background = Color(0xFFF7F8FA);

const laneNames = ['未着手', '進行中', '提出済み'];
const laneDescriptions = [
  'これから取り組む課題',
  'いま頑張っている課題',
  '終わった課題',
];

const laneColors = [
  Color(0xFFF0F2F5),
  Color(0xFFFFF2E6),
  Color(0xFFE9F5EF),
];

const accentColors = [
  Color(0xFF667085),
  Color(0xFFB96B2B),
  Color(0xFF388267),
];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;

  const KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();

  void add() {
    final text = input.text.trim();
    if (text.isEmpty) return;

    widget.vm.add(text);
    input.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> edit(Task task) async {
    final controller = TextEditingController(text: task.title);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('課題を編集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: '課題名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim(),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      widget.vm.rename(task, result);
    }
  }

  Future<void> delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('課題を削除しますか？'),
        content: Text('「${task.title}」を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.vm.remove(task);
    }
  }

  Widget taskCard(Task task) {
    final status = task.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: navy,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: '課題の操作',
                  icon: const Icon(
                    Icons.more_horiz,
                    color: muted,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') edit(task);
                    if (value == 'delete') delete(task);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('編集'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('削除'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (status > 0)
                  IconButton.outlined(
                    tooltip: '前の状態へ',
                    onPressed: () =>
                        widget.vm.move(task, status - 1),
                    icon: const Icon(Icons.arrow_back, size: 18),
                  ),
                const Spacer(),
                if (status < 2)
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        widget.vm.move(task, status + 1),
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                    ),
                    label: Text(
                      status == 0 ? '取り組む' : '提出済みにする',
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF388267),
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '完了！',
                        style: TextStyle(
                          color: Color(0xFF388267),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget lane(int status) {
    final tasks = widget.vm.tasks
        .where((task) => task.status == status)
        .toList();

    return Container(
      width: 310,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: laneColors[status],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 0
                    ? Icons.radio_button_unchecked
                    : status == 1
                        ? Icons.timelapse
                        : Icons.check_circle_outline,
                color: accentColors[status],
                size: 21,
              ),
              const SizedBox(width: 9),
              Text(
                laneNames[status],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Text(
                  '${tasks.length}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            laneDescriptions[status],
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'まだ課題はありません',
                      style: TextStyle(
                        color: accentColors[status],
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, index) =>
                        taskCard(tasks[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget progressSection() {
    final total = widget.vm.tasks.length;
    final completed = widget.vm.tasks
        .where((task) => task.status == 2)
        .length;

    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9ECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PROGRESS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: muted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$completed / $total',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '課題完了',
                style: TextStyle(color: muted),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388267),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFEDF0F2),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF388267),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9ECF0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: input,
              onSubmitted: (_) => add(),
              decoration: const InputDecoration(
                hintText: '新しい課題を追加する...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: input,
            builder: (_, value, __) => FilledButton(
              onPressed:
                  value.text.trim().isEmpty ? null : add,
              child: const Text('追加'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.vm,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth > 1100
                  ? 1100.0
                  : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'STUDY FLOW',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          '課題タスク',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '今やらないで、いつやるの！',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),
                        progressSection(),
                        const SizedBox(height: 16),
                        inputSection(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, area) {
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (var s = 0; s < 3; s++) ...[
                                    SizedBox(
                                      height: area.maxHeight,
                                      child: lane(s),
                                    ),
                                    if (s < 2)
                                      const SizedBox(width: 14),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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
