import '../models/support_user.dart';

const staticSupportUsers = <SupportUser>[
  SupportUser(
    backendUserId: 95,
    employeeCode: 'EMP001',
    username: 'support1',
    password: 'Support@123',
    fullName: 'Support User 1',
    role: 'Support Executive',
  ),
  SupportUser(
    backendUserId: 96,
    employeeCode: 'EMP002',
    username: 'support2',
    password: 'Support@456',
    fullName: 'Support User 2',
    role: 'Support Executive',
  ),
  SupportUser(
    backendUserId: 97,
    employeeCode: 'EMP003',
    username: 'manager1',
    password: 'Manager@789',
    fullName: 'Support Manager',
    role: 'Support Manager',
  ),
];
