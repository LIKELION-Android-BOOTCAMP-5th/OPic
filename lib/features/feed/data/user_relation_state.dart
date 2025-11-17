class UserRelationState {
  final bool isBlocked;
  final bool isBlockedMe;
  final bool isRequested;

  const UserRelationState({
    this.isBlocked = false,
    this.isBlockedMe = false,
    this.isRequested = false,
  });
}
