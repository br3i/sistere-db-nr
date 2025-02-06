#!/bin/bash

#chmod +x init.sh

# Instalando dependencias necesarias
echo "📦 Instalando dependencias necesarias..."
apt update && apt install -y pciutils lshw

# Verificando si Ollama ya está instalado
if command -v ollama &> /dev/null; then
    echo "✅ Ollama ya está instalado. Omitiendo instalación."
else
    echo "🔧 Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Ejecutando Ollama en segundo plano si no está corriendo
if pgrep -x "ollama" > /dev/null; then
    echo "✅ Ollama ya está en ejecución."
else
    echo "🚀 Iniciando Ollama en segundo plano..."
    nohup ollama serve &
    sleep 10  # Esperar para asegurar que se inicie correctamente
fi

# Función para descargar modelos si no están ya descargados
download_model() {
    MODEL=$1
    if ollama list | grep -q "$MODEL"; then
        echo "✅ El modelo $MODEL ya está descargado. Omitiendo descarga."
    else
        echo "⬇️ Descargando modelo $MODEL..."
        ollama pull "$MODEL"
        sleep 10  # Esperar para estabilizar Ollama
    fi
}


# Descargar los modelos necesarios
download_model "deepseek-r1:32b"
download_model "gemma2:27b"
download_model "granite3.1-dense"
download_model "granite3.1-moe:3b"
download_model "bge-m3"

# Reiniciando Ollama para asegurarnos de que los modelos estén disponibles
echo "🔄 Reiniciando Ollama..."
pkill ollama
nohup ollama serve &
sleep 10

# Iniciando el backend con Uvicorn
echo "🌍 Iniciando el backend con Uvicorn..."
cd /workspace/sistere-backend
uvicorn app-fa:app --host 0.0.0.0 --port 8000 --reload
