class JobProgress {
  final int reportId;
  final String specialistComment;
  final String userComment;
  final String imagePath;

  JobProgress({
    required this.reportId,
    required this.specialistComment,
    required this.userComment,
    required this.imagePath,
  });

  factory JobProgress.fromJson(Map<String, dynamic> json) {
    return JobProgress(
      reportId: json['report_id'],
      specialistComment: json['specialist_comment'],
      userComment: json['user_comment'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'specialist_comment': specialistComment,
      'user_comment': userComment,
      'image_path': imagePath,
    };
  }
}
