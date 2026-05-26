import 'package:flutter/material.dart';

class NumericRepInput extends StatefulWidget {
  const NumericRepInput({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onDone,
    this.onLongPressFail,
    this.min = 0,
    this.max = 50,
  });

  final int initialValue;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onDone;
  final ValueChanged<int>? onLongPressFail;

  @override
  State<NumericRepInput> createState() => _NumericRepInputState();
}

class _NumericRepInputState extends State<NumericRepInput> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(widget.min, widget.max).toInt();
  }

  @override
  void didUpdateWidget(covariant NumericRepInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _value = widget.initialValue.clamp(widget.min, widget.max).toInt();
    }
  }

  void _setValue(int next) {
    final clamped = next.clamp(widget.min, widget.max).toInt();
    if (clamped == _value) {
      return;
    }
    setState(() => _value = clamped);
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = IconButton.styleFrom(
      minimumSize: const Size.square(56),
      tapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      foregroundColor: theme.colorScheme.onSurface,
      shape: const CircleBorder(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          key: const Key('rep-decrement'),
          style: buttonStyle,
          onPressed: _value <= widget.min ? null : () => _setValue(_value - 1),
          icon: const Icon(Icons.remove, size: 32),
        ),
        const SizedBox(width: 24),
        Semantics(
          button: true,
          label: '$_value reps',
          child: InkWell(
            key: const Key('rep-value'),
            borderRadius: BorderRadius.circular(20),
            onTap: () => widget.onDone(_value),
            onLongPress: widget.onLongPressFail == null
                ? null
                : () => widget.onLongPressFail!(_value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 104, minHeight: 80),
              child: Center(
                child: Text(
                  '$_value',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton.filledTonal(
          key: const Key('rep-increment'),
          style: buttonStyle,
          onPressed: _value >= widget.max ? null : () => _setValue(_value + 1),
          icon: const Icon(Icons.add, size: 32),
        ),
      ],
    );
  }
}
