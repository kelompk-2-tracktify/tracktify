import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/widgets/primary_button.dart';

const _outline = Color(0xFFCBD9EA);
const _secondary = Color(0xFF475A74);
const _bodyStyle = TextStyle(fontSize: 14, color: AppColors.text);
const _labelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.text,
);
const _fieldDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: _outline),
  ),
);

class ManageTaskScreen extends StatefulWidget {
  const ManageTaskScreen({super.key});

  @override
  State<ManageTaskScreen> createState() => _ManageTaskScreenState();
}

class _ManageTaskScreenState extends State<ManageTaskScreen> {
  static const _members = [
    'Raka Pratama',
    'Siti Aulia',
    'Dimas Wijaya',
    'Nadia Putri',
  ];

  final _title = TextEditingController(text: 'Integrasi Autentikasi Google');
  final _description = TextEditingController(
    text: 'Menghubungkan alur login dan pengelolaan profil dengan tautan akun Google.',
  );
  final _newSubtask = TextEditingController();
  final _titleFocus = FocusNode();
  final _selectedMembers = {'Raka Pratama', 'Siti Aulia'};
  final _subtasks = [
    'Siapkan OAuth Client ID di Google Cloud',
    'Uji alur tautkan & putuskan akun Google',
  ];
  DateTime _dueDate = DateTime(2026, 11, 22);
  bool _showTitleError = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _newSubtask.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null && mounted) setState(() => _dueDate = date);
  }

  void _addSubtask() {
    final title = _newSubtask.text.trim();
    if (title.isEmpty) return;
    setState(() => _subtasks.add(title));
    _newSubtask.clear();
  }

  void _save() {
    final missingTitle = _title.text.trim().isEmpty;
    if (missingTitle) {
      setState(() => _showTitleError = true);
      _titleFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            missingTitle
                ? 'Title wajib diisi.'
                : 'Form valid. Data masih berupa pratinjau.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            const Text(
              'Manage Task',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              children: [
                const Text('Title', style: _labelStyle),
                const SizedBox(height: 4),
                TextField(
                  style: _bodyStyle,
                  controller: _title,
                  focusNode: _titleFocus,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration.copyWith(
                    errorText: _showTitleError ? 'Title wajib diisi' : null,
                  ),
                  onChanged: (value) {
                    if (_showTitleError && value.trim().isNotEmpty) {
                      setState(() => _showTitleError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Task Description', style: _labelStyle),
                const SizedBox(height: 4),
                TextField(
                  style: _bodyStyle,
                  controller: _description,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _fieldDecoration,
                ),
                const SizedBox(height: 16),
                const Text('Due Date', style: _labelStyle),
                const SizedBox(height: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDueDate,
                  child: InputDecorator(
                    decoration: _fieldDecoration,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: _secondary,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            DateFormat('MM/dd/yyyy').format(_dueDate),
                            style: _bodyStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionCard(
              children: [
                const _CardHeader('Team Members', 'Tap to select'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final member in _members)
                      FilterChip(
                        label: Text(member),
                        selected: _selectedMembers.contains(member),
                        selectedColor: AppColors.navy,
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        showCheckmark: false,
                        side: BorderSide(
                          color: _selectedMembers.contains(member)
                              ? AppColors.navy
                              : _outline,
                        ),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedMembers.contains(member)
                              ? Colors.white
                              : AppColors.text,
                        ),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _selectedMembers.add(member);
                          } else {
                            _selectedMembers.remove(member);
                          }
                        }),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionCard(
              children: [
                _CardHeader('Subtask', '${_subtasks.length} item'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSubtask,
                        style: _bodyStyle,
                        decoration: _fieldDecoration.copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          hintText: 'Add a new subtask...',
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _addSubtask,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                for (var i = 0; i < _subtasks.length; i++) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.only(left: 12, right: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_subtasks[i], style: _bodyStyle)),
                        IconButton(
                          tooltip: 'Hapus ${_subtasks[i]}',
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: _secondary,
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              setState(() => _subtasks.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Save Task', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: _outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String caption;

  const _CardHeader(this.title, this.caption);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            caption,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, color: _secondary),
          ),
        ),
      ],
    );
  }
}
