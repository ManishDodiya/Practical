import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post_model.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _postsSubscription;

  PostBloc({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const PostInitial()) {
    on<PostLoadRequested>(_onLoadRequested);
    on<PostCreateRequested>(_onCreateRequested);
    on<PostUpdated>(_onPostUpdated);
  }

  Future<void> _onLoadRequested(
    PostLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    try {
      await _postsSubscription?.cancel();

      _postsSubscription = _firestore
          .collection('posts')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen(
        (snapshot) {
          final posts = snapshot.docs
              .map((doc) => PostModel.fromMap(doc.data(), doc.id))
              .toList();
          add(PostUpdated(posts: posts));
        },
        onError: (error) {
          add(const PostUpdated(posts: []));
        },
      );
    } catch (e) {
      emit(PostError(message: 'Failed to load posts: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    final currentPosts = state is PostLoaded
        ? (state as PostLoaded).posts 
        : state is PostCreating 
            ? (state as PostCreating).posts 
            : <PostModel>[];
    
    emit(PostCreating(posts: currentPosts));
    try {
      final docRef = _firestore.collection('posts').doc();

      final post = PostModel(
        id: docRef.id,
        message: event.message,
        username: event.username,
        userId: event.userId,
        timestamp: DateTime.now(),
      );

      await docRef.set(post.toMap());
    } catch (e) {
      emit(PostError(message: 'Failed to create post: ${e.toString()}'));
    }
  }

  void _onPostUpdated(
    PostUpdated event,
    Emitter<PostState> emit,
  ) {
    emit(PostLoaded(posts: event.posts));
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}

