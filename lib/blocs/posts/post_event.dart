import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostLoadRequested extends PostEvent {
  const PostLoadRequested();
}

class PostCreateRequested extends PostEvent {
  final String message;
  final String username;
  final String userId;

  const PostCreateRequested({
    required this.message,
    required this.username,
    required this.userId,
  });

  @override
  List<Object?> get props => [message, username, userId];
}

class PostUpdated extends PostEvent {
  final List<PostModel> posts;

  const PostUpdated({required this.posts});

  @override
  List<Object?> get props => [posts];
}

