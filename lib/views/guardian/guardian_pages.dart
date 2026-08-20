import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/guardian_controller.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../services/usage_stats_service.dart';

class GuardianDashboardPage extends StatelessWidget {
  const GuardianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GuardianController.instance;
    final linkedRequests = controller.curfewRequests
        .where(
          (request) => request.tenantName == controller.linkedTenantName,
        )
        .toList();

    return PageFrame(
      title: 'Home',
      subtitle: 'Guardian dashboard',
      actions: [
        IconButton(
          tooltip: 'Safety alerts',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EmergencySafetyAlertsPage(),
            ),
          ),
          icon: const Icon(Icons.shield_outlined),
        ),
      ],
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ElegantHeader(
              eyebrow: 'Guardian view',
              title: 'Anna is inside the dormitory.',
              subtitle:
                  'Everything important about your linked tenant appears here first.',
              trailing: StatusPill(
                'IN',
                icon: Icons.home_rounded,
              ),
            ),
            const SizedBox(height: 22),
            CarmelitaCard(
              emphasis: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GuardianTenantInfoPage(),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anna Dela Cruz',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Room 204 • Bed 2'),
                        SizedBox(height: 3),
                        Text('Last IN • 8:14 PM'),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              'At a glance',
              subtitle: 'Gate, payment, and pending approvals',
            ),
            const SizedBox(height: 10),
            MutedDashboardGrid(
              items: [
                MutedDashboardItem(
                  label: 'Gate status',
                  value: 'Inside',
                  detail: 'Verified • 8:14 PM',
                  icon: Icons.sensor_door_outlined,
                  color: const Color(0xFF56886B),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianGateActivityPage(),
                    ),
                  ),
                ),
                MutedDashboardItem(
                  label: 'Outstanding',
                  value: money(controller.outstandingTotal),
                  detail: 'Unpaid / unverified',
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFAA8A45),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianPaymentStatusPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              'Needs your attention',
              subtitle: 'Requests that require a guardian decision',
            ),
            const SizedBox(height: 10),
            if (controller.pendingCurfewCount == 0)
              const CarmelitaCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.task_alt_rounded),
                  title: Text(
                    'No pending curfew requests',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'New requests from your linked tenant will appear here.',
                  ),
                ),
              )
            else
              ...linkedRequests
                  .where(
                    (request) => request.guardianStatus == 'Pending',
                  )
                  .map(
                    (request) => AttentionCard(
                      icon: Icons.schedule_outlined,
                      title: request.reason,
                      subtitle:
                          '${request.destination} • Return ${timeText(request.expectedReturn)}',
                      status: request.guardianStatus,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GuardianCurfewRequestsPage(),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            const SectionTitle(
              'Quick access',
              subtitle: 'Common information without searching',
            ),
            const SizedBox(height: 10),
            MutedActionGrid(
              items: [
                MutedActionItem(
                  label: 'Tenant info',
                  detail: 'View linked tenant',
                  icon: Icons.person_outline,
                  color: const Color(0xFF56886B),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianTenantInfoPage(),
                    ),
                  ),
                ),
                MutedActionItem(
                  label: 'Payments',
                  detail: 'Check balances',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFFAA8A45),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianPaymentStatusPage(),
                    ),
                  ),
                ),
                MutedActionItem(
                  label: 'Announcements',
                  detail: 'Read dormitory news',
                  icon: Icons.campaign_outlined,
                  color: const Color(0xFF7D70A0),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianAnnouncementsPage(),
                    ),
                  ),
                ),
                MutedActionItem(
                  label: 'Contact info',
                  detail: 'Office and emergency',
                  icon: Icons.emergency_outlined,
                  color: const Color(0xFFAA6870),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencySafetyAlertsPage(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GuardianTenantInfoPage extends StatelessWidget {
  const GuardianTenantInfoPage({super.key});
  @override
  Widget build(BuildContext context) => const PageFrame(
      title: 'Tenant information',
      subtitle: 'Linked tenant',
      child: CarmelitaCard(
          child: Column(children: [
        InfoRow(
            label: 'Tenant',
            value: 'Anna Dela Cruz',
            icon: Icons.person_outline),
        InfoRow(
            label: 'Room',
            value: '204 • Second Floor',
            icon: Icons.meeting_room_outlined),
        InfoRow(label: 'Bed space', value: 'Bed 2', icon: Icons.bed_outlined),
        InfoRow(
            label: 'Current status',
            value: 'Inside dormitory',
            icon: Icons.sensor_door_outlined),
      ])));
}

class GuardianGateActivityPage extends StatefulWidget {
  const GuardianGateActivityPage({super.key});

  @override
  State<GuardianGateActivityPage> createState() =>
      _GuardianGateActivityPageState();
}

class _GuardianGateActivityPageState extends State<GuardianGateActivityPage>
    with WidgetsBindingObserver {
  bool loading = true;
  bool hasPermission = false;
  String? error;
  List<AppUsageStat> usage = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUsage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) loadUsage();
  }

  Future<void> loadUsage() async {
    if (!UsageStatsService.isSupported) {
      if (mounted) setState(() => loading = false);
      return;
    }
    try {
      final allowed = await UsageStatsService.hasPermission();
      final result = allowed
          ? await UsageStatsService.getTodayUsage()
          : const <AppUsageStat>[];
      if (!mounted) return;
      setState(() {
        hasPermission = allowed;
        usage = result;
        error = null;
        loading = false;
      });
    } on PlatformException catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception.message ?? 'Could not load app activity.';
        loading = false;
      });
    }
  }

  String durationText(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes < 1 ? 1 : minutes} min';
    return minutes == 0 ? '$hours hr' : '$hours hr $minutes min';
  }

  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Activity',
        subtitle: 'Today\'s device usage and recent gate events',
        actions: [
          IconButton(
            tooltip: 'Refresh activity',
            onPressed: loading ? null : loadUsage,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Device app activity',
                subtitle:
                    'Foreground usage recorded on this Android device today'),
            const SizedBox(height: 10),
            _usageCard(),
            const SizedBox(height: 24),
            const SectionTitle('Recent gate records',
                subtitle: 'Verified IN and OUT events'),
            const SizedBox(height: 10),
            const _GuardianGateRecords(),
          ],
        ),
      );

  Widget _usageCard() {
    if (!UsageStatsService.isSupported) {
      return const CarmelitaCard(
          child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.phone_android_outlined),
        title: Text('Available on Android'),
        subtitle:
            Text('Device app activity is not available on this platform.'),
      ));
    }
    if (loading) {
      return const CarmelitaCard(
          child: Center(child: CircularProgressIndicator()));
    }
    if (!hasPermission) {
      return CarmelitaCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Usage access is required'),
            subtitle: Text(
                'Allow Carmelita\'s Dormitory to read app usage in Android settings.'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: UsageStatsService.openPermissionSettings,
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Open usage access settings'),
          ),
        ],
      ));
    }
    if (error != null) {
      return CarmelitaCard(
          child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.error_outline),
        title: const Text('Could not load app activity'),
        subtitle: Text(error!),
        trailing:
            IconButton(onPressed: loadUsage, icon: const Icon(Icons.refresh)),
      ));
    }
    if (usage.isEmpty) {
      return const CarmelitaCard(
          child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.hourglass_empty_rounded),
        title: Text('No app activity recorded today'),
      ));
    }
    return CarmelitaCard(
        child: Column(
      children: usage
          .take(20)
          .map((stat) => TimelineTile(
                icon: Icons.apps_rounded,
                title: stat.appName,
                subtitle: stat.packageName,
                trailing: Text(durationText(stat.foregroundTime),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ))
          .toList(),
    ));
  }
}

