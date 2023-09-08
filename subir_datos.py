import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import firebase_admin
from firebase_admin import credentials, firestore
print("Esperando cambios...")

# Función para verificar si un archivo está abierto por otro proceso
def is_file_open(file_path):
    try:
        with open(file_path, 'r') as file:
            return False
    except Exception as e:
        return True

# Clase para manejar eventos de cambios en el archivo
class MyHandler(FileSystemEventHandler):
    def __init__(self, file_path, db):
        self.file_path = file_path
        self.db = db
    
    def on_modified(self, event):
        if not event.is_directory and event.src_path == self.file_path:
            while is_file_open(self.file_path):
                # Espera hasta que el archivo esté cerrado
                time.sleep(1)
            # Cuando el archivo morse.txt está cerrado, leemos su contenido
            with open(self.file_path, "r") as file:
                data = file.read()
                # Verificar si el archivo no está vacío
                if data.strip():
                    print("Contenido del archivo morse.txt:", data)
                    # Luego, borramos el contenido del archivo
                    with open(self.file_path, "w") as file:
                        file.write("")

                    # Eliminar caracteres nulos de la cadena
                    data = data.replace("\x00", "")
                    # Dividir la cadena en nombre y mensaje usando "@" como separador
                    nombre, mensaje = data.split("@")

                    # Eliminar espacios en blanco adicionales al principio y al final de cada parte
                    nombre = nombre.strip()
                    mensaje = mensaje.strip()

                    # Extraer hora actual
                    hora = time.strftime("%H:%M")

                    # Crear el nuevo mensaje en el formato deseado
                    nuevo_mensaje = {
                        "nombre": nombre,
                        "mensaje": mensaje,
                        "hora": hora
                    }

                    # Subir los datos a Firebase
                    coleccion_usuarios = self.db.collection("chat")
                    nuevo_documento = coleccion_usuarios.add(nuevo_mensaje)
                    print("Datos subidos correctamente")

if __name__ == "__main__":
    # Ruta al archivo que deseas monitorear
    file_to_monitor = "morse.txt"
    
    # Obtén la ruta completa al archivo morse.txt
    current_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(current_directory, file_to_monitor)

    # Inicializar la aplicación de Firebase con las credenciales del archivo JSON
    cred = credentials.Certificate(os.path.join(current_directory, "firebase_config.json"))
    firebase_admin.initialize_app(cred)

    # Obtener una referencia a la base de datos
    db = firestore.client()

    event_handler = MyHandler(file_path, db)
    observer = Observer()
    observer.schedule(event_handler, path=current_directory, recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
