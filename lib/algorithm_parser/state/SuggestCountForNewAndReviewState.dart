part of algorithm_parser;

class NewAndReviewCount {
  NewAndReviewCount({
    required this.newCount,
    required this.reviewCount,
  });

  /// 新学习的数量
  final int newCount;

  /// 复习的数量
  final int reviewCount;
}

class ThirdNewAndReviewCount {
  ThirdNewAndReviewCount({
    required this.newCount,
    required this.reviewCount,
    required this.newReviewCount,
  });

  /// 新学习的数量
  final int newCount;

  /// 复习的数量
  final int reviewCount;

  /// 新复习的数量
  final int newReviewCount;
}

/// 下一次展示时间的算法状态
///
/// [result] 距离记忆组启动的时间差(秒)。
///
/// String 类型时的 use 写法：
/// use: 123
///
/// 单位：秒
class SuggestCountForNewAndReviewState extends ClassificationState {
  SuggestCountForNewAndReviewState({
    required super.algorithmWrapper,
    required super.simulationType,
    required super.externalResultHandler,
  });

  static const name = "本周期新学数量和复习数量算法";

  @override
  String get stateName => name;

  @override
  StateExplain stateExplain() => const StateExplain(
        typeExplain: "本周期需要新学和复习的碎片数量的算法。",
        useExplain: r'例如"100,200"，'
            r'逗号左侧为需要新学的数量，'
            r'逗号右侧为需要复习的数量。'
            r'若为"-1,?"，则表示新学数量使用默认配置。'
            r'若为"?,-1"，则表示复习数量使用默认配置。'
            r'若为"-1,-1"，则表示新学数量和复习数量都使用默认配置。',
        eventTimeExplain: '点击底部按钮后会触发这个算法，以计算当前展示的碎片的下一次展示时间点。',
      );

  late NewAndReviewCount result;

  @override
  SuggestCountForNewAndReviewState useParse({required String useContent}) {
    final list = useContent.split(",");

    result = NewAndReviewCount(
      newCount: AlgorithmParser.calculate(list.first).toInt(),
      reviewCount: AlgorithmParser.calculate(list.last).toInt(),
    );
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
