#!/bin/bash

# Solicita al usuario que ingrese el namespace y el nombre del secreto
read -p "Ingrese el namespace: " NAMESPACE
read -p "Ingrese el nombre del secreto: " SECRET_NAME
read -p "Ingrese la URL de destino para curl: " CURL_URL

# Verifica si los valores no están vacíos
if [ -z "$NAMESPACE" ] || [ -z "$SECRET_NAME" ] || [ -z "$CURL_URL" ]; then
  echo "Error: Namespace, nombre del secreto y URL de destino son requeridos."
  exit 1
fi

# Obtén el secreto en formato JSON
SECRET_JSON=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o json)

# Verifica si el comando anterior fue exitoso
if [ $? -ne 0 ]; then
  echo "Error: No se pudo obtener el secreto $SECRET_NAME en el namespace $NAMESPACE"
  exit 1
fi

# Decodifica los datos del secreto y construye un objeto JSON
DECODED_SECRETS=$(echo "$SECRET_JSON" | jq -r '.data | to_entries | map({(.key): (.value | @base64d)}) | add')

# Construye el JSON final con el formato requerido
#FINAL_JSON=$(jq -n --argjson data "$DECODED_SECRETS" '{data: $data}')
FINAL_JSON="{\"data\": $DECODED_SECRETS}"
# Define el archivo de salida
OUTPUT_FILE="secretos.json"

# Guarda el JSON resultante en un archivo
echo "$FINAL_JSON" > "$OUTPUT_FILE"

# Verifica si el archivo se guardó correctamente
if [ $? -eq 0 ]; then
  echo "Se guardó el secreto decodificado en el archivo $OUTPUT_FILE"
else
  echo "Error: No se pudo guardar el archivo $OUTPUT_FILE"
  exit 1
fi

# Envía el archivo JSON usando curl
# curl -X POST -H "Content-Type: application/json" --data @"$OUTPUT_FILE" "$CURL_URL"

# # Verifica si curl fue exitoso
# if [ $? -eq 0 ]; then
#   echo "El archivo $OUTPUT_FILE se envió correctamente a $CURL_URL"
# else
#   echo "Error: No se pudo enviar el archivo $OUTPUT_FILE a $CURL_URL"
#   exit 1
# fi
