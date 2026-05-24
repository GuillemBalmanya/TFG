import urllib.request
import json
import os


def descarregar_i_guardar_api_json(url: str, directori: str, nom_arxiu: str) -> dict:
    """
    Fa una petició a una API que retorna JSON i guarda el resultat en un arxiu local.

    :param url: L'enllaç de l'API (ex: 'https://jsonplaceholder.typicode.com/todos/1')
    :param directori: La carpeta on es guardarà l'arxiu (ex: 'dades_api')
    :param nom_arxiu: El nom de l'arxiu (ex: 'resultat.json')
    :return: Retorna el diccionari amb les dades de l'API o None si hi ha error.
    """

    # 1. Crear el directori si no existeix
    if not os.path.exists(directori):
        os.makedirs(directori)

    ruta_completa = os.path.join(directori, nom_arxiu)

    try:
        # 2. Fer la petició HTTP
        with urllib.request.urlopen(url) as resposta:
            # Llegir la resposta i decodificar-la a text (utf-8)
            dades_crues = resposta.read().decode('utf-8')

            # 3. Convertir el text a un diccionari de Python (JSON)
            dades_json = json.loads(dades_crues)

            # 4. Guardar les dades en un arxiu local
            with open(ruta_completa, 'w', encoding='utf-8') as arxiu:
                # json.dump guarda l'objecte directament a l'arxiu amb bona formatació (indent=4)
                json.dump(dades_json, arxiu, ensure_ascii=False, indent=4)

            print(f"✅ Dades guardades correctament a: {ruta_completa}")
            return dades_json

    except urllib.error.URLError as e:
        print(f"❌ Error de connexió en la petició: {e}")
    except json.JSONDecodeError:
        print("❌ Error: La resposta de l'API no és un JSON vàlid.")
    except Exception as e:
        print(f"❌ S'ha produït un error inesperat: {e}")

    return None


# --- EXEMPLE D'ÚS ---
if __name__ == "__main__":
    # Utilitzem una API pública de prova
    url_api = "https://jsonplaceholder.typicode.com/posts/1"
    carpeta_desti = "meves_dades"
    nom_del_fitxer = "post_1.json"

    resultat = descarregar_i_guardar_api_json(url_api, carpeta_desti, nom_del_fitxer)