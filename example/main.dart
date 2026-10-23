// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_canny/otel_canny.dart';

/// Traces Canny calls with OpenTelemetry.
///
/// `otel_canny` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Canny call in
/// [tracedCanny]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'canny-example');

  // Wraps a Canny API call in a CLIENT span.
  final cannyId = await tracedCanny<String>(
    operation: 'posts.create',
    invoke: () async {
      // Make the Canny call here, then report what it returned.
      const id = 'canny_8f3a2c';
      return const CannyCallResult(
          value: id,
          result: CannyResult(
              companyId: 'company_8f3a2c',
              entityKind: 'post',
              entityId: 'entity_8f3a2c',
              boardId: 'board_8f3a2c',
              boardName: 'example',
              postId: 'post_8f3a2c',
              postStatus: 'open',
              postScore: 1,
              commentCount: 3,
              voteCount: 3,
              changelogEntryId: 'changelogentry_8f3a2c',
              changelogPublished: true,
              changelogTypes: 'new',
              statusChangeFrom: 'under_review',
              statusChangeTo: 'succeeded',
              tagCount: 3,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedCanny posts.create returned $cannyId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCannyInstrumentationAsync.
  await runWithoutCannyInstrumentationAsync(
    () => tracedCanny<String>(
      operation: 'posts.create',
      invoke: () async {
        const id = 'canny_8f3a2c';
        return const CannyCallResult(
            value: id,
            result: CannyResult(
                companyId: 'company_8f3a2c',
                entityKind: 'post',
                entityId: 'entity_8f3a2c',
                boardId: 'board_8f3a2c',
                boardName: 'example',
                postId: 'post_8f3a2c',
                postStatus: 'open',
                postScore: 1,
                commentCount: 3,
                voteCount: 3,
                changelogEntryId: 'changelogentry_8f3a2c',
                changelogPublished: true,
                changelogTypes: 'new',
                statusChangeFrom: 'under_review',
                statusChangeTo: 'succeeded',
                tagCount: 3,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
