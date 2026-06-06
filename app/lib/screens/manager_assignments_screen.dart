import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/manager_assignments_service.dart';
import '../providers/auth_provider.dart';

/// Screen for super_manager to assign workers to managers
class ManagerAssignmentsScreen extends ConsumerStatefulWidget {
  const ManagerAssignmentsScreen({super.key});

  @override
  ConsumerState<ManagerAssignmentsScreen> createState() =>
      _ManagerAssignmentsScreenState();
}

class _ManagerAssignmentsScreenState
    extends ConsumerState<ManagerAssignmentsScreen> {
  final _service = ManagerAssignmentsService();

  List<Map<String, dynamic>> _managers = [];
  List<Map<String, dynamic>> _workers = [];
  List<ManagerWorkerAssignment> _assignments = [];

  String? _selectedManagerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_managers.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final managers = await _service.getAllManagers();
      final workers = await _service.getAllWorkers();
      final assignments = await _service.getAllAssignments();

      if (mounted) {
        setState(() {
          _managers = managers;
          _workers = workers;
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
    }
  }

  Future<void> _refreshAssignments() async {
    try {
      final assignments = await _service.getAllAssignments();
      if (mounted) {
        setState(() {
          _assignments = assignments;
        });
      }
    } catch (e) {
      // Quietly fail or log
      debugPrint('Failed to refresh assignments: $e');
    }
  }

  List<String> _getAssignedWorkerIds(String managerId) {
    return _assignments
        .where((a) => a.managerId == managerId)
        .map((a) => a.workerId)
        .toList();
  }

  Future<void> _toggleWorkerAssignment(
    String managerId,
    String workerId,
    bool isAssigned,
  ) async {
    try {
      if (isAssigned) {
        await _service.unassignWorker(managerId: managerId, workerId: workerId);
      } else {
        final user = ref.read(currentUserProvider);
        await _service.assignWorker(
          managerId: managerId,
          workerId: workerId,
          createdBy: user?.userId,
        );
      }
      await _refreshAssignments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل تحديث التعيين: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 141, 17, 17), Color(0xFF6E0A0A)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'تعيين العمال للمديرين',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_managers.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد مديرين',
          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Manager Selector
        _buildManagerSelector(),

        // Workers List or Empty State
        if (_selectedManagerId != null)
          Expanded(child: _buildWorkersList())
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'اختر مديراً من القائمة أعلاه\nلعرض وتعيين العمال',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildManagerSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            'اختر المدير',
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
          value: _selectedManagerId,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: _managers.map((manager) {
            final role = manager['role'] == 'super_manager'
                ? ' (مدير عام)'
                : '';
            return DropdownMenuItem(
              value: manager['user_id'] as String,
              child: Text(
                '${manager['name']}$role',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedManagerId = value);
          },
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    if (_workers.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد عمال',
          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final assignedWorkerIds = _getAssignedWorkerIds(_selectedManagerId!);

    // Sort workers: Assigned first, then by name
    final sortedWorkers = List<Map<String, dynamic>>.from(_workers)
      ..sort((a, b) {
        final idA = a['user_id'] as String;
        final idB = b['user_id'] as String;
        final assignedA = assignedWorkerIds.contains(idA);
        final assignedB = assignedWorkerIds.contains(idB);

        if (assignedA && !assignedB) return -1;
        if (!assignedA && assignedB) return 1;

        final nameA = a['name'] as String? ?? '';
        final nameB = b['name'] as String? ?? '';
        return nameA.compareTo(nameB);
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                'قائمة العمال',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${assignedWorkerIds.length} معين',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF16A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: sortedWorkers.length,
            itemBuilder: (context, index) {
              final worker = sortedWorkers[index];
              final workerId = worker['user_id'] as String;
              final isAssigned = assignedWorkerIds.contains(workerId);
              final name = worker['name'] as String? ?? 'بدون اسم';
              final email = worker['email'] as String? ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isAssigned ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAssigned
                        ? const Color(0xFF86EFAC)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isAssigned
                          ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isAssigned
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFE5E7EB),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.cairo(
                        color: isAssigned
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: email.isNotEmpty
                      ? Text(
                          email,
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: Switch(
                    value: isAssigned,
                    activeThumbColor: const Color(0xFF22C55E),
                    onChanged: (value) {
                      _toggleWorkerAssignment(
                        _selectedManagerId!,
                        workerId,
                        isAssigned,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
