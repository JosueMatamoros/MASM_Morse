import firebase_admin
from firebase_admin import credentials, firestore
import os

# Obtener la ruta actual del script
current_directory = os.path.dirname(os.path.abspath(__file__))

# Combinar la ruta actual con el nombre del archivo JSON
file_path = os.path.join(current_directory, "firebase_config.json")

# Inicializar la aplicación de Firebase con las credenciales del archivo JSON
cred = credentials.Certificate(file_path)
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
