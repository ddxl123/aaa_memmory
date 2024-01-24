
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class QuerySingleMemoryGroupAllSmallCycleInfoVo extends BaseObject{

    /// 查询到的单个记忆组的全部小周期信息
    List<MemoryGroupSmartCycleInfo> memory_group_small_cycle_infos_list;


QuerySingleMemoryGroupAllSmallCycleInfoVo({

    required this.memory_group_small_cycle_infos_list,

});
  factory QuerySingleMemoryGroupAllSmallCycleInfoVo.fromJson(Map<String, dynamic> json) => _$QuerySingleMemoryGroupAllSmallCycleInfoVoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$QuerySingleMemoryGroupAllSmallCycleInfoVoToJson(this);
  
  
}
