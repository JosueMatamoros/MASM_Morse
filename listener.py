import os
import google.cloud.firestore

# Obtener la ruta actual del script
current_directory = os.path.dirname(os.path.abspath(__file__))

# Combinar la ruta actual con el nombre del archivo JSON
file_path = os.path.join(current_directory, "firebase_config.json")

# Configura las credenciales del archivo JSON de la cuenta de servicio
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = file_path

# Inicializa el cliente de Firestore
db = google.cloud.firestore.Client()

# Referencia a la colección "chat"
coleccion_chat = db.collection("chat")

def on_snapshot(doc_snapshot, changes, read_time):
    with open("chat.txt", "a") as archivo:
        for cambio in changes:
            if cambio.type.name == "ADDED":
                mensaje = cambio.document.to_dict()
                archivo.write(mensaje['nombre'] + "\n")
                archivo.write(mensaje['mensaje'] + "\n")
                archivo.write("---\n")

    with open("chatTemp.txt", "w") as archivo:
        for cambio in changes:
            if cambio.type.name == "ADDED":
                mensaje = cambio.document.to_dict()
                archivo.write(mensaje['nombre'] + "\n")
                archivo.write(mensaje['mensaje'] + "\n")
                archivo.write("---\n")

# Crea un observador para la colección "chat"
chat_watch = coleccion_chat.on_snapshot(on_snapshot)

print("Esperando cambios...")

# Mantén el programa en ejecución para seguir recibiendo cambios
while True:
    pass

