import sys
import os

# LOG SEGUR (important: afegim flush + close segur)
log = open("D:/temp/python_debug.log", "w", encoding="utf-8")

try:
    log.write("ARGV: " + str(sys.argv) + "\n")
    log.flush()

    # VALIDACIÓ MÍNIMA (evita IndexError silenciós)
    if len(sys.argv) < 5:
        log.write("ERROR: Falten paràmetres\n")
        sys.exit(1)

    base_dirs = {
        "xslt": sys.argv[2],
        "json": sys.argv[3],
        "misc": sys.argv[4]
    }

    files = sys.argv[1].split(",")

    missing = []

    for f in files:
        f = f.strip().strip('"').strip("'")  # 👈 IMPORTANT ODI

        if f.endswith(".xslt"):
            path = os.path.join(base_dirs["xslt"], f)
        elif f.endswith(".json"):
            path = os.path.join(base_dirs["json"], f)
        else:
            path = os.path.join(base_dirs["misc"], f)

        log.write("CHECK: " + path + "\n")
        log.flush()

        if not os.path.isfile(path):
            missing.append(path)

    if missing:
        log.write("MISSING FILES:\n")
        for m in missing:
            log.write(m + "\n")

        print("Fitxers inexistents")
        sys.exit(1)

    print("Tots els fitxers existeixen")
    sys.exit(0)

except Exception as e:
    log.write("EXCEPTION: " + str(e) + "\n")
    sys.exit(1)

finally:
    log.close()