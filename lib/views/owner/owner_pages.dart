import 'package:flutter/material.dart';

import '../../controllers/owner_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/models.dart';
import '../shared/shared_views.dart';
import '../widgets/feature_widgets.dart';

void _ownerPush(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => page),
  );
}


class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Dashboard',
      subtitle: 'Owner / caretaker overview',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _ownerPush(
            context,
            const NotificationsPage(),
          ),
          icon:
              const Icon(Icons.notifications_none_rounded),
        ),
      ],
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElegantHeader(
              eyebrow: 'Operations',
              title: 'Good afternoon.',
              subtitle:
                  '${controller.occupiedBeds} of ${controller.totalCapacity} beds are currently occupied.',
              trailing: StatusPill(
                '${controller.pendingGateReviews} gate alert',
                icon: Icons.shield_outlined,
              ),
            ),
            const SizedBox(height: 22),
            const PhotoHero(
              image: AppAssets.dormOverview,
              title: "Carmelita's Dormitory",
              subtitle:
                  'Quick monitoring for daily operations',
              height: 220,
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              'Property status',
              subtitle:
                  'The numbers that matter most right now',
            ),
            const SizedBox(height: 10),
            AdaptiveGrid(
              minTileWidth: 245,
              children: [
                MetricCard(
                  label: 'Occupancy',
                  value:
                      '${controller.occupiedBeds}/${controller.totalCapacity}',
                  detail:
                      '${controller.rooms.length} rooms',
                  icon: Icons.bed_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const RoomMonitoringPage(),
                  ),
                  highlight: true,
                ),
                MetricCard(
                  label: 'Payment reviews',
                  value:
                      '${controller.pendingPaymentProofs}',
                  detail: 'Proofs waiting',
                  icon: Icons.payments_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const PaymentVerificationPage(),
                  ),
                ),
                MetricCard(
                  label: 'Maintenance',
                  value: '${controller.openMaintenance}',
                  detail: 'Open reports',
                  icon: Icons.handyman_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const MaintenanceManagementPage(),
                  ),
                ),
                MetricCard(
                  label: 'Curfew',
                  value:
                      '${controller.pendingCurfewReviews}',
                  detail: 'Requests to review',
                  icon: Icons.schedule_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const CurfewRequestReviewPage(),
                  ),
                ),
                MetricCard(
                  label: 'Gate alerts',
                  value:
                      '${controller.pendingGateReviews}',
                  detail: 'Flagged events',
                  icon: Icons.security_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const GateMonitoringPage(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              'Requires attention',
              subtitle:
                  'Actionable items before routine monitoring',
            ),
            const SizedBox(height: 10),
            AttentionCard(
              icon: Icons.receipt_long_outlined,
              title:
                  '${controller.pendingPaymentProofs} payment proof(s) waiting',
              subtitle:
                  'Review uploaded proof before changing payment status.',
              status: controller.pendingPaymentProofs > 0
                  ? 'Pending'
                  : 'Clear',
              onTap: () => _ownerPush(
                context,
                const PaymentVerificationPage(),
              ),
            ),
            const SizedBox(height: 10),
            AttentionCard(
              icon: Icons.approval_outlined,
              title:
                  '${controller.pendingCurfewReviews} curfew request(s) waiting',
              subtitle:
                  'Guardian-approved requests need owner/caretaker review.',
              status: controller.pendingCurfewReviews > 0
                  ? 'Pending'
                  : 'Clear',
              onTap: () => _ownerPush(
                context,
                const CurfewRequestReviewPage(),
              ),
            ),
            const SizedBox(height: 10),
            AttentionCard(
              icon: Icons.videocam_outlined,
              title:
                  '${controller.pendingGateReviews} flagged gate event(s)',
              subtitle:
                  'Review identity mismatch, unrecognized person, or tailgating alerts.',
              status: controller.pendingGateReviews > 0
                  ? 'Review'
                  : 'Clear',
              onTap: () => _ownerPush(
                context,
                const GateMonitoringPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class TenantDirectoryPage extends StatefulWidget {
  const TenantDirectoryPage({super.key});

  @override
  State<TenantDirectoryPage> createState() =>
      _TenantDirectoryPageState();
}

class _TenantDirectoryPageState extends State<TenantDirectoryPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Tenants',
      subtitle: 'Search and view tenant records',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final filtered = controller.tenants
              .where(
                (tenant) =>
                    tenant.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                    tenant.room.contains(query),
              )
              .toList();

          return Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search tenant name or room',
                ),
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                const EmptyState(
                  icon: Icons.person_search_outlined,
                  title: 'No tenant found',
                  message:
                      'Try another name or room number.',
                )
              else
                CarmelitaCard(
                  child: Column(
                    children: filtered
                        .map(
                          (tenant) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Text(tenant.name[0]),
                            ),
                            title: Text(
                              tenant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle:
                                Text('Room ${tenant.room} • ${tenant.bedSpace}'),
                            trailing:
                                StatusPill(tenant.gateStatus),
                            onTap: () => _ownerPush(
                              context,
                              TenantDetailsPage(
                                tenant: tenant,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TenantDetailsPage extends StatelessWidget {
  const TenantDetailsPage({
    required this.tenant,
    super.key,
  });

  final TenantDirectoryEntry tenant;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: tenant.name,
      subtitle: 'Tenant details',
      child: Column(
        children: [
          CarmelitaCard(
            child: Column(
              children: [
                InfoRow(
                  label: 'Room',
                  value: '${tenant.room} • ${tenant.bedSpace}',
                  icon: Icons.meeting_room_outlined,
                ),
                InfoRow(
                  label: 'Phone',
                  value: tenant.phone,
                  icon: Icons.phone_outlined,
                ),
                InfoRow(
                  label: 'Guardian',
                  value: tenant.guardianName,
                  icon: Icons.family_restroom_outlined,
                ),
                InfoRow(
                  label: 'Guardian phone',
                  value: tenant.guardianPhone,
                  icon: Icons.contact_phone_outlined,
                ),
                InfoRow(
                  label: 'Payment',
                  value: tenant.paymentSummary,
                  icon: Icons.payments_outlined,
                ),
                InfoRow(
                  label: 'Gate status',
                  value: tenant.gateStatus,
                  icon: Icons.sensor_door_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CarmelitaCard(
            child: Column(
              children: [
                _OwnerRouteTile(
                  title: 'Payment verification',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const PaymentVerificationPage(),
                  ),
                ),
                const Divider(),
                _OwnerRouteTile(
                  title: 'Gate logs',
                  icon: Icons.sensor_door_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const GateMonitoringPage(),
                  ),
                ),
                const Divider(),
                _OwnerRouteTile(
                  title: 'Confidential reports',
                  icon: Icons.shield_outlined,
                  onTap: () => _ownerPush(
                    context,
                    const ConfidentialReportsPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerRouteTile extends StatelessWidget {
  const _OwnerRouteTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class OperationsHubPage extends StatelessWidget {
  const OperationsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_OperationItem>[
      const _OperationItem(
        'Rooms',
        'Occupancy and availability',
        Icons.bed_outlined,
        RoomMonitoringPage(),
      ),
      const _OperationItem(
        'Payments',
        'Verify uploaded proofs',
        Icons.payments_outlined,
        PaymentVerificationPage(),
      ),
      const _OperationItem(
        'Maintenance',
        'Track and update reports',
        Icons.build_outlined,
        MaintenanceManagementPage(),
      ),
      const _OperationItem(
        'Floor plan',
        'View issue locations',
        Icons.map_outlined,
        FloorPlanMonitoringPage(),
      ),
      const _OperationItem(
        'Curfew',
        'Outside tenants and requests',
        Icons.schedule_outlined,
        CurfewMonitoringPage(),
      ),
      const _OperationItem(
        'Visitors',
        'Expected and previous visitors',
        Icons.people_outline,
        VisitorManagementPage(),
      ),
      const _OperationItem(
        'Confidential reports',
        'Authorized concern review',
        Icons.shield_outlined,
        ConfidentialReportsPage(),
      ),
      const _OperationItem(
        'Announcements',
        'Create and publish notices',
        Icons.campaign_outlined,
        AnnouncementsManagementPage(),
      ),
      const _OperationItem(
        'Messages',
        'Tenants and guardians',
        Icons.chat_bubble_outline,
        OwnerMessagingPage(),
      ),
      const _OperationItem(
        'Emergency contacts',
        'Guardian contact shortcuts',
        Icons.emergency_outlined,
        EmergencyContactsPage(),
      ),
      const _OperationItem(
        'IoT devices',
        'Gateway, cameras, ESP32 and sensors',
        Icons.memory_outlined,
        IotDeviceStatusPage(),
      ),
    ];

    return PageFrame(
      title: 'Operations',
      subtitle: 'Quick monitoring and field updates',
      child: AdaptiveGrid(
        minTileWidth: 250,
        children: items
            .map(
              (item) => CarmelitaCard(
                onTap: () => _ownerPush(context, item.page),
                child: Row(
                  children: [
                    CircleAvatar(child: Icon(item.icon)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _OperationItem {
  const _OperationItem(
    this.title,
    this.subtitle,
    this.icon,
    this.page,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}

class RoomMonitoringPage extends StatelessWidget {
  const RoomMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Room monitoring',
      subtitle: 'Occupancy and availability',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdaptiveGrid(
              children: [
                MetricCard(
                  label: 'Occupied beds',
                  value: '${controller.occupiedBeds}',
                  detail:
                      'of ${controller.totalCapacity} total',
                  icon: Icons.bed_outlined,
                ),
                MetricCard(
                  label: 'Available beds',
                  value:
                      '${controller.totalCapacity - controller.occupiedBeds}',
                  detail: 'Across all rooms',
                  icon: Icons.event_available_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            AdaptiveGrid(
              minTileWidth: 220,
              children: controller.rooms
                  .map(
                    (room) => CarmelitaCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Room ${room.roomNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(room.floor),
                          const SizedBox(height: 4),
                          Text(
                            '${room.occupied}/${room.capacity} occupied • '
                            '${room.available} available',
                          ),
                          const SizedBox(height: 8),
                          StatusPill(
                            room.available == 0
                                ? 'Full'
                                : 'Available',
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentVerificationPage extends StatelessWidget {
  const PaymentVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Payment verification',
      subtitle: 'Review uploaded payment proofs',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final pending = controller.payments
              .where(
                (payment) =>
                    payment.status == 'Pending verification',
              )
              .toList();

          if (pending.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt,
              title: 'No pending payment proofs',
              message:
                  'New uploads will appear here for verification.',
            );
          }

          return Column(
            children: pending
                .map(
                  (payment) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
                    child: CarmelitaCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const InfoRow(
                            label: 'Tenant',
                            value: 'Anna Dela Cruz',
                          ),
                          InfoRow(
                            label: 'Amount',
                            value: money(payment.amount),
                          ),
                          InfoRow(
                            label: 'Reference',
                            value: payment.reference ?? '—',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      controller.verifyPayment(
                                    payment,
                                    false,
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      controller.verifyPayment(
                                    payment,
                                    true,
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class MaintenanceManagementPage extends StatelessWidget {
  const MaintenanceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Maintenance management',
      subtitle: 'Pending, ongoing, and completed reports',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CarmelitaCard(
          child: Column(
            children: controller.maintenance
                .map(
                  (report) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.build_outlined),
                    ),
                    title: Text(
                      '${report.category} • ${report.location}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${report.description}\n'
                      'Priority: ${report.urgency}',
                    ),
                    trailing: StatusPill(report.status),
                    onTap: () => _ownerPush(
                      context,
                      MaintenanceDetailsPage(
                        report: report,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class MaintenanceDetailsPage extends StatefulWidget {
  const MaintenanceDetailsPage({
    required this.report,
    super.key,
  });

  final MaintenanceReport report;

  @override
  State<MaintenanceDetailsPage> createState() =>
      _MaintenanceDetailsPageState();
}

class _MaintenanceDetailsPageState
    extends State<MaintenanceDetailsPage> {
  late String status = widget.report.status;
  final notes = TextEditingController();
  bool evidenceSelected = false;

  @override
  void initState() {
    super.initState();
    notes.text = widget.report.notes;
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Maintenance details',
      subtitle: widget.report.location,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarmelitaCard(
              child: Column(
                children: [
                  InfoRow(
                    label: 'Category',
                    value: widget.report.category,
                  ),
                  InfoRow(
                    label: 'Urgency',
                    value: widget.report.urgency,
                  ),
                  InfoRow(
                    label: 'Description',
                    value: widget.report.description,
                  ),
                  InfoRow(
                    label: 'Created',
                    value: shortDate(
                      widget.report.createdAt,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration:
                  const InputDecoration(labelText: 'Status'),
              items: const [
                'Submitted',
                'Ongoing',
                'Completed',
                'Closed',
              ]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => status = value ?? status),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notes,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Caretaker notes',
              ),
            ),
            const SizedBox(height: 14),
            CarmelitaCard(
              onTap: () {
                setState(() => evidenceSelected = true);
                showAppSnackBar(
                  context,
                  'Completion evidence selected in the frontend demo.',
                );
              },
              child: Row(
                children: [
                  Icon(
                    evidenceSelected
                        ? Icons.check_circle_outline
                        : Icons.add_photo_alternate_outlined,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      evidenceSelected
                          ? 'Completion evidence ready'
                          : 'Upload completion evidence',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  OwnerController.instance.updateMaintenance(
                    widget.report,
                    status,
                    notes: notes.text,
                  );
                  showAppSnackBar(
                    context,
                    'Maintenance report updated.',
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloorPlanMonitoringPage extends StatelessWidget {
  const FloorPlanMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      title: 'Floor plan monitoring',
      subtitle: 'Maintenance concerns by location',
      child: FloorPlanCanvas(monitorMode: true),
    );
  }
}

class GateMonitoringPage extends StatelessWidget {
  const GateMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Gate monitoring',
      subtitle: 'IN/OUT events, recognition, and alerts',
      actions: [
        IconButton(
          tooltip: 'IoT status',
          onPressed: () => _ownerPush(
            context,
            const IotDeviceStatusPage(),
          ),
          icon: const Icon(Icons.memory_outlined),
        ),
      ],
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdaptiveGrid(
              children: [
                const MetricCard(
                  label: 'Gate controller',
                  value: 'Online',
                  detail: 'Normal mode',
                  icon: Icons.router_outlined,
                ),
                const MetricCard(
                  label: 'Gate lock',
                  value: 'Locked',
                  detail: 'Secure',
                  icon: Icons.lock_outline,
                ),
                MetricCard(
                  label: 'Alerts',
                  value: '${controller.pendingGateReviews}',
                  detail: 'Needs review',
                  icon: Icons.warning_amber_outlined,
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (controller.gateReviews.isNotEmpty) ...[
              const SectionTitle('Flagged events'),
              const SizedBox(height: 10),
              ...controller.gateReviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GateReviewCard(review: review),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SectionTitle('Recent gate events'),
            const SizedBox(height: 10),
            CarmelitaCard(
              child: Column(
                children: controller.gateEvents
                    .map(
                      (event) => TimelineTile(
                        icon: event.direction == 'IN'
                            ? Icons.login
                            : event.direction == 'OUT'
                                ? Icons.logout
                                : Icons.videocam_outlined,
                        title:
                            '${event.person} • ${event.direction}',
                        subtitle:
                            '${timeText(event.time)} • '
                            '${event.verification}',
                        trailing: StatusPill(event.status),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _ownerPush(
                  context,
                  const ManualGateOverridePage(),
                ),
                icon: const Icon(Icons.offline_bolt_outlined),
                label: const Text('Record manual override'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GateReviewCard extends StatefulWidget {
  const _GateReviewCard({
    required this.review,
  });

  final GateReviewRecord review;

  @override
  State<_GateReviewCard> createState() =>
      _GateReviewCardState();
}

class _GateReviewCardState extends State<_GateReviewCard> {
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return CarmelitaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${review.event.person} • '
                  '${review.event.direction}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              StatusPill(review.reviewStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${shortDate(review.event.time)} • '
            '${timeText(review.event.time)} • '
            '${review.event.verification}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Review note',
              hintText: 'Optional note',
            ),
          ),
          if (review.reviewStatus == 'Pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        OwnerController.instance.reviewGateEvent(
                      review,
                      status: 'Escalated',
                      note: note.text,
                    ),
                    child: const Text('Escalate'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        OwnerController.instance.reviewGateEvent(
                      review,
                      status: 'Resolved',
                      note: note.text,
                    ),
                    child: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ManualGateOverridePage extends StatefulWidget {
  const ManualGateOverridePage({super.key});

  @override
  State<ManualGateOverridePage> createState() =>
      _ManualGateOverridePageState();
}

class _ManualGateOverridePageState
    extends State<ManualGateOverridePage> {
  final reason = TextEditingController();
  String action = 'OPEN';

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Manual gate override',
      subtitle: 'Record operator action and reason',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: action,
              decoration:
                  const InputDecoration(labelText: 'Action'),
              items: const ['OPEN', 'LOCK']
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => action = value ?? action),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reason,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText:
                    'Example: power interruption or verified emergency',
              ),
            ),
            const SizedBox(height: 14),
            const CarmelitaCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text(
                  'Audit-ready frontend',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'The backend should later save the operator account, '
                  'timestamp, reason, device state, and action.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (reason.text.trim().isEmpty) {
                    showAppSnackBar(
                      context,
                      'Enter the reason for the override.',
                    );
                    return;
                  }

                  OwnerController.instance.addManualOverride(
                    reason: reason.text,
                    action: action,
                  );
                  showAppSnackBar(
                    context,
                    'Manual override recorded.',
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Record override'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurfewMonitoringPage extends StatelessWidget {
  const CurfewMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Curfew monitoring',
      subtitle: 'Outside tenants, late records, and exceptions',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdaptiveGrid(
              children: [
                const MetricCard(
                  label: 'Currently outside',
                  value: '4',
                  detail: 'Before curfew',
                  icon: Icons.directions_walk_outlined,
                ),
                MetricCard(
                  label: 'Approved exceptions',
                  value:
                      '${controller.curfewRequests.where((r) => r.ownerStatus == 'Approved').length}',
                  detail: 'Current records',
                  icon: Icons.event_available_outlined,
                ),
                const MetricCard(
                  label: 'Late arrivals',
                  value: '0',
                  detail: 'Today',
                  icon: Icons.warning_amber_outlined,
                ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => _ownerPush(
                context,
                const CurfewRequestReviewPage(),
              ),
              icon: const Icon(Icons.approval_outlined),
              label: const Text('Review curfew requests'),
            ),
          ],
        ),
      ),
    );
  }
}

class CurfewRequestReviewPage extends StatelessWidget {
  const CurfewRequestReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Curfew request review',
      subtitle: 'Owner / caretaker decision',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          children: controller.curfewRequests
              .map(
                (request) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: CarmelitaCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request.tenantName,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            StatusPill(
                              request.ownerStatus,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'Reason',
                          value: request.reason,
                        ),
                        InfoRow(
                          label: 'Destination',
                          value: request.destination,
                        ),
                        InfoRow(
                          label: 'Guardian',
                          value: request.guardianStatus,
                        ),
                        InfoRow(
                          label: 'Return',
                          value:
                              '${shortDate(request.expectedReturn)} • '
                              '${timeText(request.expectedReturn)}',
                        ),
                        if (request.guardianStatus ==
                                'Approved' &&
                            request.ownerStatus ==
                                'Pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      controller.decideCurfew(
                                    request,
                                    false,
                                  ),
                                  child:
                                      const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      controller.decideCurfew(
                                    request,
                                    true,
                                  ),
                                  child:
                                      const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class VisitorManagementPage extends StatelessWidget {
  const VisitorManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Visitor management',
      subtitle: 'Expected visitors and permission status',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.visitors.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No visitor requests',
              message:
                  'Tenant visitor requests will appear here.',
            );
          }

          return Column(
            children: controller.visitors
                .map(
                  (visitor) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
                    child: CarmelitaCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  visitor.visitorName,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              StatusPill(visitor.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            label: 'Relationship',
                            value: visitor.relationship,
                          ),
                          InfoRow(
                            label: 'Schedule',
                            value:
                                '${shortDate(visitor.schedule)} • '
                                '${timeText(visitor.schedule)}',
                          ),
                          if (visitor.status ==
                              'Pending') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        controller.decideVisitor(
                                      visitor,
                                      false,
                                    ),
                                    child:
                                        const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () =>
                                        controller.decideVisitor(
                                      visitor,
                                      true,
                                    ),
                                    child:
                                        const Text('Approve'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class ConfidentialReportsPage extends StatelessWidget {
  const ConfidentialReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Confidential reports',
      subtitle: 'Authorized review only',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          children: controller.concerns
              .map(
                (report) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: CarmelitaCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.category,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                            StatusPill(report.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(report.summary),
                        const SizedBox(height: 8),
                        Text(
                          shortDate(report.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  controller
                                      .updateConcernStatus(
                                report,
                                'Under review',
                              ),
                              child: const Text(
                                'Mark under review',
                              ),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  controller
                                      .updateConcernStatus(
                                report,
                                'Resolved',
                              ),
                              child:
                                  const Text('Resolve'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AnnouncementsManagementPage extends StatefulWidget {
  const AnnouncementsManagementPage({super.key});

  @override
  State<AnnouncementsManagementPage> createState() =>
      _AnnouncementsManagementPageState();
}

class _AnnouncementsManagementPageState
    extends State<AnnouncementsManagementPage> {
  final title = TextEditingController();
  final body = TextEditingController();
  String audience = 'All tenants';

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Announcements',
      subtitle: 'Create and publish dormitory notices',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          children: [
            CarmelitaCard(
              child: Column(
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: body,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Announcement',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: audience,
                    decoration: const InputDecoration(
                      labelText: 'Audience',
                    ),
                    items: const [
                      'All tenants',
                      'Guardians',
                      'All users',
                    ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => audience = value ?? audience,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (title.text.trim().isEmpty ||
                            body.text.trim().isEmpty) {
                          showAppSnackBar(
                            context,
                            'Enter a title and announcement.',
                          );
                          return;
                        }

                        controller.publishAnnouncement(
                          title: title.text,
                          body: body.text,
                          audience: audience,
                        );
                        title.clear();
                        body.clear();
                        showAppSnackBar(
                          context,
                          'Announcement published in the frontend.',
                        );
                      },
                      child: const Text('Publish'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Published'),
            const SizedBox(height: 10),
            ...controller.announcements.map(
              (announcement) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: CarmelitaCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.campaign_outlined,
                    ),
                    title: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${announcement.audience}\n'
                      '${announcement.body}',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerMessagingPage extends StatelessWidget {
  const OwnerMessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Messages',
      subtitle: 'Tenant and guardian conversations',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CarmelitaCard(
          child: Column(
            children: controller.conversations
                .map(
                  (conversation) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        conversation.personName[0],
                      ),
                    ),
                    title: Text(
                      conversation.personName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${conversation.personRole} • '
                      '${conversation.messages.last.body}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        const Icon(Icons.chevron_right),
                    onTap: () => _ownerPush(
                      context,
                      OwnerConversationPage(
                        conversation: conversation,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class OwnerConversationPage extends StatefulWidget {
  const OwnerConversationPage({
    required this.conversation,
    super.key,
  });

  final OwnerConversation conversation;

  @override
  State<OwnerConversationPage> createState() =>
      _OwnerConversationPageState();
}

class _OwnerConversationPageState
    extends State<OwnerConversationPage> {
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: widget.conversation.personName,
      subtitle: widget.conversation.personRole,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Column(
            children: [
              CarmelitaCard(
                child: Column(
                  children: widget.conversation.messages
                      .map(
                        (item) => Align(
                          alignment:
                              item.senderRole ==
                                      'ownerCaretaker'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 560,
                            ),
                            margin:
                                const EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                            child: Text(
                              '${item.senderName}: ${item.body}\n'
                              '${timeText(item.sentAt)}',
                              textAlign:
                                  item.senderRole ==
                                          'ownerCaretaker'
                                      ? TextAlign.right
                                      : TextAlign.left,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: message,
                decoration: InputDecoration(
                  hintText: 'Write a message',
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (message.text.trim().isEmpty) {
                        return;
                      }
                      controller.sendOwnerMessage(
                        widget.conversation,
                        message.text,
                      );
                      message.clear();
                    },
                    icon:
                        const Icon(Icons.send_outlined),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  controller.sendOwnerMessage(
                    widget.conversation,
                    value,
                  );
                  message.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'Emergency contacts',
      subtitle: 'Guardian contact shortcuts',
      child: CarmelitaCard(
        child: Column(
          children: controller.tenants
              .map(
                (tenant) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.contact_phone_outlined,
                    ),
                  ),
                  title: Text(
                    tenant.guardianName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${tenant.name} • '
                    '${tenant.guardianPhone}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Call',
                    onPressed: () => showAppSnackBar(
                      context,
                      'Phone launcher integration placeholder.',
                    ),
                    icon: const Icon(
                      Icons.call_outlined,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class IotDeviceStatusPage extends StatelessWidget {
  const IotDeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OwnerController.instance;

    return PageFrame(
      title: 'IoT device status',
      subtitle: 'Gateway and gate hardware indicators',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CarmelitaCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text(
                'Frontend demonstration',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                'These states are still mock values. Real heartbeat, '
                'camera availability, fingerprint state, lock state, '
                'and sensor connectivity will come from the backend/IoT layer.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          AdaptiveGrid(
            minTileWidth: 250,
            children: controller.devices
                .map(
                  (device) => CarmelitaCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Icon(
                                Icons.memory_outlined,
                                size: 26,
                              ),
                            ),
                            StatusPill(device.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.detail,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
