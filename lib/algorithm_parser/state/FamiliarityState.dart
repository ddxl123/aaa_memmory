part of algorithm_parser;

class FamiliarityState extends ClassificationState {
  FamiliarityState({
    required super.algorithmWrapper,
    required super.simulationType,
    required super.externalResultHandler,
  });

  static const name = "熟悉度变化算法";

  @override
  String get stateName => name;

  @override
  StateExplain stateExplain() => const StateExplain(
        typeExplain: "当学习了一个碎片后，会记录一系列数据，该算法反映了在本次学习后的熟悉度。",
        useExplain: r'范围通常在 0~1.0，当然也可以大于1.0，甚至可以是 100~1000，因为它只是个算法变量，可根据算法本身去定义其数值意义和范围。',
        eventTimeExplain: '点击底部按钮后会触发这个算法，以计算当前展示的碎片的熟悉度。',
      );

  late double result;

  @override
  FamiliarityState useParse({required String useContent}) {
    result = AlgorithmParser.calculate(useContent);
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
