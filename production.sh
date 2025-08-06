#!/bin/bash

# Script para verificar, construir y ejecutar la aplicación DevOps
echo "=== Script de verificación DevOps ==="

# Verificar si Docker está instalado
echo "Verificando instalación de Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado o no está en el PATH"
    exit 1
fi

if ! docker --version &> /dev/null; then
    echo "❌ Error: Docker no está funcionando correctamente"
    exit 1
fi

echo "✅ Docker está instalado y funcionando"

# Detener y eliminar contenedor existente si existe
echo "Limpiando contenedores existentes..."
docker stop devops-app 2>/dev/null || true
docker rm devops-app 2>/dev/null || true

# Construir la imagen
echo "Construyendo la imagen Docker..."
if ! docker build -t devops-app .; then
    echo "❌ Error: Falló la construcción de la imagen Docker"
    exit 1
fi

echo "✅ Imagen construida exitosamente"

# Ejecutar el contenedor
echo "Ejecutando el contenedor..."
if ! docker run -d \
    --name devops-app \
    -p 8080:3000 \
    -e PORT=3000 \
    -e NODE_ENV=production \
    devops-app; then
    echo "❌ Error: Falló la ejecución del contenedor"
    exit 1
fi

echo "✅ Contenedor ejecutándose"

# Realizar prueba básica
echo "Realizando prueba del servicio..."
for i in {1..10}; do
    if curl -s -f http://localhost:8080/health > /dev/null; then
        echo "✅ Servicio respondiendo correctamente"
        break
    fi
    
    if [ $i -eq 10 ]; then
        echo "❌ Error: El servicio no responde después de 10 intentos"
        docker logs devops-app
        docker stop devops-app
        docker rm devops-app
        exit 1
    fi
    
    echo "   Intento $i/10 - Esperando respuesta..."
    sleep 2
done