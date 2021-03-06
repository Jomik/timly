import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tyme/model/exercise.dart';

part 'timer_state.freezed.dart';

@freezed
abstract class TimerState with _$TimerState {
  const factory TimerState.setup(Duration setupDuration, Exercise remaining) =
      Setup;

  const factory TimerState.running(Exercise remaining) = Running;

  const factory TimerState.paused(TimerState lastState, Exercise remaining) =
      Paused;

  const factory TimerState.recover(Exercise remaining) = Recover;

  const factory TimerState.finished(Exercise remaining) = Finished;
}
