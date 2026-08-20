import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../data/mock_data.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../responsive/breakpoints.dart';
import '../theme/app_theme.dart';
import 'adaptive_shell.dart';

class CarmelitaLogo extends StatelessWidget {
  const CarmelitaLogo({
    this.height = 56,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          AppAssets.logo,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class MutedDashboardItem {
  const MutedDashboardItem(
      {required this.label,
      required this.value,
      required this.detail,
      required this.icon,
      required this.color,
      this.onTap});
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class MutedDashboardGrid extends StatelessWidget {
  const MutedDashboardGrid({required this.items, super.key});
  final List<MutedDashboardItem> items;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth < 700
            ? (items.length >= 4 ? 4 : 2)
            : items.length.clamp(2, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio:
                constraints.maxWidth < 500 && columns == 4 ? .65 : 1.15,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: .035),
                  border: Border.all(color: item.color.withValues(alpha: .10)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: item.color.withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(9)),
                          child: Icon(item.icon, color: item.color, size: 19)),
                      const Spacer(),
                      Text(item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: item.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 17)),
                      const SizedBox(height: 2),
                      Text(item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w800)),
                      Text(item.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 9)),
                    ]),
              ),
            );
          },
        );
      });
}

class MutedActionItem {
  const MutedActionItem(
      {required this.label,
      required this.detail,
      required this.icon,
      required this.color,
      required this.onTap});
  final String label;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class MutedActionGrid extends StatelessWidget {
  const MutedActionGrid({required this.items, super.key});
  final List<MutedActionItem> items;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: constraints.maxWidth < 520 ? 2.15 : 2.8),
          itemBuilder: (context, index) {
            final item = items[index];
            return CarmelitaCard(
              onTap: item.onTap,
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: item.color.withValues(alpha: .075),
                        borderRadius: BorderRadius.circular(11)),
                    child: Icon(item.icon, color: item.color, size: 21)),
                const SizedBox(width: 9),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(item.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 10)),
                    ])),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Theme.of(context).colorScheme.outline),
              ]),
            );
          },
        );
      });
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.heroTitle,
    this.useScriptTitle = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? heroTitle;
  final bool useScriptTitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final navScope = CarmelitaNavScope.maybeOf(context);
    final canPop = Navigator.of(context).canPop();
    final extraBottom = navScope == null ? 24.0 : 132.0;
    final canShowNotifications =
        SessionController.instance.currentUser != null &&
            title.toLowerCase() != 'notifications';
    final actionSpaceOccupied = actions?.isNotEmpty ?? false;

    void openNotifications() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const _GlobalNotificationsPage()),
        );

    final notificationButton = IconButton(
      tooltip: 'Notifications',
      onPressed: openNotifications,
      icon: const Icon(Icons.notifications_none_rounded),
    );

    Widget? resolvedFloatingActionButton = floatingActionButton;
    if (canShowNotifications && actionSpaceOccupied) {
      final notificationFab = IconButton(
        tooltip: 'Notifications',
        onPressed: openNotifications,
        icon: const Icon(Icons.notifications_none_rounded),
      );
      resolvedFloatingActionButton = floatingActionButton == null
          ? notificationFab
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                notificationFab,
                const SizedBox(height: 12),
                floatingActionButton!,
              ],
            );
    }

    return Scaffold(
      extendBody: navScope != null,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: navScope != null
                ? 'Menu'
                : canPop
                    ? 'Back'
                    : 'Menu',
            onPressed: () {
              if (navScope != null) {
                navScope.openMenu();
              } else if (canPop) {
                Navigator.of(context).maybePop();
              }
            },
            icon: Icon(
              navScope != null
                  ? Icons.menu_rounded
                  : Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heroTitle ?? title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: useScriptTitle ? 'GreatVibes' : null,
                    fontSize: useScriptTitle ? 30 : null,
                    fontWeight:
                        useScriptTitle ? FontWeight.w600 : FontWeight.w700,
                  ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        actions: [
          ...?actions,
          if (canShowNotifications && !actionSpaceOccupied) notificationButton,
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: resolvedFloatingActionButton,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: ResponsiveContent(
            padding: EdgeInsets.fromLTRB(
              AppBreakpoints.horizontalPadding(context),
              6,
              AppBreakpoints.horizontalPadding(context),
              extraBottom,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: .975, end: 1),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, value, page) {
                return Opacity(
                  opacity: ((value - .975) / .025).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: page,
                  ),
                );
              },
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalNotificationsPage extends StatelessWidget {
  const _GlobalNotificationsPage();

  int _urgency(String type) => type == 'Gate'
      ? 3
      : type == 'Payment'
          ? 2
          : 1;

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
              .map((notification) => TimelineTile(
                    icon: notification.type == 'Payment'
                        ? Icons.payments_outlined
                        : notification.type == 'Gate'
                            ? Icons.sensor_door_outlined
                            : Icons.build_outlined,
                    title: notification.title,
                    subtitle:
                        '${notification.body}\n${shortDate(notification.time)} • ${timeText(notification.time)}',
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class CarmelitaCard extends StatelessWidget {
  const CarmelitaCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.emphasis = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<CarmelitaThemeExtension>();
    final scheme = Theme.of(context).colorScheme;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color:
            emphasis ? scheme.primary.withValues(alpha: .075) : scheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(22),
        ),
        border: Border.all(
          color: emphasis
              ? scheme.primary.withValues(alpha: .22)
              : ext?.border ?? Theme.of(context).dividerColor,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .032),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 1),
      duration: const Duration(milliseconds: 120),
      builder: (context, value, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(22),
            ),
            onTap: onTap,
            child: content,
          ),
        );
      },
    );
  }
}

