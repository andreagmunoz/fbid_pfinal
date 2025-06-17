FROM cassandra:3.11

#Ejecutando el script
echo 'Convirtiendo JSONL a CSV...'
python3 /cassandra-init/json_to_csv.py
echo 'Conversión completada.'

# Copia el directorio de inicialización
COPY ./init/ /cassandra-init/

