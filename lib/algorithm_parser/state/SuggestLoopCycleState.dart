part of algorithm_parser;

class SmallCycle {
  SmallCycle({
    required this.rawStart,
    required this.rawDelta,
    required this.cumulative,
    required this.order,
  });

  final double rawStart;

  /// 当前是第几个小周期
  ///
  /// 从 1 开始算起，如果当前为 [rawStart]，则 [order] 为 1
  final int order;

  /// 原始增量值
  ///
  /// 若为 null，则表示当前是 [rawStart]
  final double? rawDelta;

  /// 累加后的值，不加 [rawStart]
  final double cumulative;

  /// 可以看作是从 0 点开始叠加
  double get cumulativeWithStart => cumulative + rawStart;

  /// 获取当前小周期 24小时制 的时间点
  double get cumulative24Sys => cumulativeWithStart % 24;

  /// 获取上一个小周期 24小时制 的时间点
  double get lastCumulative24Syc => (cumulative - rawDelta! + rawStart) % 24;

  /// 相对上一个小周期，增量是否大于 24h
  bool get isCross24h => rawDelta! >= 24;

  /// 相对 [rawStart]，跨了几个 24h
  int get cross24hCountFromStart => cumulativeWithStart ~/ 24;

  int get cross24hCountFromLast => rawDelta! ~/ 24;

  /// 相对 [lastCumulative24Syc]，当前24制时间是否在以 00:00 分割的元素中，即需展示"选择"的元素
  /// 返回 bool - 是否是尾巴(如果有尾)
  List<(DateTime, bool)> cross0PointFromLastForNowCount() {
    // 仅存储当前24制时间是否在以 00:00 分割的元素中，即需展示"选择"的元素
    final result = <(DateTime, bool)>[];
    final now = DateTime.now();
    final nowHour = (now.hour * 60 + now.minute) / 60;

    // 1.23 -> 1
    final rawStartFloor = rawStart.floor();
    // 1.23 -> 0.23*60
    final rawStartDecimal = ((rawStart - rawStart.floor()) * 60).toInt();

    // 仅有 rawStart
    if (rawDelta == null) {
      if (rawStart > nowHour) {
        result.add((now.copyWith(hour: rawStartFloor, minute: rawStartDecimal), false));
        return result;
      } else {
        result.add((now.add(const Duration(days: 1)).copyWith(hour: rawStartFloor, minute: rawStartDecimal), false));
        return result;
      }
    }

    // 不超过24h
    if (!isCross24h) {
      // 跨 00:00
      if (lastCumulative24Syc > cumulative24Sys) {
        if (nowHour > lastCumulative24Syc || nowHour < cumulative24Sys) {
          result.add(
            (
              now.add(const Duration(days: 1)).copyWith(
                    hour: cumulative24Sys.floor(),
                    minute: ((cumulative24Sys - cumulative24Sys.floor()) * 60).toInt(),
                  ),
              false
            ),
          );
          return result;
        }
      }
      // 不跨 00:00
      else {
        if (nowHour > lastCumulative24Syc && nowHour < cumulative24Sys) {
          result.add(
            (
              now.copyWith(
                hour: cumulative24Sys.floor(),
                minute: ((cumulative24Sys - cumulative24Sys.floor()) * 60).toInt(),
              ),
              false
            ),
          );
          return result;
        }
      }
    }

    // 超过24h

    // 掐头去尾，跨了多少个 00:00。结果应始终是24小时的倍数，或是0，若不跨天也是0。
    // -头-|-1-|-2-|-3-|-尾-
    // "|"表示 00:00，
    // "1 2 3"序号，表示 count 数量有3个
    final cutTheFrills = (rawDelta! - (24 - lastCumulative24Syc) - cumulative24Sys).toInt();
    int count = cutTheFrills ~/ 24;

    // 是否有头
    if (nowHour > lastCumulative24Syc) {
      result.add(
        (
          now.add(Duration(days: count + 1)).copyWith(
                hour: cumulative24Sys.floor(),
                minute: ((cumulative24Sys - cumulative24Sys.floor()) * 60).toInt(),
              ),
          false
        ),
      );
    }

    for (int i = 0; i < count; i++) {
      result.add(
        (
          now.add(Duration(days: count - i)).copyWith(
                hour: cumulative24Sys.floor(),
                minute: ((cumulative24Sys - cumulative24Sys.floor()) * 60).toInt(),
              ),
          false
        ),
      );
    }

    // 是否有尾
    if (nowHour < cumulative24Sys) {
      result.add(
        (
          now.copyWith(
            hour: cumulative24Sys.floor(),
            minute: ((cumulative24Sys - cumulative24Sys.floor()) * 60).toInt(),
          ),
          true
        ),
      );
    }

    return result;
  }

  /// 将24小时制的时间点浮点数转换成时分字符
  ///
  /// 例如：1.5 => 1:30
  String get getHmText {
    final target = rawDelta == null ? rawStart : cumulative24Sys;
    int totalMinutes = (target * 60).toInt();
    int hoursPart = totalMinutes ~/ 60;
    int minutesPart = totalMinutes % 60;
    return '${hoursPart.toString().padLeft(2, '0')}:${minutesPart.toString().padLeft(2, '0')}';
  }
}

