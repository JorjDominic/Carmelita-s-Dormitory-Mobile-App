import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ranked = [...MockData.notifications]
      ..sort((a, b) => _urgency(b.type).compareTo(_urgency(a.type)));
    return PageFrame(
      title: 'Notifications',
      subtitle: 'Updates ranked by urgency',
      child: CarmelitaCard(
          child: Column(
              children: ranked
                  .map((n) => TimelineTile(
                        icon: n.type == 'Payment'
                            ? Icons.payments_outlined
                            : n.type == 'Gate'
                                ? Icons.sensor_door_outlined
                                : Icons.build_outlined,
                        title: n.title,
                        subtitle:
                            '${n.body}\n${shortDate(n.time)} • ${timeText(n.time)}',
                      ))
                  .toList())),
    );
  }

  int _urgency(String type) => type == 'Gate'
      ? 3
      : type == 'Payment'
          ? 2
          : 1;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.currentUser!;
    final role = user.role == UserRole.ownerCaretaker
        ? 'Owner / Caretaker'
        : user.role == UserRole.guardian
            ? 'Guardian'
            : 'Tenant';
    return PageFrame(
      title: 'Profile',
      subtitle: 'Personal and contact information',
      actions: [
        IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage())),
            icon: const Icon(Icons.notifications_outlined))
      ],
      child: Column(children: [
        CarmelitaCard(
            child: Row(children: [
          CircleAvatar(
              radius: 34,
              child: Text(user.name.substring(0, 1),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(user.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 8),
                StatusPill(role),
              ])),
        ])),
        const SizedBox(height: 16),
        CarmelitaCard(
            child: Column(children: [
          InfoRow(
              label: 'Full name', value: user.name, icon: Icons.person_outline),
          InfoRow(label: 'Email', value: user.email, icon: Icons.mail_outline),
          InfoRow(
              label: 'Phone', value: user.phone, icon: Icons.phone_outlined),
        ])),
        const SizedBox(height: 16),
        ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Appearance, privacy, password, and sign out'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsPage()))),
      ]),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <({ThemeMode mode, IconData icon, String label})>[
      (
        mode: ThemeMode.system,
        icon: Icons.settings_suggest_outlined,
        label: 'System',
      ),
      (
        mode: ThemeMode.light,
        icon: Icons.light_mode_outlined,
        label: 'Light',
      ),
      (
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_outlined,
        label: 'Dark',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 350;

        if (vertical) {
          return Column(
            children: options
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ThemeModeChoice(
                      mode: option.mode,
                      icon: option.icon,
                      label: option.label,
                      selected: value == option.mode,
                      onTap: () => onChanged(option.mode),
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: options
              .map(
                (option) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option.mode == ThemeMode.dark ? 0 : 8,
                    ),
                    child: _ThemeModeChoice(
                      mode: option.mode,
                      icon: option.icon,
                      label: option.label,
                      selected: value == option.mode,
                      onTap: () => onChanged(option.mode),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ThemeModeChoice extends StatelessWidget {
  const _ThemeModeChoice({
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: .11)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: .35)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: .68),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return PageFrame(
      title: 'Settings',
      subtitle: 'Appearance, privacy, and account',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ElegantHeader(
              eyebrow: 'Preferences',
              title: 'Make the app feel right for you.',
              subtitle:
                  'Choose how Carmelita looks on this device. System mode follows your iPhone or Android setting automatically.',
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              'Appearance',
              subtitle: 'System, Light, or Dark',
            ),
            const SizedBox(height: 10),
            CarmelitaCard(
              emphasis: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ThemeModeSelector(
                    value: controller.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.themeMode == ThemeMode.system
                        ? 'Following your device appearance.'
                        : controller.themeMode == ThemeMode.light
                            ? 'Light appearance is active.'
                            : 'Dark appearance is active.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('Notifications & privacy'),
            const SizedBox(height: 10),
            CarmelitaCard(
              child: Column(
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notifications_outlined),
                    title: Text(
                      'Notification preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Payment, gate, maintenance, curfew, and announcement alerts.',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.fingerprint_outlined),
                    title: const Text('Device binding',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                        'Register this device and enable the native biometric app lock.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const DeviceBindingPage())),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.privacy_tip_outlined),
                    title: Text(
                      'Privacy and permissions',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Camera, location, storage, and notification permissions.',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.password_outlined),
                    title: Text(
                      'Change password',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Will connect to Supabase Auth in the backend phase.',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  SessionController.instance.signOut();

                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceBindingPage extends StatelessWidget {
  const DeviceBindingPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Device binding',
        subtitle: 'One tenant account, one trusted device',
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(children: [
              const CarmelitaCard(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.phonelink_lock_outlined),
                      title: Text('Register this device'),
                      subtitle: Text(
                          'Binding supports accurate geofencing and protects access with fingerprint or Face ID. Native biometric and device-token services are not connected yet.'))),
              const SizedBox(height: 14),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                      onPressed: () => showAppSnackBar(context,
                          'Device binding requires native biometric and backend integration.'),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Bind and enable biometrics'))),
            ])),
      );
}

class OtpPage extends StatelessWidget {
  const OtpPage({required this.email, super.key});
  final String email;
  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Verification code',
        subtitle: email,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                  'Enter the verification code sent to your email. This is a frontend placeholder until authentication is connected.'),
              const SizedBox(height: 20),
              const TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                      labelText: '6-digit code',
                      prefixIcon: Icon(Icons.pin_outlined))),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () {
                        showAppSnackBar(context,
                            'Verification UI completed. Backend connection comes next.');
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: const Text('Verify'))),
            ])),
      );
}

class DormitoryInfoPage extends StatelessWidget {
  const DormitoryInfoPage({super.key});
  @override
  Widget build(BuildContext context) => const PageFrame(
        title: "Carmelita's Dormitory",
        subtitle: 'Dormitory information',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PhotoHero(
              image: AppAssets.exterior,
              title: 'More than a place to stay',
              subtitle: 'A place to belong',
              height: 270),
          SizedBox(height: 20),
          CarmelitaCard(
              child: Column(children: [
            InfoRow(
                label: 'Type',
                value: 'Dormitory for girls',
                icon: Icons.home_outlined),
            InfoRow(
                label: 'Room setup',
                value: 'Up to 4 tenants per room',
                icon: Icons.bed_outlined),
            InfoRow(
                label: 'Location',
                value: 'Brgy. Concepcion, Baliwag, Bulacan',
                icon: Icons.location_on_outlined),
          ])),
        ]),
      );
}
