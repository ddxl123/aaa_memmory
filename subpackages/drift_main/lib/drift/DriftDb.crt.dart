// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// CrtGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
part of drift_db;

class Crt {
  Crt._();
  static ClientSyncInfo clientSyncInfoEntity({
    required String device_info,
    required String? token,
  }) {
    return ClientSyncInfo(
      device_info: device_info,
      token: token,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static Sync syncEntity({
    required int row_id,
    required SyncCurdType sync_curd_type,
    required String sync_table_name,
    required int tag,
  }) {
    return Sync(
      row_id: row_id,
      sync_curd_type: sync_curd_type,
      sync_table_name: sync_table_name,
      tag: tag,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentGroupInfo fragmentGroupInfoEntity({
    required int creator_user_id,
    required int fragment_group_id,
    required String notification_modify_content,
  }) {
    return FragmentGroupInfo(
      creator_user_id: creator_user_id,
      fragment_group_id: fragment_group_id,
      notification_modify_content: notification_modify_content,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentMemoryInfo fragmentMemoryInfoEntity({
    required String actual_show_time,
    required bool be_synced,
    required String button_values,
    required String click_familiarity,
    required String click_time,
    required String click_value,
    required String content_value,
    required int creator_user_id,
    required int fragment_id,
    required int memory_group_id,
    required String next_plan_show_time,
    required String show_familiarity,
    required FragmentMemoryInfoStudyStatus study_status,
    required int sync_version,
  }) {
    return FragmentMemoryInfo(
      actual_show_time: actual_show_time,
      be_synced: be_synced,
      button_values: button_values,
      click_familiarity: click_familiarity,
      click_time: click_time,
      click_value: click_value,
      content_value: content_value,
      creator_user_id: creator_user_id,
      fragment_id: fragment_id,
      memory_group_id: memory_group_id,
      next_plan_show_time: next_plan_show_time,
      show_familiarity: show_familiarity,
      study_status: study_status,
      sync_version: sync_version,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfoEntity({
    required int creator_user_id,
    required int incremental_new_learn_count,
    required int incremental_review_count,
    required String loop_cycle,
    required int loop_cycle_order,
    required int memory_algorithm_id,
    required int memory_group_id,
    required int should_new_learn_count,
    required int should_review_count,
    required DateTime should_small_cycle_end_time,
    required int small_cycle_order,
  }) {
    return MemoryGroupSmartCycleInfo(
      creator_user_id: creator_user_id,
      incremental_new_learn_count: incremental_new_learn_count,
      incremental_review_count: incremental_review_count,
      loop_cycle: loop_cycle,
      loop_cycle_order: loop_cycle_order,
      memory_algorithm_id: memory_algorithm_id,
      memory_group_id: memory_group_id,
      should_new_learn_count: should_new_learn_count,
      should_review_count: should_review_count,
      should_small_cycle_end_time: should_small_cycle_end_time,
      small_cycle_order: small_cycle_order,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentGroupTag fragmentGroupTagEntity({
    required int fragment_group_id,
    required String tag,
  }) {
    return FragmentGroupTag(
      fragment_group_id: fragment_group_id,
      tag: tag,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static RFragment2FragmentGroup rFragment2FragmentGroupEntity({
    required int creator_user_id,
    required int? fragment_group_id,
    required int fragment_id,
  }) {
    return RFragment2FragmentGroup(
      creator_user_id: creator_user_id,
      fragment_group_id: fragment_group_id,
      fragment_id: fragment_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static Test2 test2Entity({
    required String client_content,
  }) {
    return Test2(
      client_content: client_content,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static Test testEntity({
    required String client_a,
    required String client_content,
  }) {
    return Test(
      client_a: client_a,
      client_content: client_content,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static Fragment fragmentEntity({
    required bool be_sep_publish,
    required String content,
    required int creator_user_id,
    required int? father_fragment_id,
    required String title,
  }) {
    return Fragment(
      be_sep_publish: be_sep_publish,
      content: content,
      creator_user_id: creator_user_id,
      father_fragment_id: father_fragment_id,
      title: title,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static MemoryAlgorithm memoryAlgorithmEntity({
    required String? button_algorithm,
    required String? button_algorithm_remark,
    required String? completed_algorithm,
    required String? completed_algorithm_remark,
    required int creator_user_id,
    required String? explain_content,
    required String? familiarity_algorithm,
    required String? familiarity_algorithm_remark,
    required int? father_memory_algorithm_id,
    required String? next_time_algorithm,
    required String? next_time_algorithm_remark,
    required String? suggest_count_for_new_and_review_algorithm,
    required String? suggest_count_for_new_and_review_algorithm_remark,
    required String? suggest_loop_cycle_algorithm,
    required String? suggest_loop_cycle_algorithm_remark,
    required String title,
  }) {
    return MemoryAlgorithm(
      button_algorithm: button_algorithm,
      button_algorithm_remark: button_algorithm_remark,
      completed_algorithm: completed_algorithm,
      completed_algorithm_remark: completed_algorithm_remark,
      creator_user_id: creator_user_id,
      explain_content: explain_content,
      familiarity_algorithm: familiarity_algorithm,
      familiarity_algorithm_remark: familiarity_algorithm_remark,
      father_memory_algorithm_id: father_memory_algorithm_id,
      next_time_algorithm: next_time_algorithm,
      next_time_algorithm_remark: next_time_algorithm_remark,
      suggest_count_for_new_and_review_algorithm:
          suggest_count_for_new_and_review_algorithm,
      suggest_count_for_new_and_review_algorithm_remark:
          suggest_count_for_new_and_review_algorithm_remark,
      suggest_loop_cycle_algorithm: suggest_loop_cycle_algorithm,
      suggest_loop_cycle_algorithm_remark: suggest_loop_cycle_algorithm_remark,
      title: title,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static MemoryGroup memoryGroupEntity({
    required bool be_synced,
    required int creator_user_id,
    required int? memory_algorithm_id,
    required NewDisplayOrder new_display_order,
    required NewReviewDisplayOrder new_review_display_order,
    required ReviewDisplayOrder review_display_order,
    required DateTime? start_time,
    required StudyStatus study_status,
    required int sync_version,
    required String title,
  }) {
    return MemoryGroup(
      be_synced: be_synced,
      creator_user_id: creator_user_id,
      memory_algorithm_id: memory_algorithm_id,
      new_display_order: new_display_order,
      new_review_display_order: new_review_display_order,
      review_display_order: review_display_order,
      start_time: start_time,
      study_status: study_status,
      sync_version: sync_version,
      title: title,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static Shorthand shorthandEntity({
    required String content,
    required int creator_user_id,
  }) {
    return Shorthand(
      content: content,
      creator_user_id: creator_user_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentGroupBeSaved fragmentGroupBeSavedEntity({
    required int? fragment_group_id,
    required int saved_user_id,
  }) {
    return FragmentGroupBeSaved(
      fragment_group_id: fragment_group_id,
      saved_user_id: saved_user_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentGroupLike fragmentGroupLikeEntity({
    required int fragment_group_id,
    required int liker_user_id,
  }) {
    return FragmentGroupLike(
      fragment_group_id: fragment_group_id,
      liker_user_id: liker_user_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static FragmentGroup fragmentGroupEntity({
    required bool be_publish,
    required String? cover_cloud_path,
    required int creator_user_id,
    required int? father_fragment_groups_id,
    required int? jump_to_fragment_groups_id,
    required String profile,
    required String title,
  }) {
    return FragmentGroup(
      be_publish: be_publish,
      cover_cloud_path: cover_cloud_path,
      creator_user_id: creator_user_id,
      father_fragment_groups_id: father_fragment_groups_id,
      jump_to_fragment_groups_id: jump_to_fragment_groups_id,
      profile: profile,
      title: title,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static UserComment userCommentEntity({
    required String comment_content,
    required int commentator_user_id,
    required int? fragment_group_id,
    required int? fragment_id,
  }) {
    return UserComment(
      comment_content: comment_content,
      commentator_user_id: commentator_user_id,
      fragment_group_id: fragment_group_id,
      fragment_id: fragment_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static UserFollow userFollowEntity({
    required int be_followed_user_id,
    required int follow_user_id,
  }) {
    return UserFollow(
      be_followed_user_id: be_followed_user_id,
      follow_user_id: follow_user_id,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }

  static User userEntity({
    required String? area,
    required String? avatar_cloud_path,
    required String? bind_email,
    required String? bind_phone,
    required DateTime? birth,
    required String? career,
    required Gender? gender,
    required String? interest,
    required String? password,
    required String? personalized_tags,
    required String? profile,
    required String username,
  }) {
    return User(
      area: area,
      avatar_cloud_path: avatar_cloud_path,
      bind_email: bind_email,
      bind_phone: bind_phone,
      birth: birth,
      career: career,
      gender: gender,
      interest: interest,
      password: password,
      personalized_tags: personalized_tags,
      profile: profile,
      username: username,
      created_at: DateTime(0),
      id: -1,
      updated_at: DateTime(0),
    );
  }
}