class _GuardianGateRecords extends StatelessWidget {
  const _GuardianGateRecords();
  @override
  Widget build(BuildContext context) {
    final events = GuardianController.instance.gateEvents
        .where((e) => e.person == 'Anna Dela Cruz')
        .toList();
    return CarmelitaCard(
        child: Column(
            children: events
                .map((e) => TimelineTile(
                    icon: e.direction == 'IN' ? Icons.login : Icons.logout,
                    title: '${e.direction} • ${e.verification}',
                    subtitle: '${shortDate(e.time)} • ${timeText(e.time)}',
                    trailing: StatusPill(e.status)))
                .toList()));
  }
}

class GuardianCurfewRequestsPage extends StatelessWidget {
  const GuardianCurfewRequestsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GuardianController.instance;
    return PageFrame(
        title: 'Curfew requests',
        subtitle:
            'Provide supporting input; owner/caretaker makes the final decision',
        child: AnimatedBuilder(
            animation: c,
            builder: (context, _) => Column(
                children: c.curfewRequests
                    .where((r) => r.tenantName == 'Anna Dela Cruz')
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CarmelitaCard(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(r.reason,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17))),
                                  StatusPill(r.guardianStatus)
                                ]),
                                const SizedBox(height: 10),
                                InfoRow(
                                    label: 'Destination', value: r.destination),
                                InfoRow(
                                    label: 'Expected return',
                                    value:
                                        '${shortDate(r.expectedReturn)} • ${timeText(r.expectedReturn)}'),
                                if (r.guardianStatus == 'Input pending') ...[
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: () =>
                                                c.decideCurfew(r, false),
                                            child: const Text('Note concern'))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: FilledButton(
                                            onPressed: () =>
                                                c.decideCurfew(r, true),
                                            child:
                                                const Text('Confirm details'))),
                                  ])
                                ],
                              ])),
                        ))
                    .toList())));
  }
}

