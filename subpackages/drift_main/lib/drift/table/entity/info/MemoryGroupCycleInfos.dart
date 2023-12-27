
part of drift_db;

@ReferenceTo([])
class MemoryGroupCycleInfos extends CloudTableBase  {
  @override
  String? get tableName => "memory_group_cycle_infos";
  
  @override
  Set<Column>? get primaryKey => {id};

  @ReferenceTo([Users])
  IntColumn get creator_user_id => integer().named("creator_user_id")();

  TextColumn get loop_cycle => text().named("loop_cycle")();

  @ReferenceTo([MemoryAlgorithms])
  IntColumn get memory_algorithm_id => integer().named("memory_algorithm_id")();

  @ReferenceTo([MemoryGroups])
  IntColumn get memory_group_id => integer().named("memory_group_id")();

  DateTimeColumn get should_end_time => dateTime().named("should_end_time")();

  IntColumn get should_new_learn_count => integer().named("should_new_learn_count")();

  IntColumn get should_review_count => integer().named("should_review_count")();

  IntColumn get which_small_cycle => integer().named("which_small_cycle")();

  DateTimeColumn get created_at => dateTime().named("created_at")();

  IntColumn get id => integer().named("id")();

  DateTimeColumn get updated_at => dateTime().named("updated_at")();

}
        