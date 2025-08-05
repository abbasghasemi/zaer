class BackController {
  static BackController? _backController;

  static BackController globalInstance() {
    _backController ??= BackController();
    return _backController!;
  }

  final List<BackControllerDelegate> delegateList = [];

  bool allowBack() {
    if (delegateList.isEmpty) {
      return true;
    }
    return delegateList.last.didAllowBack();
  }

  void addBackControl(BackControllerDelegate delegate) {
    delegateList.add(delegate);
  }

  void removeBackControl(BackControllerDelegate delegate) {
    delegateList.remove(delegate);
  }
}

abstract class BackControllerDelegate {
  bool didAllowBack();
}
