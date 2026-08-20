import '../models/models.dart';

abstract class AuthService {
  Future<AppUser> signIn(String email, String password);
  Future<void> requestPasswordReset(String email);
}

class MockAuthService implements AuthService {
  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (email.trim().isEmpty || password.trim().isEmpty)
      throw Exception('Enter both email and password.');
    final normalized = email.toLowerCase();
    if (normalized.contains('owner') || normalized.contains('caretaker')) {
      return AppUser(
          id: 'owner-001',
          name: 'Carmelita Admin',
          email: email,
          role: UserRole.ownerCaretaker,
          phone: '+63 917 000 0001');
    }
    if (normalized.contains('guardian') || normalized.contains('parent')) {
      return AppUser(
          id: 'guardian-001',
          name: 'Maria Dela Cruz',
          email: email,
          role: UserRole.guardian,
          phone: '+63 917 000 0002');
    }
    return AppUser(
        id: 'tenant-001',
        name: 'Anna Dela Cruz',
        email: email,
        role: UserRole.tenant,
        phone: '+63 917 000 0003');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!email.contains('@')) throw Exception('Enter a valid email address.');
  }
}
