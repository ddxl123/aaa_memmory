
part of drift_db;

@ReferenceTo([])
class MemoryGroups extends CloudTableBase  {
  @override
  String? get tableName => "memory_groups";
  
  @override
  Set<Column>? get primaryKey => {id};

  BoolColumn get be_synced => boolean().named("be_synced")();

  @ReferenceTo([Users])
  IntColumn get creator_user_id => integer().named("creator_user_id")();

  @ReferenceTo([MemoryAlgorithms])
  IntColumn get memory_algorithm_id => integer().named("memory_algorithm_id").nullable()();

  TextColumn get new_display_order => textEnum<NewDisplayOrder>().named("new_display_order")();

  TextColumn get new_review_display_order => textEnum<NewReviewDisplayOrder>().named("new_review_display_order")();

  TextColumn get review_display_order => textEnum<ReviewDisplayOrder>().named("review_display_order")();

  DateTimeColumn get start_time => dateTime().named("start_time").nullable()();

  TextColumn get study_status => textEnum<StudyStatus>().named("study_status")();

  IntColumn get sync_version => integer().named("sync_version")();

  TextColumn get title => text().named("title")();

  DateTimeColumn get created_at => dateTime().named("created_at")();

  IntColumn get id => integer().named("id")();

  DateTimeColumn get updated_at => dateTime().named("updated_at")();

}
        