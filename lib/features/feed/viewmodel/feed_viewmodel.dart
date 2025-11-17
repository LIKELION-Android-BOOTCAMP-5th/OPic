// feed_viewmodel.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/feed/data/feed_state.dart';
import 'package:opicproject/features/feed/data/user_relation_state.dart';
import 'package:opicproject/features/feed/manager/pagination_manager.dart';
import 'package:opicproject/features/feed/manager/scroll_manager.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _repository = FeedRepository();
  late final ScrollManager _scrollManager;
  final PaginationManager _paginationManager = PaginationManager();

  // 스크롤 컨트롤러
  ScrollController scrollController = ScrollController();

  // 상태
  FeedState _state = const FeedState();
  FeedState get state => _state;

  // 관계 상태
  UserRelationState _relationState = const UserRelationState();
  UserRelationState get relationState => _relationState;

  // 피드 게시물 목록
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  // 피드 주인 유저 정보
  UserInfo? _feedUser;
  UserInfo? get feedUser => _feedUser;

  // 현재 피드 주인 유저, 로그인 유저 ID
  int? _currentFeedUserId;
  int? _loginUserId;

  // Getter
  int get currentPage => _paginationManager.currentPage;
  bool get shouldShowScrollUpButton => _state.shouldShowScrollUpButton;
  bool get isInitialized => _state.isInitialized;
  bool get isLoading => _state.isLoading;
  bool get isStatusChecked => _state.isStatusChecked;
  bool get isBlocked => _relationState.isBlocked;
  bool get isBlockedMe => _relationState.isBlockedMe;
  bool get isRequested => _relationState.isRequested;

  FeedViewModel() {
    _initializeScrollManager();
  }

  // 스크롤 관련
  void _initializeScrollManager() {
    _scrollManager = ScrollManager(
      controller: scrollController,
      onScrollToBottom: _handleScrollToBottom,
      onScrollButtonVisibilityChanged: _updateScrollButtonVisibility,
    );
    _scrollManager.initialize();
  }

  void _handleScrollToBottom() {
    if (_currentFeedUserId != null) {
      fetchMorePosts(_currentFeedUserId!);
    }
  }

  void _updateScrollButtonVisibility(bool shouldShow) {
    if (_state.shouldShowScrollUpButton != shouldShow) {
      _updateState(shouldShowScrollUpButton: shouldShow);
    }
  }

  void moveScrollUp() {
    _scrollManager.scrollToTop();
  }

  // 상태 업데이트
  void _updateState({
    bool? isInitialized,
    bool? isLoading,
    bool? isStatusChecked,
    bool? shouldShowScrollUpButton,
  }) {
    _state = FeedState(
      isInitialized: isInitialized ?? _state.isInitialized,
      isLoading: isLoading ?? _state.isLoading,
      isStatusChecked: isStatusChecked ?? _state.isStatusChecked,
      shouldShowScrollUpButton:
          shouldShowScrollUpButton ?? _state.shouldShowScrollUpButton,
    );
    notifyListeners();
  }

  void _updateRelationState({
    bool? isBlocked,
    bool? isBlockedMe,
    bool? isRequested,
  }) {
    _relationState = UserRelationState(
      isBlocked: isBlocked ?? _relationState.isBlocked,
      isBlockedMe: isBlockedMe ?? _relationState.isBlockedMe,
      isRequested: isRequested ?? _relationState.isRequested,
    );
    notifyListeners();
  }

  // 피드 정보 초기설정 (다른 유저 피드로 이동할 때 이전 유저 정보 남지 않게)
  Future<void> initializeFeed(int feedUserId, int loginUserId) async {
    if (_state.isLoading) return;

    if (_currentFeedUserId == feedUserId && _state.isInitialized) {
      return;
    }

    _resetFeedData(feedUserId, loginUserId);
    _updateState(isLoading: true);

    await _loadInitialData(feedUserId);

    _updateState(isInitialized: true, isLoading: false);
  }

  void _resetFeedData(int feedUserId, int loginUserId) {
    _currentFeedUserId = feedUserId;
    _loginUserId = loginUserId;
    _posts = [];
    _feedUser = null;
    _paginationManager.reset();
    _state = const FeedState();
    _relationState = const UserRelationState();
  }

  Future<void> _loadInitialData(int feedUserId) async {
    await Future.wait([
      _fetchAUser(feedUserId),
      _fetchPosts(page: 1, userId: feedUserId),
    ]);
  }

  // 유저와 피드 유저의 관계 확인
  Future<void> checkUserStatus(int loginUserId, int feedUserId) async {
    if (_state.isStatusChecked) return;

    _relationState = await _repository.fetchUserRelation(
      loginUserId,
      feedUserId,
    );

    _updateState(isStatusChecked: true);
  }

  // 새로고침
  Future<void> refresh(int userId) async {
    _updateState(isLoading: true);

    await Future.delayed(Duration(milliseconds: 1000));

    _paginationManager.reset();
    _posts = await _repository.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );

    _updateState(isLoading: false);
  }

  // 피드 게시물 가져오기
  Future<void> _fetchPosts({required int page, required int userId}) async {
    _posts = await _repository.fetchPosts(currentPage: page, userId: userId);
  }

  // 피드 게시물 가져오기 (다음 페이지)
  Future<void> fetchMorePosts(int userId) async {
    if (_state.isLoading) return;

    _updateState(isLoading: true);

    _paginationManager.nextPage();
    final fetchedPosts = await _repository.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );

    if (fetchedPosts.isNotEmpty) {
      _posts.addAll(fetchedPosts);
    } else {
      _paginationManager.pastPage();
    }

    _updateState(isLoading: false);
  }

  // 아이디로 유저 정보 조회
  Future<void> _fetchAUser(int userId) async {
    _feedUser = await _repository.fetchAUser(userId);
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    await _repository.blockUser(loginUserId, userId);
    _updateRelationState(isBlocked: true);
  }

  // 차단해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    _updateRelationState(isBlocked: false);
  }

  // 친구 요청 취소하기
  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _repository.deleteARequest(loginUserId, targetUserId);
    _updateRelationState(isRequested: false);
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
