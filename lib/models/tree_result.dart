class TreeResult {
  final int score;
  final int lights;
  final int decor;
  final int vibe;
  final int symmetry;
  final String comment;
  final List<String> advice;

  const TreeResult({
    required this.score,
    required this.lights,
    required this.decor,
    required this.vibe,
    required this.symmetry,
    required this.comment,
    required this.advice,
  });

  factory TreeResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TreeResult(
        score: 0,
        lights: 0,
        decor: 0,
        vibe: 0,
        symmetry: 0,
        comment: 'Без комментариев',
        advice: <String>[],
      );
    }

    int _clampInt(dynamic v) {
      final value = v is num ? v.toInt() : 0;
      return value.clamp(0, 10);
    }

    final rawComment = json['comment'];
    final parsedComment =
        rawComment is String && rawComment.isNotEmpty ? rawComment : 'Без комментариев';

    List<String> parsedAdvice = <String>[];
    final rawAdvice = json['advice'];
    if (rawAdvice is List) {
      parsedAdvice = rawAdvice
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList()
          .take(3)
          .toList();
    }

    return TreeResult(
      score: _clampInt(json['score']),
      lights: _clampInt(json['lights']),
      decor: _clampInt(json['decor']),
      vibe: _clampInt(json['vibe']),
      symmetry: _clampInt(json['symmetry']),
      comment: parsedComment,
      advice: parsedAdvice,
    );
  }
}

