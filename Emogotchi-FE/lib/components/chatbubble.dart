import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class CustomChatBubble extends StatefulWidget {
  final String message;
  final Alignment alignment;
  final BubbleType bubbleType;
  final bool isResult;
  final String? imageAsset;
  final Color backgroundColor;
  final Widget? child; // ✅ Typewriter 등 외부 위젯을 위한 child

  const CustomChatBubble({
    Key? key,
    required this.message,
    required this.alignment,
    required this.bubbleType,
    this.isResult = false,
    this.imageAsset,
    required this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  _CustomChatBubbleState createState() => _CustomChatBubbleState();
}

// ✅ 여기에서 TickerProviderStateMixin 추가!
class _CustomChatBubbleState extends State<CustomChatBubble>
    with TickerProviderStateMixin {
  double girlSize = 60;
  double boySize = 60;
  double midSize = 50;
  double resultSize = 40;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.bubbleType == BubbleType.receiverBubble
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.bubbleType == BubbleType.receiverBubble &&
            widget.imageAsset != null)
          Container(
            width: girlSize,
            height: girlSize,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: midSize,
                height: midSize,
                child: ClipOval(
                  child: Image.asset(
                    widget.imageAsset!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        if (widget.bubbleType == BubbleType.receiverBubble)
          const SizedBox(width: 8),
        Flexible(
          child: ChatBubble(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shadowColor: Colors.transparent,
            alignment: widget.alignment,
            backGroundColor: () {
              if (widget.isResult) return Colors.green;
              if (widget.bubbleType == BubbleType.receiverBubble) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
              } else {
                return Colors.blue;
              }
            }(),
            clipper: ChatBubbleClipper5(
              type: widget.bubbleType,
            ),
            child: widget.child ??
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: (widget.bubbleType == BubbleType.sendBubble)
                        ? Colors.white
                        : Theme.of(context).colorScheme.outline,
                  ),
                  overflow: TextOverflow.visible,
                ),
          ),
        ),
        if (widget.bubbleType == BubbleType.sendBubble &&
            widget.imageAsset != null)
          const SizedBox(width: 8),
        if (widget.bubbleType == BubbleType.sendBubble &&
            widget.imageAsset != null)
          Container(
            width: boySize,
            height: boySize,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: !widget.isResult
                  ? SizedBox(
                      width: midSize,
                      height: midSize,
                      child: ClipOval(
                        child: Image.asset(
                          widget.imageAsset!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: resultSize,
                      height: resultSize,
                      child: Image.asset(
                        widget.imageAsset!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

final Set<String> _typedTextCache = {};

class TrueTypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration charDuration;

  const TrueTypewriterText({
    Key? key,
    required this.text,
    required this.style,
    this.charDuration = const Duration(milliseconds: 10),
  }) : super(key: key);

  @override
  State<TrueTypewriterText> createState() => _TrueTypewriterTextState();
}

class _TrueTypewriterTextState extends State<TrueTypewriterText> {
  int _charIndex = 0;
  Timer? _timer;

  bool get _shouldType =>
      !_typedTextCache.contains(widget.text) && widget.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (_shouldType) {
      _typedTextCache.add(widget.text);
      _timer = Timer.periodic(widget.charDuration, (timer) {
        if (!mounted) return;
        if (_charIndex >= widget.text.length) {
          timer.cancel();
          return;
        }
        setState(() {
          _charIndex++;
        });
      });
    } else {
      _charIndex = widget.text.length;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.text.substring(0, _charIndex);

    return Stack(
      children: [
        // Invisible full-width line to reserve height (for first line only)
        Opacity(
          opacity: 0,
          child: Text(
            ' ',
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          displayText,
          style: widget.style,
        ),
      ],
    );
  }
}
