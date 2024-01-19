import 'parser.dart';

/// 注意接收的是 if-else 原生语句。
class DefaultAlgorithmOfRaw {
  DefaultAlgorithmOfRaw({
    required this.title,
    required this.list,
  });

  final String title;
  final List<ClassificationState> list;

  /// 是否展开 [list]。
  bool isExpand = false;

  static final defaultList = <DefaultAlgorithmOfRaw>[
    ebbinghaus(),
  ];

  static DefaultAlgorithmOfRaw ebbinghaus() {
    return DefaultAlgorithmOfRaw(
      title: "艾宾浩斯复习周期",
      list: [
        ButtonDataState(
          algorithmWrapper: AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        1;下一个
      }
      """),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        FamiliarityState(
          algorithmWrapper: AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        1
      }
      """),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        NextShowTimeState(
          algorithmWrapper: AlgorithmBidirectionalParsing.parseFromString("""
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
      """),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        CompleteConditionState(
          algorithmWrapper: AlgorithmBidirectionalParsing.parseFromString("""
      if(${InternalVariableConstantHandler.i4ClickFamiliarityConst.name + "_1last"}>0.9){
        true
      }
      """),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        SuggestCountForNewAndReviewState(
          algorithmWrapper: AlgorithmBidirectionalParsing.parseFromString("""
      if(true){
        -1,-1
      }
      """),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
      ],
    );
  }
}
