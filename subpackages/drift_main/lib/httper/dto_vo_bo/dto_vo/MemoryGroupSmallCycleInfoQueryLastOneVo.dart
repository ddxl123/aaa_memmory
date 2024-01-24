
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class MemoryGroupSmallCycleInfoQueryLastOneVo extends BaseObject{

    /// 如果为 null，则没有信息。
    MemoryGroupSmartCycleInfo? memory_group_small_cycle_info;


MemoryGroupSmallCycleInfoQueryLastOneVo({

    required this.memory_group_small_cycle_info,

});
  factory MemoryGroupSmallCycleInfoQueryLastOneVo.fromJson(Map<String, dynamic> json) => _$MemoryGroupSmallCycleInfoQueryLastOneVoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$MemoryGroupSmallCycleInfoQueryLastOneVoToJson(this);
  
  
}
