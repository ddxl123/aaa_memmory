
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class QueryCurrentMemoryGroupSmallCycleInfoVo extends BaseObject{

    /// 如果为 null，则没有正在执行的小周期
    MemoryGroupSmartCycleInfo? memory_group_small_cycle_info;


QueryCurrentMemoryGroupSmallCycleInfoVo({

    required this.memory_group_small_cycle_info,

});
  factory QueryCurrentMemoryGroupSmallCycleInfoVo.fromJson(Map<String, dynamic> json) => _$QueryCurrentMemoryGroupSmallCycleInfoVoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$QueryCurrentMemoryGroupSmallCycleInfoVoToJson(this);
  
  
}
