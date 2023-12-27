
part of drift_db;

@ReferenceTo([])
class MemoryAlgorithms extends CloudTableBase  {
  @override
  String? get tableName => "memory_algorithms";
  
  @override
  Set<Column>? get primaryKey => {id};

  TextColumn get button_algorithm => text().named("button_algorithm").nullable()();

  TextColumn get button_algorithm_remark => text().named("button_algorithm_remark").nullable()();

  TextColumn get completed_algorithm => text().named("completed_algorithm").nullable()();

  TextColumn get completed_algorithm_remark => text().named("completed_algorithm_remark").nullable()();

  @ReferenceTo([Users])
  IntColumn get creator_user_id => integer().named("creator_user_id")();

  TextColumn get explain_content => text().named("explain_content").nullable()();

  TextColumn get familiarity_algorithm => text().named("familiarity_algorithm").nullable()();

  TextColumn get familiarity_algorithm_remark => text().named("familiarity_algorithm_remark").nullable()();

  @ReferenceTo([MemoryAlgorithms])
  IntColumn get father_memory_algorithm_id => integer().named("father_memory_algorithm_id").nullable()();

  TextColumn get next_time_algorithm => text().named("next_time_algorithm").nullable()();

  TextColumn get next_time_algorithm_remark => text().named("next_time_algorithm_remark").nullable()();

  TextColumn get suggest_count_for_new_and_review_algorithm => text().named("suggest_count_for_new_and_review_algorithm").nullable()();

  TextColumn get suggest_count_for_new_and_review_algorithm_remark => text().named("suggest_count_for_new_and_review_algorithm_remark").nullable()();

  TextColumn get suggest_loop_cycle => text().named("suggest_loop_cycle").nullable()();

  TextColumn get suggest_loop_cycle_remark => text().named("suggest_loop_cycle_remark").nullable()();

  TextColumn get title => text().named("title")();

  DateTimeColumn get created_at => dateTime().named("created_at")();

  IntColumn get id => integer().named("id")();

  DateTimeColumn get updated_at => dateTime().named("updated_at")();

}
        