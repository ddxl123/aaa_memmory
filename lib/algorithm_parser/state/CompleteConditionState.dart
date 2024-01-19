part of algorithm_parser;

class CompleteConditionState extends ClassificationState {
  CompleteConditionState({
    required super.algorithmWrapper,
    required super.simulationType,
    required super.externalResultHandler,
  });

  static const name = "完成条件算法";

  @override
  String get stateName => name;

  @override
  StateExplain stateExplain() => const StateExplain(
        typeExplain: "某个碎片完成条件的算法，完成意味着在当前记忆组学习时不会再出现该碎片。",
        useExplain: r'true" 表示完成，'
            r'"false" 表示未完成。',
        eventTimeExplain: '点击底部按钮后会触发这个算法，以计算当前展示的碎片的完成状态。',
      );

  late bool result;

  @override
  CompleteConditionState useParse({required String useContent}) {
    result = bool.parse(useContent);
    return this;
  }

  @override
  String toStringResult() => result.toString();

  @override
  Future<AtomResultOrNull> syntaxCheckInternalVariablesResultHandler(InternalVariableAtom atom) async {
    return await atom.filter(
      storage: internalVariableStorage,
      k1countAllConst: IvFilter(ivf: () async => 1, isReGet: true),
      k2CountStopConst: IvFilter(ivf: () async => 1, isReGet: true),
      k2CountCompleteConst: IvFilter(ivf: () async => 1, isReGet: true),
      k2CountReviewConst: IvFilter(ivf: () async => 1, isReGet: true),
      k2CountNeverConst: IvFilter(ivf: () async => 1, isReGet: true),
      k3StudiedTimesConst: IvFilter(ivf: () async => math.Random().nextInt(9) + 1, isReGet: true),
      k4CurrentShowTimeConst: IvFilter(ivf: () async => 1, isReGet: true),
      k5CurrentShowFamiliarityConst: IvFilter(ivf: () async => math.Random().nextDouble() * 200, isReGet: true),
      k6CurrentButtonValuesConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      k6CurrentButtonValueConst: IvFilter(ivf: () async => 1, isReGet: true),
      k7CurrentClickTimeConst: IvFilter(ivf: () async => 1, isReGet: true),
      i1ActualShowTimeConst: IvFilter(ivf: () async => [1, 1, 1], isReGet: true),
      i2NextPlanShowTimeConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      i3ShowFamiliarityConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      i4ClickFamiliarityConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      i5ClickTimeConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      i6ClickValueConst: IvFilter(ivf: () async => [1, 2, 3], isReGet: true),
      i7ButtonValuesConst: IvFilter(
          ivf: () async => [
                [1],
                [2],
                [3]
              ],
          isReGet: true),
    );
  }
}
