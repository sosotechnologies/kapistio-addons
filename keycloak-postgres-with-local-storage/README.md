k exec -it postgres-7b4d4cfd89-rhfxx -- /bin/sh
psql -U myuser -d mydatabase

SELECT datname FROM pg_database;
\dt


## see schema name
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema');
