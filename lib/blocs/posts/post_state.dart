import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostLoaded extends PostState {
  final List<PostModel> posts;

  const PostLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostCreating extends PostState {
  final List<PostModel> posts;

  const PostCreating({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostCreated extends PostState {
  const PostCreated();
}

