import 'package:flutter/material.dart';

import '../../domain/record_type.dart';
import '../../../../shared/design/app_colors.dart';

Future<void> showQuickRecordSheet(
  BuildContext context, {
  RecordType? initialType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _QuickRecordSheet(initialType: initialType ?? RecordType.exercise);
    },
  );
}

class _QuickRecordSheet extends StatefulWidget {
  const _QuickRecordSheet({required this.initialType});

  final RecordType initialType;

  @override
  State<_QuickRecordSheet> createState() => _QuickRecordSheetState();
}

class _QuickRecordSheetState extends State<_QuickRecordSheet> {
  late RecordType _type = widget.initialType;
  final TextEditingController _controller = TextEditingController();
  String _value = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '记录${_type.label}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      final type = RecordType.values[index];
                      final selected = type == _type;
                      return ChoiceChip(
                        selected: selected,
                        onSelected: (_) => setState(() => _type = type),
                        label: Text(type.label),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : Colors.black54,
                        ),
                        selectedColor: type.color,
                        backgroundColor: Colors.grey.shade100,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: RecordType.values.length,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  onChanged: (value) => setState(() => _value = value),
                  decoration: InputDecoration(
                    labelText: '内容详情',
                    hintText: '写点什么...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _value.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.candyPink,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('保存'),
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