class LoopCycle {
  LoopCycle({
    required this.rawStart,
    required this.rawDeltas,
  }) {
    if (rawStart < 0 && rawStart >= 24) {
      throw "起始时间点必须大于等于0且小于24！";
    }
    startSmallCycle = SmallCycle(
      rawStart: rawStart,
      rawDelta: rawStart,
      cumulative: rawStart,
      order: 1,
    );

    smallCycles = rawDeltas.fold(
      <SmallCycle>[],
      (previousValue, element) {
        previousValue.add(
          SmallCycle(
            rawStart: rawStart,
            rawDelta: element,
            cumulative: previousValue.isEmpty ? element : previousValue.last.cumulative + element,
            order: previousValue.isEmpty ? startSmallCycle.order : previousValue.last.order + 1,
          ),
        );
        return previousValue;
      },
    );
  }

  /// 限制在在 [0,24) 区间内
  final double rawStart;
  final List<double> rawDeltas;

  /// 起始时间
  ///
  /// 若为小数，则按照 60 分钟计算成小数。
  ///
  /// 可以大于 24，但会转换成 24 以内。
  late final SmallCycle startSmallCycle;

  /// 周期增量
  ///
  /// 若为小数，则按照 60 分钟计算成小数。
  ///
  /// 这个变量是原始值，即可以大于 24。
  late final List<SmallCycle> smallCycles;

  List<SmallCycle> get completeSmallCycles => [startSmallCycle, ...smallCycles];

  int get getSmallCycleCount => rawDeltas.length + 1;

  int getLoopCycleOrder(SmallCycle smallCycle) => smallCycles.indexOf(smallCycle);

  factory LoopCycle.fromText({required String text}) {
    final listAll = text.split(" ").where((element) => element.trim() != "").map((e) => double.parse(e)).toList();
    if (listAll.length == 1) {
      return LoopCycle(rawStart: listAll.first, rawDeltas: []);
    } else if (listAll.length > 1) {
      return LoopCycle(rawStart: listAll.first, rawDeltas: listAll.sublist(1, listAll.length));
    } else {
      throw "循环周期格式不正确：$text";
    }
  }

  String toText() => "$rawStart ${rawDeltas.join(" ")}";

  String toTextWithoutStart() => rawDeltas.isEmpty ? "24" : rawDeltas.join(" ");

  /// 将当前时间转换成小数。
  double get getNowTimePoint => DateTime.now().hour + (DateTime.now().minute / 60);

  /// 当前时间点在哪个 [SmallCycle] 前。
  List<SmallCycle> nowBeforeWhich() {
    final nowTimePoint = getNowTimePoint;
    final scs = completeSmallCycles;
    final which = <SmallCycle>[];
    if (scs.length == 1) {
      which.add(scs.first);
    } else {
      for (var element in scs) {
        if (element.rawDelta == null) {
          if (scs.last.cumulative24Sys == element.rawStart) {
            which.add(element);
          } else if (scs.last.cumulative24Sys < element.rawStart) {
            if (scs.last.cumulative24Sys < nowTimePoint && nowTimePoint < element.rawStart) {
              which.add(element);
            }
          } else {
            if (scs.last.cumulative24Sys > element.rawStart) {
              which.add(element);
            }
          }
        } else {
          if (element.isCross24h) {
            which.add(element);
          } else {
            if (element.lastCumulative24Syc < element.cumulative24Sys) {
              if (element.lastCumulative24Syc < nowTimePoint && nowTimePoint < element.cumulative24Sys) {
                which.add(element);
              }
            } else {
              which.add(element);
            }
          }
        }
      }
    }
    return which;
  }

  bool equal({required LoopCycle? target}) => target?.rawStart != rawStart || target?.rawDeltas.join(",") != rawDeltas.join(",");
}

class SuggestLoopCycleState extends ClassificationState {
  SuggestLoopCycleState({
    required super.algorithmWrapper,
    required super.simulationType,
    required super.externalResultHandler,
  });

  static const name = "循环周期算法";

  @override
  String get stateName => name;

  @override
  StateExplain stateExplain() => const StateExplain(
        typeExplain: "循环周期指的是多个小周期形成的一个闭环周期。。",
        useExplain: r'-',
        eventTimeExplain: '在学习前会触发这个算法，以计算之后要以什么样的循环周期进行循环。',
      );

  late LoopCycle result;

  @override
  SuggestLoopCycleState useParse({required String useContent}) {
    // TODO：需要对 userContent 进行计算
    result = LoopCycle.fromText(text: useContent);
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
      c1CurrentSmallCycleTheNthConst: IvFilter(ivf: () async => 0, isReGet: true),
      c2CurrentLoopCycleTheNthConst: IvFilter(ivf: () async => 0, isReGet: true),
    );
  }
}