class GuardianPaymentStatusPage extends StatelessWidget {
  const GuardianPaymentStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GuardianController.instance;

    return PageFrame(
      title: 'Payment status',
      subtitle: 'Linked tenant balances and verification',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricCard(
              label: 'Outstanding total',
              value: money(controller.outstandingTotal),
              detail: 'Unverified and unpaid records',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            CarmelitaCard(
              child: Column(
                children: controller.payments
                    .map(
                      (payment) => TimelineTile(
                        icon: Icons.receipt_long_outlined,
                        title: payment.label,
                        subtitle: '${money(payment.amount)} • Due '
                            '${shortDate(payment.dueDate)}',
                        trailing: StatusPill(payment.status),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuardianAnnouncementsPage extends StatelessWidget {
  const GuardianAnnouncementsPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Announcements',
      subtitle: 'Notices relevant to guardians',
      child: Column(
          children: MockData.announcements
              .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CarmelitaCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(a.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 7),
                        Text(a.body)
                      ]))))
              .toList()));
}

class GuardianMessagesPage extends StatefulWidget {
  const GuardianMessagesPage({super.key});

  @override
  State<GuardianMessagesPage> createState() => _GuardianMessagesPageState();
}

class _GuardianMessagesPageState extends State<GuardianMessagesPage> {
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GuardianController.instance;

    return PageFrame(
      title: 'Messages',
      subtitle: 'Owner / caretaker communication',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Column(
            children: [
              CarmelitaCard(
                child: Column(
                  children: controller.messages
                      .map(
                        (item) => Align(
                          alignment: item.senderRole == 'guardian'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 560),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              '${item.senderName}: ${item.body}\n'
                              '${timeText(item.sentAt)}',
                              textAlign: item.senderRole == 'guardian'
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
                    icon: const Icon(Icons.send_outlined),
                    onPressed: () {
                      if (message.text.trim().isEmpty) return;
                      controller.sendMessage(message.text);
                      message.clear();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  controller.sendMessage(value);
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

class EmergencySafetyAlertsPage extends StatelessWidget {
  const EmergencySafetyAlertsPage({super.key});
  @override
  Widget build(BuildContext context) => const PageFrame(
      title: 'Dormitory contact info',
      subtitle: 'Static office and emergency contact details',
      child: Column(children: [
        CarmelitaCard(
            child: TimelineTile(
                icon: Icons.info_outline,
                title: 'Dormitory office',
                subtitle: '+63 917 000 0001 • 8:00 AM–8:00 PM',
                trailing: StatusPill('Contact'))),
        SizedBox(height: 12),
        CarmelitaCard(
            child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.emergency_outlined),
                title: Text('Emergency services',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(
                    'For immediate danger, contact local emergency services. This page is a directory, not a live SOS or push-alert feature.'))),
      ]));
}
