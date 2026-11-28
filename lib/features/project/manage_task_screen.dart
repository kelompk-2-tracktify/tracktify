import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/widgets/primary_button.dart';
import '../task_list/task_list_providers.dart';
import 'project_repository.dart';

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

class ManageTaskScreen extends ConsumerStatefulWidget {
  const ManageTaskScreen({super.key});

  @override
  ConsumerState<ManageTaskScreen> createState() => _ManageTaskScreenState();
}

class _ManageTaskScreenState extends ConsumerState<ManageTaskScreen> {
  final _emailSearch = TextEditingController();
  final _selectedNames = <String, String>{};
  Timer? _debounce;
  Future<List<Map<String, dynamic>>>? _results;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _newSubtask = TextEditingController();
  final _descriptionFocus = FocusNode();
  final _subtaskFocus = FocusNode();
  final _titleFocus = FocusNode();
  final _selectedMemberIds = <String>{};
  final _subtasks = <String>[];
  DateTime? _dueDate;
  bool _showTitleError = false;
  bool _saving = false;

  void _search(String value) {
    _debounce?.cancel();
    setState(() => _results = null);
    final query = value.trim();
    if (query.length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _results = ref
            .read(projectRepositoryProvider)
            .searchProfilesByEmail(query);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailSearch.dispose();
    _title.dispose();
    _description.dispose();
    _newSubtask.dispose();
    _descriptionFocus.dispose();
    _subtaskFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null && mounted) setState(() => _dueDate = date);
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _title.text.trim();
    if (name.isEmpty) {
      setState(() => _showTitleError = true);
      _titleFocus.requestFocus();
      _showMessage('Enter a project title.');
      return;
    }

    final description = _description.text.trim();
    if (description.isEmpty) {
      _descriptionFocus.requestFocus();
      _showMessage('Enter a project description.');
      return;
    }
    if (_dueDate == null) {
      _showMessage('Select a due date.');
      return;
    }
    if (_subtasks.isEmpty) {
      _subtaskFocus.requestFocus();
      _showMessage('Add at least one subtask.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await ref
          .read(projectRepositoryProvider)
          .createProject(
            name: name,
            description: description,
            dueDate: _dueDate,
            memberIds: _selectedMemberIds.toList(),
            subtasks: List.of(_subtasks),
          );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _showMessage('Could not save the project. Please try again.');
      }
      return;
    }

    container.invalidate(projectsProvider);
    if (!mounted) return;
    _debounce?.cancel();
    _emailSearch.clear();
    _title.clear();
    _description.clear();
    _newSubtask.clear();
    setState(() {
      _saving = false;
      _results = null;
      _selectedMemberIds.clear();
      _selectedNames.clear();
      _subtasks.clear();
      _dueDate = null;
    });
    _showMessage('Project saved.');
    context.go('/home');
  }

  Widget _profileTile(Map<String, dynamic> profile) {
    final id = profile['id'] as String;
    final name = (profile['full_name'] as String?)?.trim() ?? '';
    final label = name.isEmpty ? 'Unnamed member' : name;
    final words = name.split(RegExp(r'\s+'));
    final initials = words.length == 1
        ? name.characters.take(2).toString()
        : words.first.characters.first + words.last.characters.first;
    final url = Uri.tryParse((profile['avatar_url'] as String?)?.trim() ?? '');
    final hasPhoto =
        url != null &&
        url.host.isNotEmpty &&
        (url.scheme == 'https' || url.scheme == 'http');
    final selected = _selectedMemberIds.contains(id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        foregroundImage: hasPhoto ? NetworkImage(url.toString()) : null,
        onForegroundImageError: hasPhoto ? (_, _) {} : null,
        child: Text(initials.isEmpty ? '?' : initials.toUpperCase()),
      ),
      title: Text(label),
      subtitle: Text(profile['email'] as String),
      trailing: Icon(selected ? Icons.check_circle : Icons.add_circle_outline),
      selected: selected,
      onTap: selected
          ? null
          : () => setState(() {
              _selectedMemberIds.add(id);
              _selectedNames[id] = label;
            }),
    );
  }

  void _addSubtask() {
    final title = _newSubtask.text.trim();
    if (title.isEmpty) return;
    setState(() => _subtasks.add(title));
    _newSubtask.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                    hintText: 'Enter a project title',
                    errorText: _showTitleError
                        ? 'Enter a project title'
                        : null,
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
                  focusNode: _descriptionFocus,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _fieldDecoration.copyWith(
                    hintText: 'Enter a project description',
                  ),
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
                            _dueDate == null
                                ? 'Select a due date'
                                : DateFormat('MM/dd/yyyy').format(_dueDate!),
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
                const Text(
                  'Team Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailSearch,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _fieldDecoration.copyWith(
                    hintText: 'Search by email...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _search,
                ),
                const SizedBox(height: 8),
                if (_emailSearch.text.trim().length < 3)
                  const Text(
                    'Enter at least 3 characters to search for a team member.',
                    style: _bodyStyle,
                  )
                else
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _results,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            const Text('Could not search for team members.'),
                            TextButton(
                              onPressed: () => _search(_emailSearch.text),
                              child: const Text('Try again'),
                            ),
                          ],
                        );
                      }
                      final profiles = snapshot.requireData;
                      if (profiles.isEmpty) {
                        return const Text('No matching email addresses found.');
                      }
                      return Material(
                        type: MaterialType.transparency,
                        child: Column(
                          children: profiles.map(_profileTile).toList(),
                        ),
                      );
                    },
                  ),
                const Divider(),
                if (_selectedMemberIds.isEmpty)
                  const Text(
                    'No team members selected.',
                    style: _bodyStyle,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final id in _selectedMemberIds)
                        InputChip(
                          key: ValueKey(id),
                          label: Text(_selectedNames[id]!),
                          onDeleted: () => setState(() {
                            _selectedMemberIds.remove(id);
                            _selectedNames.remove(id);
                          }),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionCard(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Subtask',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_subtasks.length} ${_subtasks.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(fontSize: 12, color: _secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSubtask,
                        focusNode: _subtaskFocus,
                        style: _bodyStyle,
                        decoration: _fieldDecoration.copyWith(
                          hintText: 'Add a new subtask...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                      child: const Text('Add', semanticsLabel: 'Add Subtask'),
                    ),
                  ],
                ),
                for (var i = 0; i < _subtasks.length; i++)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_subtasks[i], style: _bodyStyle)),
                        IconButton(
                          tooltip: 'Remove subtask',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: _secondary,
                          ),
                          onPressed: () =>
                              setState(() => _subtasks.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save Task',
              loading: _saving,
              onPressed: _save,
            ),
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
