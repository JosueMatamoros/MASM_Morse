import time
import sys
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


# Clase para manejar eventos de cambios en el archivo
class MyHandler(FileSystemEventHandler):
    def __init__(self, file_path):
        self.file_path = file_path
    
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

            # Crear el nuevo mensaje en el formato deseado
            nuevo_mensaje = {
                "nombre": nombre,
                "mensaje": mensaje
            }
            print("Mensaje a subir:", nuevo_mensaje)

# Función para verificar si un archivo está abierto por otro proceso
def is_file_open(file_path):
    try:
        with open(file_path, 'r') as file:
            return False
    except Exception as e:
        return True

if __name__ == "__main__":
    # Ruta al archivo que deseas monitorear
    file_to_monitor = "morse.txt"
    
    # Obtén la ruta completa al archivo morse.txt
    current_directory = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(current_directory, file_to_monitor)

    event_handler = MyHandler(file_path)
    observer = Observer()
    observer.schedule(event_handler, path=current_directory, recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
