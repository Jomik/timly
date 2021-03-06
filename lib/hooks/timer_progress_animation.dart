import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tyme/paints/timer_progress_paint.dart';

/// This function will provide an animation that will animate
/// the given [progress] in respect of the old [progress] from an
/// older state. It's used to animate the TimerProgress and should be used
/// in combination with [TimerProgressPainter]
Animation useTimerProgressAnimation(
    {@required AnimationController controller, @required double progress}) {
  return Hook.use(_TimerProgressAnimation(controller, progress));
}

class _TimerProgressAnimation extends Hook<Animation> {
  final AnimationController animationController;
  final double currentProgress;

  _TimerProgressAnimation(this.animationController, this.currentProgress);

  @override
  _TimerProgressAnimationState createState() => _TimerProgressAnimationState();
}

class _TimerProgressAnimationState
    extends HookState<Animation, _TimerProgressAnimation> {
  Animation _timerProgressAnimation;

  @override
  void initHook() {
    _timerProgressAnimation =
        Tween(begin: hook.currentProgress, end: hook.currentProgress)
            .animate(hook.animationController);
    super.initHook();
    hook.animationController.forward(from: 0.0);
  }

  @override
  void didUpdateHook(_TimerProgressAnimation oldHook) {
    _timerProgressAnimation =
        Tween(begin: oldHook.currentProgress, end: hook.currentProgress)
            .animate(hook.animationController);
    hook.animationController.forward(from: 0.0);
    super.didUpdateHook(oldHook);
  }

  @override
  Animation build(BuildContext context) => _timerProgressAnimation;
}
