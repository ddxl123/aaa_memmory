
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class QuerySingleMemoryGroupAllSmallCycleInfoDto extends BaseObject{

    /// 要查询的记忆组
    int memory_group_id;

    /// 填充字段1
    bool? dto_padding_1;


QuerySingleMemoryGroupAllSmallCycleInfoDto({

    required this.memory_group_id,

    required this.dto_padding_1,

});
  factory QuerySingleMemoryGroupAllSmallCycleInfoDto.fromJson(Map<String, dynamic> json) => _$QuerySingleMemoryGroupAllSmallCycleInfoDtoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$QuerySingleMemoryGroupAllSmallCycleInfoDtoToJson(this);
  
  
          
  @JsonKey(ignore: true)
  int? code;

  @JsonKey(ignore: true)
  String? successMessage;

  @JsonKey(ignore: true)
  HttperException? httperException;
  
  @JsonKey(ignore: true)
  StackTrace? st;

  @JsonKey(ignore: true)
  QuerySingleMemoryGroupAllSmallCycleInfoVo? vo;

  /// 内部抛出的异常将在 [otherException] 中捕获。
  Future<T> handleCode<T>({
    // code 为 null 时的异常（request 函数内部捕获到的异常）
    Future<T> Function(int? code, HttperException httperException, StackTrace st)? otherException,

    // message: 获取成功！
    // explain: 查询单个记忆组的全部小周期信息。
    required Future<T> Function(String showMessage, QuerySingleMemoryGroupAllSmallCycleInfoVo vo) code200201,
    
    }) async {
    try {

        if (code == 200201) return await code200201(successMessage!, vo!);

    } catch (handleE, handleSt) {
      if (otherException == null) {
        if (httperException != null) {
          throw httperException!;
        }
        rethrow;
      }
      if (httperException != null) {
        return await otherException(code, httperException!, st ?? handleSt);
      }
      if (handleE is HttperException) {
        return await otherException(code, handleE, handleSt);
      }
      return await otherException(code, HttperException(showMessage: '请求异常！', debugMessage: handleE.toString()), handleSt);
    }
    // 当以流的形式响应时，下面代码被忽略。
    if (code != null) {
      if(otherException==null) throw HttperException(showMessage: '请求异常！', debugMessage: '响应码 $code 未处理！');
      return await otherException(code, HttperException(showMessage: '请求异常！', debugMessage: '响应码 $code 未处理！'), st!);
    }
    if(otherException==null) {
      throw HttperException(showMessage: "请求异常", debugMessage: '子 handleCode 异常：\n子 code：$code\n子 StackTrace：\n$st\n${httperException!.showMessage}\n${httperException!.debugMessage}');
    }
    return await otherException(code, httperException!, st!);
  }
}
