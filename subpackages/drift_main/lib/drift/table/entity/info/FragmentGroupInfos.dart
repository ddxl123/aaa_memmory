
part of drift_db;

@ReferenceTo([])
class FragmentGroupInfos extends CloudTableBase  {
  @override
  String? get tableName => "fragment_group_infos";
  
  @override
  Set<Column>? get primaryKey => {id};

  @ReferenceTo([Users])
  IntColumn get creator_user_id => integer().named("creator_user_id")();

  @ReferenceTo([MemoryGroups])
  IntColumn get fragment_group_id => integer().named("fragment_group_id")();

  TextColumn get notification_modify_content => text().named("notification_modify_content")();

  DateTimeColumn get created_at => dateTime().named("created_at")();

  IntColumn get id => integer().named("id")();

  DateTimeColumn get updated_at => dateTime().named("updated_at")();

}
        