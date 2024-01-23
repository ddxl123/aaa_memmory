import 'package:drift_main/drift/DriftDb.dart';

import 'parser.dart';

/// 注意接收的是 if-else 原生语句。
class DefaultAlgorithmOfRaw {
  DefaultAlgorithmOfRaw({
    required this.defaultTitle,
    required this.memoryAlgorithm,
    required this.list,
    required this.officialDefault,
  });

  /// 当为默认时，即没有 [memoryAlgorithm] 时
  final String? defaultTitle;

  final MemoryAlgorithm? memoryAlgorithm;

  String get getTitle => memoryAlgorithm?.title ?? defaultTitle!;

  /// 如果元素为 null，则表示该算法为空算法。
  final List<ClassificationState> list;

  /// 是否官方默认
  final bool officialDefault;

  /// 是否展开 [list]。
  bool isExpand = false;

  static final defaultList = <DefaultAlgorithmOfRaw>[
    ebbinghaus(),
  ];

  static DefaultAlgorithmOfRaw ebbinghaus() {
    return DefaultAlgorithmOfRaw(
      officialDefault: false,
      defaultTitle: "艾宾浩斯复习周期",
      memoryAlgorithm: null,
      list: ClassificationState.all(
        buttonData: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        1;下一个
      }
      """);
          return ButtonDataState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
        familiarity: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        1
      }
      """);
          return FamiliarityState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
        nextShowTime: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      sts = ${InternalVariableConstantHandler.k3StudiedTimesConst.name}
      cct = ${InternalVariableConstantHandler.k7CurrentClickTimeConst.name}
      if(sts == 0){
        cct + 5 * 60
      }else if(sts == 1){
        cct + 20 * 60
      }else if(sts == 2){
        cct + 60 * 60 * 8
      }else if(sts == 3){
        cct + 60 * 60 * 24
      }else if(sts == 4){
        cct + 60 * 60 * 24 * 2
      }else if(sts == 5){
        cct + 60 * 60 * 24 * 4
      }else if(sts == 6){
        cct + 60 * 60 * 24 * 7
      }else if(sts == 7){
        cct + 60 * 60 * 24 * 16
      }else{
        cct + 60 * 60 * 24 * 30
      }
      """);
          return NextShowTimeState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
        completeCondition: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      if(${InternalVariableConstantHandler.i4ClickFamiliarityConst.name + "_1last"}>0.9){
        true
      }
      """);
          return CompleteConditionState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
        suggestLoopCycle: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        4
      }
      """);
          return SuggestLoopCycleState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
        suggestCountForNewAndReviewState: () {
          final result = AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        -1,-1
      }
      """);
          return SuggestCountForNewAndReviewState(
            algorithmWrapper: result?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : result!.algorithmWrapper!,
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          );
        },
      ),
    );
  }
}
