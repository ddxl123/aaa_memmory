part of drift_db;

enum QueryFragmentWhereType {
  /// 查询全部碎片。
  all,

  /// 查询 [Fragment.isSelectedUnit] 为 true 的碎片。
  selected,
}

@DriftAccessor(
  tables: tableClasses,
)
class GeneralQueryDAO extends DatabaseAccessor<DriftDb> with _$GeneralQueryDAOMixin {
  GeneralQueryDAO(super.attachedDatabase);

  Future<User?> queryUserOrNull() async {
    final manyUsers = await select(users).get();
    if (manyUsers.length > 1) {
      throw "本地存在多个用户！";
    }
    return manyUsers.isEmpty ? null : manyUsers.first;
  }

  /// 在查询前，必须已插入过，否则抛出异常
  ///
  /// 如果 [deviceInfo] 与本地查询到的不一致，则抛出异常
  Future<ClientSyncInfo> queryClientSyncInfo([String? deviceInfo]) async {
    final result = await queryClientSyncInfoOrNull();
    if (result == null) throw "ClientSyncInfo 不应该为空";
    if (deviceInfo != null && result.device_info != deviceInfo) throw "响应的 deviceInfo 与本地查询到的不一致！";
    return result;
  }

  Future<ClientSyncInfo?> queryClientSyncInfoOrNull() async {
    final sel = await select(clientSyncInfos).get();
    if (sel.length > 1) throw "本地存在多个客户端同步信息！";
    return sel.isEmpty ? null : sel.first;
  }

  /// 根据实体 [id] 查询实体
  ///
  /// 如果查询结果存在多个，则抛出异常
  Future<D?> querySingleOrNullById<T extends Table, D extends DataClass>({
    required TableInfo<T, D> tableInfo,
    required int id,
  }) async {
    return await (select(tableInfo)..where((tbl) => (tbl as dynamic).id.equals(id))).getSingleOrNull();
  }

  /// 查询实体类对应的全部实体
  Future<List<D>> queryAll<T extends Table, D extends DataClass>({required TableInfo<T, D> tableInfo}) async {
    return await select(tableInfo).get();
  }

  /// 通过 [where] 查询实体类对应的全部实体
  Future<List<D>> queryAllByWhere<T extends Table, D extends DataClass>({
    required TableInfo<T, D> tableInfo,
    required Expression<bool> Function(T) whereExpr,
  }) async {
    final sel = select(tableInfo);
    sel.where((tbl) => whereExpr(tbl));
    return await sel.get();
  }

  /// 通过 [where] 查询实体类对应的单个实体
  ///
  /// 如果查询结果存在多个，则抛出异常
  Future<D?> querySingleOrNullByWhere<T extends Table, D extends DataClass>({
    required TableInfo<T, D> tableInfo,
    required Expression<bool> Function(T) whereExpr,
  }) async {
    final sel = select(tableInfo);
    sel.where((tbl) => whereExpr(tbl));
    return await sel.getSingleOrNull();
  }

  Future<int> queryCount<T extends Table, D extends DataClass>({
    required TableInfo<T, D> tableInfo,
    required Expression<bool> whereExpr,
  }) async {
    final count = (tableInfo as dynamic).id.count();
    final sel = selectOnly(tableInfo);
    sel.where(whereExpr);
    sel.addColumns([count]);
    return (await sel.getSingle()).read(count) as int;
  }

  /// [count] 要同步多少个
  Future<List<FragmentMemoryInfo>> queryNotSyncedMemoryInfos({required int count}) async {
    return await (select(fragmentMemoryInfos)
          ..where((tbl) => tbl.be_synced.equals(false))
          ..limit(count))
        .get();
  }

  Future<List<int>> queryMemoryInfoIdAndVersion({required int memoryGroupId}) async {
    final sel = selectOnly(fragmentMemoryInfos)
      ..where(fragmentMemoryInfos.memory_group_id.equals(memoryGroupId))
      ..addColumns([fragmentMemoryInfos.id]);
    return (await sel.get()).map((e) => e.read(fragmentMemoryInfos.id)!).toList();
  }
}