class ElegantHeader extends StatelessWidget {
  const ElegantHeader({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.useScriptTitle = true,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool useScriptTitle;

  Widget _copy(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 350 ? 29.0 : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: useScriptTitle ? 'GreatVibes' : null,
                fontSize: useScriptTitle ? titleSize + 10 : titleSize,
                fontWeight: useScriptTitle ? FontWeight.w600 : FontWeight.w700,
                height: useScriptTitle ? 1.15 : null,
                letterSpacing: useScriptTitle ? 0 : null,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (trailing == null) {
      return _copy(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: trailing!,
              ),
              const SizedBox(height: 12),
              _copy(context),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _copy(context)),
            const SizedBox(width: 12),
            Flexible(
              flex: 0,
              child: trailing!,
            ),
          ],
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    this.trailing,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.text, {
    this.icon,
    super.key,
  });

  final String text;
  final IconData? icon;

  Color _color() {
    final value = text.toLowerCase();
    if (value.contains('verified') ||
        value.contains('approved') ||
        value.contains('online') ||
        value.contains('locked') ||
        value == 'in' ||
        value == 'clear' ||
        value.contains('resolved')) {
      return AppColors.success;
    }
    if (value.contains('reject') ||
        value.contains('late') ||
        value.contains('offline') ||
        value.contains('alert') ||
        value.contains('escalated')) {
      return AppColors.danger;
    }
    if (value.contains('pending') ||
        value.contains('ongoing') ||
        value.contains('review') ||
        value.contains('waiting') ||
        value.contains('due') ||
        value.contains('submitted')) {
      return AppColors.warning;
    }
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 138),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .105),
          borderRadius: const BorderRadius.all(
            Radius.circular(999),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.detail,
    this.onTap,
    this.highlight = false,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? detail;
  final VoidCallback? onTap;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CarmelitaCard(
      onTap: onTap,
      emphasis: highlight,
      padding: const EdgeInsets.all(15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final veryNarrow = constraints.maxWidth < 145;
          final iconSize = veryNarrow ? 40.0 : 44.0;

          final accent = color ?? Theme.of(context).colorScheme.primary;
          final iconBox = Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .075),
              borderRadius: const BorderRadius.all(
                Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: veryNarrow ? 19 : 21,
              color: accent,
            ),
          );

          final copy = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: veryNarrow ? 18 : 21,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 4),
                Text(
                  detail!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );

          if (veryNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconBox,
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .30),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                copy,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconBox,
              const SizedBox(width: 12),
              Expanded(child: copy),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .30),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return CarmelitaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .075),
              borderRadius: const BorderRadius.all(
                Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 11.5,
                  height: 1.18,
                ),
          ),
        ],
      ),
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.children,
    this.minTileWidth = 220,
    super.key,
  });

  final List<Widget> children;
  final double minTileWidth;

  int _columnsFor(double width) {
    if (width < 320) return 1;
    if (width < 600) return 2;

    const spacing = 12.0;
    final estimated = ((width + spacing) / (minTileWidth + spacing)).floor();
    return estimated.clamp(2, 4);
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 330
            ? 2
            : width < 700
                ? 4
                : 6;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    required this.image,
    required this.title,
    required this.subtitle,
    this.height = 210,
    super.key,
  });

  final String image;
  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = AppBreakpoints.isPhone(context)
        ? height.clamp(180, 250).toDouble()
        : height.clamp(220, 320).toDouble();

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(26)),
      child: SizedBox(
        height: effectiveHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .76),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttentionCard extends StatelessWidget {
  const AttentionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CarmelitaCard(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 320;

          final leading = Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .09),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );

          if (compact && status != null) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      const SizedBox(height: 10),
                      StatusPill(status!),
                    ],
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 13),
              Expanded(child: copy),
              if (status != null) ...[
                const SizedBox(width: 10),
                StatusPill(status!),
              ] else if (onTap != null) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 13),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 370;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 19,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                ],
                SizedBox(
                  width: 118,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  const TimelineTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 3,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .085),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Icon(
          icon,
          size: 21,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 42),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

void showAppSnackBar(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String money(double value) => '₱${value.toStringAsFixed(0)}';

String shortDate(DateTime value) => '${value.month}/${value.day}/${value.year}';

String timeText(DateTime value) {
  final hour =
      value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
}
