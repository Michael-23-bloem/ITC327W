import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/akea_theme.dart';

class AkeaCard extends StatelessWidget {
  const AkeaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AkeaColors.card,
        borderRadius: BorderRadius.circular(20),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AkeaPageHeader extends StatelessWidget {
  const AkeaPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: AkeaColors.muted, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
          ...actions.map(
            (w) => Padding(padding: const EdgeInsets.only(left: 10), child: w),
          ),
        ],
      ),
    );
  }
}

enum AkeaButtonStyle { primary, gold, outline, ghost, danger, dangerSoft }

class AkeaButton extends StatelessWidget {
  const AkeaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AkeaButtonStyle.primary,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AkeaButtonStyle style;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      AkeaButtonStyle.primary => (AkeaColors.purple, Colors.white, null),
      AkeaButtonStyle.gold => (AkeaColors.gold, Colors.white, null),
      AkeaButtonStyle.outline => (Colors.white, AkeaColors.ink, AkeaColors.border),
      AkeaButtonStyle.ghost => (Colors.transparent, AkeaColors.ink, AkeaColors.border),
      AkeaButtonStyle.danger => (AkeaColors.purple, Colors.white, null),
      AkeaButtonStyle.dangerSoft => (
        AkeaColors.statusDanger,
        AkeaColors.statusDangerInk,
        null,
      ),
    };

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14),
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 44,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          disabledBackgroundColor: bg.withValues(alpha: 0.6),
          foregroundColor: fg,
          side: border == null ? null : BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: child,
      ),
    );
  }
}

class AkeaStatusChip extends StatelessWidget {
  const AkeaStatusChip({
    super.key,
    required this.label,
    this.kind = AkeaChipKind.neutral,
  });

  final String label;
  final AkeaChipKind kind;

  factory AkeaStatusChip.forStatus(String status, {int? hoursLeft}) {
    final s = status.toLowerCase();
    if (s == 'pending' && hoursLeft != null && hoursLeft <= 6 && hoursLeft >= 0) {
      return AkeaStatusChip(label: '${hoursLeft}h left', kind: AkeaChipKind.warn);
    }
    if (s == 'pending' || s == 'new') {
      return const AkeaStatusChip(label: 'New', kind: AkeaChipKind.info);
    }
    if (s.contains('confirm')) {
      return const AkeaStatusChip(label: 'Confirmed', kind: AkeaChipKind.ok);
    }
    if (s.contains('deposit') || s == 'awaiting') {
      return const AkeaStatusChip(label: 'Awaiting deposit', kind: AkeaChipKind.warn);
    }
    if (s.contains('suspend')) {
      return const AkeaStatusChip(label: 'Suspended', kind: AkeaChipKind.danger);
    }
    if (s == 'active') {
      return const AkeaStatusChip(label: 'Active', kind: AkeaChipKind.ok);
    }
    if (s == 'open') {
      return const AkeaStatusChip(label: 'Open', kind: AkeaChipKind.warn);
    }
    if (s == 'done' || s.contains('complete')) {
      return const AkeaStatusChip(label: 'Done', kind: AkeaChipKind.ok);
    }
    return AkeaStatusChip(label: status, kind: AkeaChipKind.neutral);
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      AkeaChipKind.info => (AkeaColors.statusNew, AkeaColors.statusNewInk),
      AkeaChipKind.warn => (AkeaColors.statusWarn, AkeaColors.statusWarnInk),
      AkeaChipKind.ok => (AkeaColors.statusOk, AkeaColors.statusOkInk),
      AkeaChipKind.danger => (AkeaColors.statusDanger, AkeaColors.statusDangerInk),
      AkeaChipKind.neutral => (AkeaColors.cream, AkeaColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum AkeaChipKind { info, warn, ok, danger, neutral }

class AkeaLogoMark extends StatelessWidget {
  const AkeaLogoMark({super.key, this.size = 42});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AkeaColors.gold,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'A',
        style: GoogleFonts.playfairDisplay(
          color: AkeaColors.sidebar,
          fontSize: size * 0.52,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AkeaPage extends StatelessWidget {
  const AkeaPage({super.key, required this.child, this.maxWidth = 1180});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AkeaColors.bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AkeaFieldLabel extends StatelessWidget {
  const AkeaFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AkeaColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AkeaStepperRow extends StatelessWidget {
  const AkeaStepperRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AkeaColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
          ),
          SizedBox(
            width: 28,
            child: Text('$value', textAlign: TextAlign.center),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 16),
          ),
        ],
      ),
    );
  }
}

class AkeaTrackerStep extends StatelessWidget {
  const AkeaTrackerStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final AkeaStepState state;

  @override
  Widget build(BuildContext context) {
    final Widget mark = switch (state) {
      AkeaStepState.done => const CircleAvatar(
        radius: 11,
        backgroundColor: Color(0xFF2F8A4A),
        child: Icon(Icons.check, size: 14, color: Colors.white),
      ),
      AkeaStepState.current => const CircleAvatar(
        radius: 11,
        backgroundColor: AkeaColors.gold,
        child: Icon(Icons.circle, size: 8, color: Colors.white),
      ),
      AkeaStepState.upcoming => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AkeaColors.border, width: 2),
          color: Colors.white,
        ),
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mark,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: state == AkeaStepState.upcoming
                        ? AkeaColors.muted
                        : AkeaColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AkeaColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AkeaStepState { done, current, upcoming }
