#!/bin/bash

#set -e

echo 'Esperando a que Cassandra esté disponible...'
until cqlsh cassandra -e "SELECT now() FROM system.local" >/dev/null 2>&1; do
  echo 'Cassandra aún no está lista. Esperando 10 segundos...'
  sleep 10
done

echo 'Cassandra está lista. Creando keyspace...'

cqlsh cassandra -e "CREATE KEYSPACE IF NOT EXISTS agile_data_science WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': 1 };"

echo 'Creando tablas...'

# Cada tabla en una llamada separada para evitar errores de parsing
cqlsh cassandra -e "CREATE TABLE IF NOT EXISTS agile_data_science.origin_dest_distances (
  origin TEXT,
  destination TEXT,
  distance DOUBLE,
  PRIMARY KEY (origin, destination)
);"

cqlsh cassandra -e "CREATE TABLE IF NOT EXISTS agile_data_science.predictions (
  uuid text PRIMARY KEY,
  origin TEXT,
  dayofweek INT,
  dayofmonth INT,
  dayofyear INT,
  dest TEXT,
  depdelay DOUBLE,
  timestamp TEXT,
  flightdate TEXT,
  carrier TEXT,
  distance DOUBLE,
  route TEXT,
  prediction DOUBLE
);"

cqlsh cassandra -e  "CREATE TABLE IF NOT EXISTS agile_data_science.predictions_by_day (
  date_partition TEXT, -- 'YYYY-MM-DD'
  timestamp TEXT,
  uuid text,
  carrier TEXT,
  dayofmonth INT,
  dayofweek INT,
  dayofyear INT,
  depdelay DOUBLE,
  dest TEXT,
  distance DOUBLE,
  flightdate TEXT,
  origin TEXT,
  prediction DOUBLE,
  route TEXT,
  PRIMARY KEY ((date_partition), timestamp, uuid)
);"

cqlsh cassandra -e "CREATE TABLE IF NOT EXISTS agile_data_science.distances (
  uuid text PRIMARY KEY,
  origin TEXT,
  dest TEXT,
  distance DOUBLE
);"

cqlsh cassandra -e "CREATE TABLE IF NOT EXISTS agile_data_science.airplanes (
  uuid text PRIMARY KEY,
  carrier TEXT,
  type TEXT
);"

echo 'Tablas creadas correctamente.'

echo 'Importando datos desde CSV...'

cqlsh cassandra -k agile_data_science -e "COPY origin_dest_distances (origin, destination, distance) FROM '/init-data/origin_dest_distances.csv' WITH HEADER = TRUE;"

echo 'Datos importados correctamente.'
