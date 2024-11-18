FROM redash/redash:10.1.0.b50633 AS base

ENTRYPOINT ["/app/bin/docker-entrypoint"]

FROM base AS web
CMD export MAX_REQUESTS=${MAX_REQUESTS:-1000}; export MAX_REQUESTS_JITTER=${MAX_REQUESTS_JITTER:-100}; exec /usr/local/bin/gunicorn -b 0.0.0.0:$PORT --name redash -w${REDASH_WEB_WORKERS:-4} redash.wsgi:app --max-requests $MAX_REQUESTS --max-requests-jitter $MAX_REQUESTS_JITTER

FROM base AS scheduler
CMD exec /app/bin/docker-entrypoint scheduler

FROM base AS worker
CMD exec /app/bin/docker-entrypoint worker