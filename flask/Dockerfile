# Usa una imagen base de Python
FROM python:3.9-slim

# Instala dependencias necesarias, incluyendo curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Crea el directorio de trabajo
WORKDIR /flask

# Copiar el archivo de dependencias de la aplicación Flask
COPY requirements.txt /flask_container/

# Instalar las dependencias de Python
RUN python -m pip install -r /flask_container/requirements.txt

# Copiar el código de la aplicación Flask
COPY web /flask_container/web/

# Exponer el puerto para Flask
EXPOSE 5001

# Define el punto de entrada por defecto
CMD ["bash"]