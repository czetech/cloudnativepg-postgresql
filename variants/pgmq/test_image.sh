#!/usr/bin/env sh
set -e

container_name=cloudnativepg-postgresql
container_exec_cmd="docker exec ${container_name}"
psql_cmd="${container_exec_cmd} psql --username postgres"

# Start the PostgreSQL container
docker run \
  --detach \
  --env POSTGRES_PASSWORD=password \
  --name "${container_name}" \
  --user root \
  "${IMAGE:?}"

# Wait for the PostgreSQL server to be ready
until ${container_exec_cmd} pg_isready; do
  sleep 1
done
echo "PostgreSQL server is running"

# Create the pgmq extension
${psql_cmd} --command "CREATE EXTENSION pgmq"
echo "Extension pgmq created"

# Create a new queue
${psql_cmd} --command "SELECT pgmq.create('queue')"
echo "Queue created"

# Send a message to the queue
${psql_cmd} --command "SELECT * from pgmq.send(
    queue_name => 'queue',
    msg => '{\"foo\": \"bar\"}'
  )"
echo "Message sent to queue"

# Pop a message from the queue
queue_pop_count=$(${psql_cmd} \
  --no-align \
  --command "SELECT COUNT(*) from pgmq.pop('queue')" \
  --tuples-only)
echo "Queue pop count: '${queue_pop_count}'"
[ "${queue_pop_count}" = 1 ]
echo "Message popped from queue"
