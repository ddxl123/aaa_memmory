part of algorithm_parser;

typedef ResultHandler = Future<AtomResultOrNull> Function(InternalVariableAtom atom);

class IfExpr {
  IfExpr({
    required this.ifContent,
    required this.useContent,
    required this.childIfExpr,
  });

  final String? ifContent;
  final String useContent;
  final IfExpr childIfExpr;
}

/// 状态类型说明
class StateExplain {
  const StateExplain({
    required this.typeExplain,
    required this.useExplain,
    required this.eventTimeExplain,
  });

  /// 类型说明
  final String typeExplain;

  /// 返回值说明
  final String useExplain;

  /// 什么时候触发
  final String eventTimeExplain;
}

abstract class ClassificationState {
  ClassificationState({
    required this.algorithmWrapper,
    required this.simulationType,
    required this.externalResultHandler,
  });

  final AlgorithmWrapper algorithmWrapper;
  final SimulationType simulationType;

  /// 若 [simulationType] 为 [SimulationType.external]，则 [externalResultHandler] 不能为 null。
  ///
  /// 若 [simulationType] 为 [SimulationType.syntaxCheck]，则 [externalResultHandler] 为 null。
  ///
  /// 可以使用 [InternalVariableStorage.filterStorage] 进行筛选。
  final ResultHandler? externalResultHandler;

  InternalVariableStorage internalVariableStorage = InternalVariableStorage();

  String get stateName;

  Type get getStateType => runtimeType;

  /// 返回 String 类型的 result。
  String toStringResult();

  /// 该类型的说明
  StateExplain stateExplain();

  /// 当前状态类的 use 的解析方式。
  ClassificationState useParse({required String useContent});

  /// 处理 if-else-use 已使用的内置变量。
  ///
  /// 根据 [SimulationType] 进行扩展。
  Future<AtomResultOrNull> internalVariablesResultHandler(InternalVariableAtom atom) async {
    if (simulationType == SimulationType.syntaxCheck) {
      return await syntaxCheckInternalVariablesResultHandler(atom);
    } else if (simulationType == SimulationType.external) {
      return await externalInternalVariablesResultHandler(atom);
    }
    throw KnownAlgorithmException('未处理模拟类型：$simulationType');
  }

  /// 语法分析。
  Future<AtomResultOrNull> syntaxCheckInternalVariablesResultHandler(InternalVariableAtom atom);

  /// 外部处理。
  Future<AtomResultOrNull> externalInternalVariablesResultHandler(InternalVariableAtom atom) async {
    if (externalResultHandler == null) throw KnownAlgorithmException('当为 SimulationType.external 类型时，externalResultHandler 不能为 null！');
    return await externalResultHandler!(atom);
  }

  static T filter<T>({
    required String stateName,
    required T Function() buttonData,
    required T Function() familiarity,
    required T Function() nextShowTime,
    required T Function() completeCondition,
    required T Function() suggestCountForNewAndReviewState,
  }) {
    switch (stateName) {
      case ButtonDataState.name:
        return buttonData();
      case FamiliarityState.name:
        return familiarity();
      case NextShowTimeState.name:
        return nextShowTime();
      case CompleteConditionState.name:
        return completeCondition();
      case SuggestCountForNewAndReviewState.name:
        return suggestCountForNewAndReviewState();
      default:
        throw "未处理 $stateName";
    }
  }

  static Future<T> filterFuture<T>({
    required String stateName,
    required Future<T> Function() buttonData,
    required Future<T> Function() familiarity,
    required Future<T> Function() nextShowTime,
    required Future<T> Function() completeCondition,
    required Future<T> Function() suggestCountForNewAndReviewState,
  }) async {
    switch (stateName) {
      case ButtonDataState.name:
        return await buttonData();
      case FamiliarityState.name:
        return await familiarity();
      case NextShowTimeState.name:
        return await nextShowTime();
      case CompleteConditionState.name:
        return await completeCondition();
      case SuggestCountForNewAndReviewState.name:
        return await suggestCountForNewAndReviewState();
      default:
        throw "未处理 $stateName";
    }
  }
}
