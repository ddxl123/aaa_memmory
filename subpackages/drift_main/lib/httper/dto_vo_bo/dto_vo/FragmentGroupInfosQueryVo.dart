
// ignore_for_file: non_constant_identifier_names
part of httper;

/// 
@JsonSerializable()
class FragmentGroupInfosQueryVo extends BaseObject{

    /// 所查询的碎片组的全部 FragmentGroupInfos。
    List<FragmentGroupInfo> fragment_group_infos_list;


FragmentGroupInfosQueryVo({

    required this.fragment_group_infos_list,

});
  factory FragmentGroupInfosQueryVo.fromJson(Map<String, dynamic> json) => _$FragmentGroupInfosQueryVoFromJson(json);
    
  @override
  Map<String, dynamic> toJson() => _$FragmentGroupInfosQueryVoToJson(this);
  
  
}
