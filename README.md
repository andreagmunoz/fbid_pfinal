# Versión 1 - Docker Compose

Se ha creado el archivo `docker-compose.yml`con los siguientes servicios (todos ellos conectados a la red `docker_network`): 

## Zookeeper

Construido a partir de la imagen base `wurstmeister/zookeeper`. Expone el puerto 2181, que es el puerto estándar donde los clientes (como Kafka brokers) se conectan a ZooKeeper.

## Kafka

Este servicio configura un contenedor Kafka usando la imagen wurstmeister/kafka:2.12-2.3.0 con las siguientes características clave:

- Conexión a Zookeeper haciendo referencia al contenedor anterior: `zookeeper:2181`.
- Acepta conexiones dirigidas al puerto `9092` en todas las interfaces y expone `kafka:9092`
- Crea automáticamente el topic `flight-delay-ml-request` con 1 partición y factor de replicación 1 al iniciar. Para ello: `AUTO_CREATE_TOPICS_ENABLE: "true"`
- Asegura el arranque después de Zookeeper (`depends_on`).
- Monta la carpeta local `./kafka` dentro del contenedor en `/kafka-scripts`, donde se encuentra el script `create_topics.sh`
- Entrypoint personalizado: Usa el script `/kafka-scripts/create_topics.sh` como entrypoint, lo que significa que al arrancar el contenedor se ejecutará ese script en lugar del comando por defecto. Se utiliza para la creación del topic de vuelta por kafka. 

## Mongo

- Expone el puerto por defecto de mongo `:27017`
- Monta la carpeta local `mongo/init` en `/docker-entrypoint-initdb.d/`, que contiene el script `import_distances.sh`que inicializa la base de datos.
- Implementa persistencia en el volumen `mongodb_data`

## Flask 

Se construye a partir del `Dockerfile` existente en `flask/`, que usa una imagen de Python, instala las dependencias necesarias para la aplicación y copia su código duente y expone el puerto 5001.

En el `docker-compose.yml`:

- Se define la variable de entonrno `PROJECT_HOME`
- Se monta el directorio local `flask/`en `flask-container/`
- Se ejecuta la aplicación mediante el script `predict_flask.py`

## Spark 

Se define un entorno completo para la ejecución de un cluster de Apache Spark. Todos los nodos montan el directorio `spark/` y `checkpoint/` para persistencia. Está formado por: 

1. `proxy` 

Contenedor basado en Node.js que actúa como intermediario en el clúster.

2. `spark-master`

- Expone los puertos `:8080`y `:7077` para la interfaz web de Spark y conexiones de workers y clientes, respectivamente.
- Depende del proxy para iniciarse

3. `spark-worker-1`y `spark-worker-2`

- Dos nodos workers de Spark idénticos que dependen del máster para iniciar
- Se conectan a la dirección expuesta por el maestro

