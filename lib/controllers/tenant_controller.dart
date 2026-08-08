import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class TenantController extends ChangeNotifier {
  TenantController._();

  static final TenantController instance = TenantController._();

  Room get room => MockData.room;
  List<Payment> get payments => List.unmodifiable(MockData.payments);
  List<MaintenanceReport> get maintenance =>
      List.unmodifiable(MockData.maintenance);
  List<GateEvent> get gateEvents => List.unmodifiable(MockData.gateEvents);
  List<Announcement> get announcements =>
      List.unmodifiable(MockData.announcements);
  List<CurfewRequest> get curfewRequests =>
      List.unmodifiable(MockData.curfewRequests);
  List<VisitorRequest> get visitors => List.unmodifiable(MockData.visitors);
  List<ConcernReport> get concerns => List.unmodifiable(MockData.concerns);
  List<ChatMessage> get messages => List.unmodifiable(MockData.tenantMessages);

  void submitPaymentProof({
    required double amount,
    required String method,
    required String reference,
  }) {
    MockData.payments.insert(
      0,
      Payment(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        label: '$method payment submission',
        amount: amount,
        dueDate: DateTime.now(),
        status: 'Pending verification',
        reference: reference.trim().isEmpty ? null : reference.trim(),
      ),
    );
    notifyListeners();
  }

  void submitMaintenance({
    required String category,
    required String description,
    required String location,
    required String urgency,
  }) {
    MockData.maintenance.insert(
      0,
      MaintenanceReport(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        category: category,
        description: description,
        location: location,
        urgency: urgency,
        status: 'Submitted',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void submitCurfew({
    required String reason,
    required String destination,
    required DateTime expectedReturn,
  }) {
    MockData.curfewRequests.insert(
      0,
      CurfewRequest(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        tenantName: 'Anna Dela Cruz',
        reason: reason,
        destination: destination,
        expectedReturn: expectedReturn,
        guardianStatus: 'Pending',
        ownerStatus: 'Waiting for guardian',
      ),
    );
    notifyListeners();
  }

  void submitVisitor({
    required String visitorName,
    required String relationship,
    required DateTime schedule,
  }) {
    MockData.visitors.insert(
      0,
      VisitorRequest(
        id: 'v${DateTime.now().millisecondsSinceEpoch}',
        visitorName: visitorName,
        relationship: relationship,
        schedule: schedule,
        status: 'Pending',
      ),
    );
    notifyListeners();
  }

  void submitConcern({
    required String category,
    required String summary,
  }) {
    MockData.concerns.insert(
      0,
      ConcernReport(
        id: 'r${DateTime.now().millisecondsSinceEpoch}',
        category: category,
        summary: summary,
        status: 'Submitted',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void sendMessage(String body) {
    final clean = body.trim();
    if (clean.isEmpty) return;

    MockData.tenantMessages.add(
      ChatMessage(
        id: 'tm${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Anna Dela Cruz',
        senderRole: 'tenant',
        body: clean,
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
