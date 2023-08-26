import firebase_admin
from firebase_admin import credentials, firestore

# Inicializar la aplicación de Firebase con las credenciales del archivo JSON
cred = credentials.Certificate("C:/MASM_Morse/firebase_config.json")
firebase_admin.initialize_app(cred)

# Obtener una referencia a la base de datos
db = firestore.client()

# Dict con los datos a subir
nuevo_mensaje = {
    "nombre": "Miguel",
    "mensaje": ".... --- .-.. .- / -- .. / .- ...- --- .-."
}

# Agregar los datos a una colección llamada "usuarios"
coleccion_usuarios = db.collection("chat")
nuevo_documento = coleccion_usuarios.add(nuevo_mensaje)

print("Datos subidos correctamente")
