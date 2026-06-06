/// Manager assignment model - simple plain Dart class
library;

/// Model representing a manager-worker assignment
class ManagerAssignment {
  /// Unique identifier for the assignment
  final String id;

  /// Manager's user ID
  final String managerId;

  /// Worker's user ID
  final String workerId;

  /// Optional assigned area/region
  final String? assignedArea;

  /// When the assignment was created
  final DateTime? assignedAt;

  /// Who created this assignment (super manager user ID)
  final String? createdBy;

  ManagerAssignment({
    required this.id,
    required this.managerId,
    required this.workerId,
    this.assignedArea,
    this.assignedAt,
    this.createdBy,
  });

  factory ManagerAssignment.fromJson(Map<String, dynamic> json) {
    return ManagerAssignment(
      id: json['id'] as String,
      managerId: json['manager_id'] as String,
      workerId: json['worker_id'] as String,
      assignedArea: json['assigned_area'] as String?,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manager_id': managerId,
      'worker_id': workerId,
      'assigned_area': assignedArea,
      'assigned_at': assignedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }
}

/// Status of an assignment
enum AssignmentStatus { active, revoked }

/// Extension for assignment status
extension AssignmentStatusExtension on AssignmentStatus {
  String get arabicLabel {
    switch (this) {
      case AssignmentStatus.active:
        return 'نشط';
      case AssignmentStatus.revoked:
        return 'ملغي';
    }
  }
}
