import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Renders text that can be updated over time and animates only the newly
/// appended characters (ChatGPT/Gemini-style streaming).
class AnimatedStreamingText extends StatefulWidget {
  const AnimatedStreamingText({
    super.key,
    required this.text,
    this.style,
    this.isStreaming = false,
    this.charDelay = const Duration(milliseconds: 12),
    this.charsPerTick = 2,
    this.cursor = '▍',
  });

  final String text;
  final TextStyle? style;

  /// When true, keeps a cursor visible to indicate the message is still arriving.
  final bool isStreaming;

  /// Delay between each reveal tick.
  final Duration charDelay;

  /// How many chars to reveal per tick (higher = faster typing).
  final int charsPerTick;

  /// Cursor glyph to show while streaming.
  final String cursor;

  @override
  State<AnimatedStreamingText> createState() => _AnimatedStreamingTextState();
}

class _AnimatedStreamingTextState extends State<AnimatedStreamingText> {
  String _visible = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _visible = widget.text;
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant AnimatedStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the upstream text changed in a non-append way (reset/edit), snap.
    if (!_isAppend(oldWidget.text, widget.text)) {
      _visible = widget.text;
    }

    // If text grew beyond what we show, animate the delta.
    if (widget.text.length > _visible.length) {
      _syncTimer(forceStart: true);
    } else {
      _syncTimer();
    }
  }

  bool _isAppend(String oldText, String newText) {
    if (newText.length < oldText.length) return false;
    return newText.startsWith(oldText);
  }

  void _syncTimer({bool forceStart = false}) {
    final shouldAnimateMore = widget.text.length > _visible.length;

    if ((forceStart || shouldAnimateMore) && _timer == null) {
      _timer = Timer.periodic(widget.charDelay, (_) {
        if (!mounted) return;
        if (widget.text.length <= _visible.length) {
          // Stop once we caught up and the stream is done.
          if (!widget.isStreaming) {
            _stopTimer();
          }
          return;
        }

        final nextLen = math.min(
          widget.text.length,
          _visible.length + math.max(1, widget.charsPerTick),
        );
        setState(() {
          _visible = widget.text.substring(0, nextLen);
        });
      });
      return;
    }

    if (!shouldAnimateMore && !widget.isStreaming) {
      _stopTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCursor = widget.isStreaming;
    final displayText = showCursor ? '$_visible${widget.cursor}' : _visible;
    return Text(displayText, style: widget.style);
  }
}

