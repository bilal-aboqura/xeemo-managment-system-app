import 'package:flutter_test/flutter_test.dart';
import 'package:xeemo_sales/models/manager_assignment_model.dart';

void main() {
  group('ManagerAssignment', () {
    test('should create ManagerAssignment with required fields', () {
      final assignment = ManagerAssignment(
        id: 'assignment-1',
        managerId: 'manager-1',
        workerId: 'worker-1',
      );

      expect(assignment.id, 'assignment-1');
      expect(assignment.managerId, 'manager-1');
      expect(assignment.workerId, 'worker-1');
      expect(assignment.assignedArea, isNull);
      expect(assignment.assignedAt, isNull);
      expect(assignment.createdBy, isNull);
    });

    test('should create ManagerAssignment with all fields', () {
      final now = DateTime.now();
      final assignment = ManagerAssignment(
        id: 'assignment-1',
        managerId: 'manager-1',
        workerId: 'worker-1',
        assignedArea: 'المنطقة الشرقية',
        assignedAt: now,
        createdBy: 'super-manager-1',
      );

      expect(assignment.assignedArea, 'المنطقة الشرقية');
      expect(assignment.assignedAt, now);
      expect(assignment.createdBy, 'super-manager-1');
    });

    test('should convert from JSON correctly', () {
      final json = {
        'id': 'assignment-1',
        'manager_id': 'manager-1',
        'worker_id': 'worker-1',
        'assigned_area': 'المنطقة الغربية',
        'assigned_at': '2024-01-15T10:30:00.000Z',
        'created_by': 'super-manager-1',
      };

      final assignment = ManagerAssignment.fromJson(json);

      expect(assignment.id, 'assignment-1');
      expect(assignment.managerId, 'manager-1');
      expect(assignment.workerId, 'worker-1');
      expect(assignment.assignedArea, 'المنطقة الغربية');
      expect(assignment.assignedAt, isNotNull);
      expect(assignment.createdBy, 'super-manager-1');
    });

    test('should convert from JSON with null optional fields', () {
      final json = {
        'id': 'assignment-1',
        'manager_id': 'manager-1',
        'worker_id': 'worker-1',
      };

      final assignment = ManagerAssignment.fromJson(json);

      expect(assignment.assignedArea, isNull);
      expect(assignment.assignedAt, isNull);
      expect(assignment.createdBy, isNull);
    });

    test('should convert to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final assignment = ManagerAssignment(
        id: 'assignment-1',
        managerId: 'manager-1',
        workerId: 'worker-1',
        assignedArea: 'المنطقة الشمالية',
        assignedAt: now,
        createdBy: 'super-manager-1',
      );

      final json = assignment.toJson();

      expect(json['id'], 'assignment-1');
      expect(json['manager_id'], 'manager-1');
      expect(json['worker_id'], 'worker-1');
      expect(json['assigned_area'], 'المنطقة الشمالية');
      expect(json['assigned_at'], isNotNull);
      expect(json['created_by'], 'super-manager-1');
    });

    test('should handle toJson with null optional fields', () {
      final assignment = ManagerAssignment(
        id: 'assignment-1',
        managerId: 'manager-1',
        workerId: 'worker-1',
      );

      final json = assignment.toJson();

      expect(json['assigned_area'], isNull);
      expect(json['assigned_at'], isNull);
      expect(json['created_by'], isNull);
    });
  });

  group('AssignmentStatus', () {
    test('should have correct Arabic labels', () {
      expect(AssignmentStatus.active.arabicLabel, 'نشط');
      expect(AssignmentStatus.revoked.arabicLabel, 'ملغي');
    });

    test('should have all expected enum values', () {
      expect(AssignmentStatus.values.length, 2);
      expect(AssignmentStatus.values.contains(AssignmentStatus.active), true);
      expect(AssignmentStatus.values.contains(AssignmentStatus.revoked), true);
    });
  });
}
