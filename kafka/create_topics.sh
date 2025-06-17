#!/bin/sh

# Esperar a que Zookeeper esté disponible
until nc -z -v -w30 zookeeper 2181; do
  echo "Esperando a Zookeeper..."
  sleep 5
done

# Iniciar Kafka en segundo plano
/usr/bin/start-kafka.sh &

# Esperar a que Kafka esté disponible
echo "Esperando a Kafka..."
until kafka-topics.sh --list --bootstrap-server kafka:9092 > /dev/null 2>&1; do
  sleep 5
done

# Crear el topic si no existe
TOPIC_NAME="flight-delay-ml-response"

EXISTS=$(kafka-topics.sh --list --bootstrap-server kafka:9092 | grep "^$TOPIC_NAME$")

if [ "$EXISTS" = "$TOPIC_NAME" ]; then
  echo "El topic '$TOPIC_NAME' ya existe."
else
  echo "Creando topic '$TOPIC_NAME'..."
  kafka-topics.sh --create \
    --topic "$TOPIC_NAME" \
    --partitions 1 \
    --replication-factor 1 \
    --bootstrap-server kafka:9092
fi

# Esperar a que Kafka termine
wait
