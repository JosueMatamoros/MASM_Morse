import firebase_admin
from firebase_admin import credentials, firestore

# Inicializar la aplicación de Firebase con las credenciales del archivo JSON
cred = credentials.Certificate("C:/MASM_Morse/firebase_config.json")
firebase_admin.initialize_app(cred)

# Obtener una referencia a la base de datos
db = firestore.client()

# Referencia a la colección que deseas eliminar
coleccion_usuarios = db.collection("chat")

# Obtener los documentos en la colección
documentos = coleccion_usuarios.stream()

# Eliminar cada documento en la colección
for documento in documentos:
    documento.reference.delete()

# Eliminar los datos en chat.txt    
with open("chat.txt", "w") as archivo:
    archivo.write("")
    
print("Colección 'chat' eliminada Salirosamente")
