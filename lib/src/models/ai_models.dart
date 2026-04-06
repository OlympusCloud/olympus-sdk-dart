/// Models for the Olympus AI service.
library;

/// Response from an AI query or chat completion.
class AiResponse {
  const AiResponse({
    required this.content,
    this.model,
    this.tier,
    this.tokensUsed,
    this.finishReason,
    this.requestId,
  });

  final String content;
  final String? model;
  final String? tier;
  final int? tokensUsed;
  final String? finishReason;
  final String? requestId;

  factory AiResponse.fromJson(Map<String, dynamic> json) => AiResponse(
        content: json['content'] as String? ??
            json['response'] as String? ??
            json['text'] as String? ??
            '',
        model: json['model'] as String?,
        tier: json['tier'] as String?,
        tokensUsed: json['tokens_used'] as int? ??
            json['usage']?['total_tokens'] as int?,
        finishReason: json['finish_reason'] as String?,
        requestId: json['request_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        if (model != null) 'model': model,
        if (tier != null) 'tier': tier,
        if (tokensUsed != null) 'tokens_used': tokensUsed,
        if (finishReason != null) 'finish_reason': finishReason,
        if (requestId != null) 'request_id': requestId,
      };
}

/// Result from invoking a LangGraph agent.
class AgentResult {
  const AgentResult({
    required this.output,
    this.agentName,
    this.steps,
    this.tokensUsed,
    this.requestId,
  });

  final String output;
  final String? agentName;
  final List<AgentStep>? steps;
  final int? tokensUsed;
  final String? requestId;

  factory AgentResult.fromJson(Map<String, dynamic> json) => AgentResult(
        output: json['output'] as String? ?? json['result'] as String? ?? '',
        agentName: json['agent_name'] as String?,
        steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => AgentStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        tokensUsed: json['tokens_used'] as int?,
        requestId: json['request_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'output': output,
        if (agentName != null) 'agent_name': agentName,
        if (steps != null) 'steps': steps!.map((e) => e.toJson()).toList(),
        if (tokensUsed != null) 'tokens_used': tokensUsed,
        if (requestId != null) 'request_id': requestId,
      };
}

/// A single step executed by an agent during task processing.
class AgentStep {
  const AgentStep({
    required this.action,
    this.observation,
    this.thought,
  });

  final String action;
  final String? observation;
  final String? thought;

  factory AgentStep.fromJson(Map<String, dynamic> json) => AgentStep(
        action: json['action'] as String,
        observation: json['observation'] as String?,
        thought: json['thought'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'action': action,
        if (observation != null) 'observation': observation,
        if (thought != null) 'thought': thought,
      };
}

/// An asynchronous agent task with status tracking.
class AgentTask {
  const AgentTask({
    required this.id,
    required this.status,
    this.agentName,
    this.task,
    this.result,
    this.error,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String status;
  final String? agentName;
  final String? task;
  final String? result;
  final String? error;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory AgentTask.fromJson(Map<String, dynamic> json) => AgentTask(
        id: json['id'] as String? ?? json['task_id'] as String? ?? '',
        status: json['status'] as String? ?? 'unknown',
        agentName: json['agent_name'] as String? ?? json['agent'] as String?,
        task: json['task'] as String?,
        result: json['result'] as String?,
        error: json['error'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        if (agentName != null) 'agent_name': agentName,
        if (task != null) 'task': task,
        if (result != null) 'result': result,
        if (error != null) 'error': error,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (completedAt != null)
          'completed_at': completedAt!.toIso8601String(),
      };

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending' || status == 'running';
}

/// Text classification result.
class Classification {
  const Classification({
    required this.label,
    required this.confidence,
    this.scores,
  });

  final String label;
  final double confidence;
  final Map<String, double>? scores;

  factory Classification.fromJson(Map<String, dynamic> json) => Classification(
        label: json['label'] as String? ?? json['category'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ??
            (json['score'] as num?)?.toDouble() ??
            0.0,
        scores: (json['scores'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
        if (scores != null) 'scores': scores,
      };
}

/// Sentiment analysis result.
class SentimentResult {
  const SentimentResult({
    required this.sentiment,
    required this.score,
    this.aspects,
  });

  /// One of: positive, negative, neutral, mixed.
  final String sentiment;
  final double score;
  final List<AspectSentiment>? aspects;

  factory SentimentResult.fromJson(Map<String, dynamic> json) =>
      SentimentResult(
        sentiment: json['sentiment'] as String? ?? 'neutral',
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        aspects: (json['aspects'] as List<dynamic>?)
            ?.map((e) => AspectSentiment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'sentiment': sentiment,
        'score': score,
        if (aspects != null)
          'aspects': aspects!.map((e) => e.toJson()).toList(),
      };
}

/// Sentiment for a specific aspect of the analyzed text.
class AspectSentiment {
  const AspectSentiment({
    required this.aspect,
    required this.sentiment,
    required this.score,
  });

  final String aspect;
  final String sentiment;
  final double score;

  factory AspectSentiment.fromJson(Map<String, dynamic> json) =>
      AspectSentiment(
        aspect: json['aspect'] as String,
        sentiment: json['sentiment'] as String,
        score: (json['score'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'aspect': aspect,
        'sentiment': sentiment,
        'score': score,
      };
}
