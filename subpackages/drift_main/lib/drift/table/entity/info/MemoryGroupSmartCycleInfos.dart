
part of drift_db;

@ReferenceTo([])
class MemoryGroupSmartCycleInfos extends CloudTableBase  {
  @override
  String? get tableName => "memory_group_smart_cycle_infos";
  
  @override
  Set<Column>? get primaryKey => {id};

  @ReferenceTo([Users])
  IntColumn get creator_user_id => integer().named("creator_user_id")();

  TextColumn get loop_cycle => text().named("loop_cycle")();

  @ReferenceTo([MemoryAlgorithms])
  IntColumn get memory_algorithm_id => integer().named("memory_algorithm_id")();

  @ReferenceTo([MemoryGroups])
  IntColumn get memory_group_id => integer().named("memory_group_id")();

  IntColumn get small_cycle_incremental_new_learn_count => integer().named("small_cycle_incremental_new_learn_count")();

  IntColumn get small_cycle_incremental_review_count => integer().named("small_cycle_incremental_review_count")();

  IntColumn get small_cycle_order => integer().named("small_cycle_order")();

  IntColumn get small_cycle_should_new_learn_count => integer().named("small_cycle_should_new_learn_count")();

  IntColumn get small_cycle_should_review_count => integer().named("small_cycle_should_review_count")();

  DateTimeColumn get created_at => dateTime().named("created_at")();

  IntColumn get id => integer().named("id")();

  DateTimeColumn get updated_at => dateTime().named("updated_at")();

}
        