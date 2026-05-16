// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_canny/otel_canny.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_canny-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('posts.change_status records transition + score', () async {
    await tracedCanny<String>(
      operation: 'posts.change_status',
      invoke: () async => const CannyCallResult(
        value: 'ok',
        result: CannyResult(
          companyId: 'co_1',
          postId: 'post_1',
          boardName: 'Feature Requests',
          postStatus: 'planned',
          postScore: 48,
          voteCount: 47,
          commentCount: 9,
          statusChangeFrom: 'under_review',
          statusChangeTo: 'planned',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('canny posts.change_status')!);
    expect(a['canny.post.status'], 'planned');
    expect(a['canny.status_change.from'], 'under_review');
    expect(a['canny.status_change.to'], 'planned');
    expect(a['canny.post.score'], 48);
    expect(a['canny.vote.count'], 47);
  });

  test('changelog.create records types + published', () async {
    await tracedCanny<String>(
      operation: 'changelog.create',
      invoke: () async => const CannyCallResult(
        value: 'ok',
        result: CannyResult(
          changelogEntryId: 'cl_1',
          changelogPublished: true,
          changelogTypes: 'new,improved',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('canny changelog.create')!);
    expect(a['canny.changelog.published'], true);
    expect(a['canny.changelog.types'], 'new,improved');
  });

  test('HTTP 401 sets span error', () async {
    await tracedCanny<String>(
      operation: 'posts.list',
      invoke: () async => const CannyCallResult(
        value: 'ok',
        result: CannyResult(statusCode: 401),
      ),
    );
    expect(
      spans.findSpanByName('canny posts.list')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutCannyInstrumentationAsync(() async {
      await tracedCanny<String>(
        operation: 'boards.list',
        invoke: () async => const CannyCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('canny '), isEmpty);
  });
}
