// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_canny_suppression.dart';

const _tracerName = 'dartastic_otel_libs_canny';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class CannyResult {
  const CannyResult({
    this.companyId,
    this.entityKind,
    this.entityId,
    this.boardId,
    this.boardName,
    this.postId,
    this.postStatus,
    this.postScore,
    this.commentCount,
    this.voteCount,
    this.changelogEntryId,
    this.changelogPublished,
    this.changelogTypes,
    this.statusChangeFrom,
    this.statusChangeTo,
    this.tagCount,
    this.statusCode,
  });

  /// Canny company (tenant).
  final String? companyId;

  /// `post` / `board` / `comment` / `vote` / `user` / `company` /
  /// `tag` / `category` / `changelog_entry` / `webhook` /
  /// `status_change`.
  final String? entityKind;

  final String? entityId;

  final String? boardId;
  final String? boardName;

  final String? postId;

  /// `open` / `under_review` / `planned` / `in_progress` /
  /// `complete` / `closed` (and any custom statuses the workspace
  /// has configured).
  final String? postStatus;

  /// Canny aggregates `score = votes + 0.1*comments` (visible in UI).
  final int? postScore;

  final int? commentCount;
  final int? voteCount;

  final String? changelogEntryId;

  /// `true` when the changelog entry is publicly visible.
  final bool? changelogPublished;

  /// Comma-separated entry types (`new`, `improved`, `fixed`).
  final String? changelogTypes;

  /// Status transition (from `under_review` → `planned`, etc.).
  final String? statusChangeFrom;
  final String? statusChangeTo;

  /// Number of tags applied.
  final int? tagCount;

  final int? statusCode;
}

class CannyCallResult<T> {
  const CannyCallResult({required this.value, this.result});
  final T value;
  final CannyResult? result;
}

/// Wraps a Canny API call in a CLIENT span. [operation] is one of
/// `boards.list`, `boards.retrieve`, `posts.list`, `posts.create`,
/// `posts.update`, `posts.change_status`, `posts.add_tag`,
/// `comments.list`, `comments.create`, `votes.list`, `votes.create`,
/// `users.list`, `users.create_or_update`, `companies.list`,
/// `changelog.list`, `changelog.create`.
Future<T> tracedCanny<T>({
  required String operation,
  required Future<CannyCallResult<T>> Function() invoke,
}) async {
  if (cannyInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'canny',
    'rpc.method': operation,
    'canny.operation': operation,
  };

  final span = _tracer().startSpan(
    'canny $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.companyId != null) {
        extras.add(OTel.attributeString(
          'canny.company.id',
          r.result!.companyId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'canny.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'canny.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.boardId != null) {
        extras.add(OTel.attributeString(
          'canny.board.id',
          r.result!.boardId!,
        ));
      }
      if (r.result!.boardName != null) {
        extras.add(OTel.attributeString(
          'canny.board.name',
          r.result!.boardName!,
        ));
      }
      if (r.result!.postId != null) {
        extras.add(OTel.attributeString(
          'canny.post.id',
          r.result!.postId!,
        ));
      }
      if (r.result!.postStatus != null) {
        extras.add(OTel.attributeString(
          'canny.post.status',
          r.result!.postStatus!,
        ));
      }
      if (r.result!.postScore != null) {
        extras.add(OTel.attributeInt(
          'canny.post.score',
          r.result!.postScore!,
        ));
      }
      if (r.result!.commentCount != null) {
        extras.add(OTel.attributeInt(
          'canny.comment.count',
          r.result!.commentCount!,
        ));
      }
      if (r.result!.voteCount != null) {
        extras.add(OTel.attributeInt(
          'canny.vote.count',
          r.result!.voteCount!,
        ));
      }
      if (r.result!.changelogEntryId != null) {
        extras.add(OTel.attributeString(
          'canny.changelog_entry.id',
          r.result!.changelogEntryId!,
        ));
      }
      if (r.result!.changelogPublished != null) {
        extras.add(OTel.attributeBool(
          'canny.changelog.published',
          r.result!.changelogPublished!,
        ));
      }
      if (r.result!.changelogTypes != null) {
        extras.add(OTel.attributeString(
          'canny.changelog.types',
          r.result!.changelogTypes!,
        ));
      }
      if (r.result!.statusChangeFrom != null) {
        extras.add(OTel.attributeString(
          'canny.status_change.from',
          r.result!.statusChangeFrom!,
        ));
      }
      if (r.result!.statusChangeTo != null) {
        extras.add(OTel.attributeString(
          'canny.status_change.to',
          r.result!.statusChangeTo!,
        ));
      }
      if (r.result!.tagCount != null) {
        extras.add(OTel.attributeInt(
          'canny.tag.count',
          r.result!.tagCount!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Canny HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
