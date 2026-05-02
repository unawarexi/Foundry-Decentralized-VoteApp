import 'package:flutter_frontend_vote/app/domain/models/user_model.dart';

class ForumPostModel {
  final String id;
  final String userId;
  final String? electionId;
  final String title;
  final String body;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final bool isResolved;
  final String status; // OPEN | CLOSED | REMOVED
  final UserModel? author;
  final List<ForumAnswerModel> answers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ForumPostModel({
    required this.id,
    required this.userId,
    this.electionId,
    required this.title,
    required this.body,
    this.tags = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.answerCount = 0,
    this.isResolved = false,
    required this.status,
    this.author,
    this.answers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) => ForumPostModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        electionId: json['electionId'] as String?,
        title: json['title'] as String,
        body: json['body'] as String,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        upvotes: json['upvotes'] as int? ?? 0,
        downvotes: json['downvotes'] as int? ?? 0,
        answerCount: json['answerCount'] as int? ?? 0,
        isResolved: json['isResolved'] as bool? ?? false,
        status: json['status'] as String? ?? 'OPEN',
        author: json['author'] != null
            ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
            : null,
        answers: (json['answers'] as List<dynamic>?)
                ?.map((e) =>
                    ForumAnswerModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'tags': tags,
        'upvotes': upvotes,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  int get score => upvotes - downvotes;
}

class ForumAnswerModel {
  final String id;
  final String postId;
  final String userId;
  final String body;
  final int upvotes;
  final bool isAccepted;
  final UserModel? author;
  final DateTime createdAt;

  const ForumAnswerModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    this.upvotes = 0,
    this.isAccepted = false,
    this.author,
    required this.createdAt,
  });

  factory ForumAnswerModel.fromJson(Map<String, dynamic> json) =>
      ForumAnswerModel(
        id: json['id'] as String,
        postId: json['postId'] as String,
        userId: json['userId'] as String,
        body: json['body'] as String,
        upvotes: json['upvotes'] as int? ?? 0,
        isAccepted: json['isAccepted'] as bool? ?? false,
        author: json['author'] != null
            ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
