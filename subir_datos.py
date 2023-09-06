import os
import firebase_admin
from firebase_admin import credentials, firestore

# Obtener la ruta actual del script
current_directory = os.path.dirname(os.path.abspath(__file__))

# Combinar la ruta actual con el nombre del archivo JSON
file_path = os.path.join(current_directory, "firebase_config.json")

# Inicializar la aplicación de Firebase con las credenciales del archivo JSON
cred = credentials.Certificate(file_path)
firebase_admin.initialize_app(cred)

# Obtener una referencia a la base de datos
db = firestore.client()

# Dict con los datos a subir
nuevo_mensaje = {
    "nombre": "Josue Matamoros",
    "mensaje": ".... --- .-.. .- / -- .. / .- ...- --- .-."
}

# Agregar los datos a una colección llamada "usuarios"
coleccion_usuarios = db.collection("chat")
nuevo_documento = coleccion_usuarios.add(nuevo_mensaje)

print("Datos subidos correctamente")
