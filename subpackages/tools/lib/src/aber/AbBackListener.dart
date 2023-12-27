part of aber;

/// 返回键监听。
///
/// 在 onInit 函数中调用 [attachBack]，在 onDispose 函数中调用 [detachBack]，
/// 返回时调用 [abBack]，会触发 [backListener]，在 [backListener] 中进行返回逻辑编写。
mixin AbBackListener {
  late final BuildContext backContext;

  void attachBack({required BuildContext context}) {
    backContext = context;
    BackButtonInterceptor.add(_backListener, context: context);
  }

  void detachBack() {
    BackButtonInterceptor.remove(_backListener);
  }

  Future<void> abBack() async {
    await BackButtonInterceptor.popRoute();
  }

  /// 返回 true，则不触发 pop。
  /// 返回 false，则触发 pop。
  ///
  /// 对物理返回键、[abBack] 有效，对 [Navigator.pop] 无效，因此使用 [abBack] 代替 [Navigator.pop]。
  Future<bool> _backListener(bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    // 如果一个对话框(或任何其他路由)是打开的。
    var hasRoute = false;
    if (backContext.mounted) {
      hasRoute = routeInfo.ifRouteChanged(backContext);
    }
    return await backListener(hasRoute);
  }

  Future<bool> backListener(bool hasRoute) async => false;
}
