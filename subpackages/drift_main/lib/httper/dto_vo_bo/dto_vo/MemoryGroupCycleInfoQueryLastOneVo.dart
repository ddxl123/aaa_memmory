
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class MemoryGroupCycleInfoQueryLastOneVo extends BaseObject{

    /// 如果为 null，则没有信息。
    MemoryGroupSmartCycleInfo? memory_group_cycle_info;


MemoryGroupCycleInfoQueryLastOneVo({

    required this.memory_group_cycle_info,

});
  factory MemoryGroupCycleInfoQueryLastOneVo.fromJson(Map<String, dynamic> json) => _$MemoryGroupCycleInfoQueryLastOneVoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$MemoryGroupCycleInfoQueryLastOneVoToJson(this);
  
  
}
