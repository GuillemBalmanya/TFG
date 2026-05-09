import json
import argparse
from pathlib import Path
from datetime import datetime
#S'hauria de mirar d'evitar utilitzar numpy i trobar un recanvi per np.nan
import numpy as np
import pandas as pd

class DataQualityTests:
    def __init__(self, csv_antic, csv_nou, config=None, output_dir="D:/"):
        self.csv_antic = csv_antic
        self.csv_nou = csv_nou
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        if config:
            self.config = config
        else:
            self.config = {}
        self.clau_primaria = self.config.get("clau_primaria", [])
        self.columnes_ignorar = set(self.config.get("columnes_ignorar", []))
        self.columnes_dates = set(self.config.get("columnes_dates", []))
        self.columnes_numeriques = set(self.config.get("columnes_numeriques", []))
        self.columnes_noespais = self.config.get("columnes_noespais", True)
        self.columnes_nomajuscules = self.config.get("columnes_nomajuscules", False)
        self.valors_null = self.config.get("valors_null",["", "NULL", "null", "None", np.nan])
        self.report = {"timestamp": str(datetime.now()),"tests": {}}

    def carregar_csv(self, path):
        """
        Carrega els CSV.
        """
        try:
            df = pd.read_csv(path,sep=";",dtype=str,encoding="utf-8",keep_default_na=False)
            if len(df.columns) > 1:
                return df

        except Exception:
            pass
        raise Exception("No s'ha pogut llegir el CSV")

    def normalitzar_dataframe(self, df):
        """
        S'apliquen les següents comprovacions;
            1. Comprovació de Nulls
            2. Comprovació d'espais al principi i final
            3. Comprovació de majúscules
            4. Comprovació de dates
            5. Normalització decimals
        """
        df=df.copy()
        for col in df.columns:
            if col not in self.columnes_ignorar:
                #Asegurar-se que les columnes que haurien de tenir Null's, en tenen
                df[col]=df[col].replace(self.valors_null, np.nan)
                if self.columnes_noespais:
                    #Treure espais en blanc al principi i final (i forçar string)
                    df[col]=df[col].astype(str).str.strip()
                if not self.columnes_nomajuscules:
                    #Treure majúscules
                    df[col]=df[col].astype(str).str.lower()
                if col in self.columnes_dates:
                    #Normalitzar dades
                    df[col]=self.normalitzar_dates(df[col])
                if col in self.columnes_numeriques:
                    #Normalitzar dades numèriques (decimals)
                    df[col]=self.normalitzar_numeric(df[col])
        return df

    def normalitzar_dates(self, columnes):
        """
        Normalitza dates declarant el format Any-Mes-Dia. Per gestió d'errors convertim en NaN.
        """
        return pd.to_datetime(columnes,errors="coerce",utc=True).dt.strftime("%Y-%m-%d")

    def normalitzar_numeric(self, columnes):
        """
        Normalitza decimals. Per gestió d'errors convertim en NaN.
        """
        return pd.to_numeric(columnes,errors="coerce").round(2)

    def validar_estructura(self, csv_antic, csv_nou):
        """
        Compara l'estructura de l'àntic CSV amb la nova (ha de ser idèntic)
        """
        columnes_antigues = set(csv_antic.columns)-self.columnes_ignorar
        columnes_noves = set(csv_nou.columns) - self.columnes_ignorar
        faltants = columnes_antigues - columnes_noves
        noves = columnes_noves - columnes_antigues

        if faltants or noves:
            raise Exception("Estructures diferents")
        resultat = {"mateixa_estructura": (len(faltants) == 0 and len(noves) == 0)}
        self.report["tests"]["estructura"] = resultat
        return resultat

    def validar_files (self, csv_antic, csv_nou, n_files):
        """
        Valida nombre de files. En cas de detectar un número diferent de registres aixeca error.
        """
        n_antic = n_files
        n_nou = len(csv_nou)
        diferencia = n_nou - n_antic
        #Si la diferència és diferent de 0 significa que el número de files no és igual.
        if diferencia != 0:
            raise Exception("Número de registres diferent")
        resultat = {"files_antic": len(csv_antic),"files_nou": len(csv_nou),"diferencia": len(csv_nou) - len(csv_antic),}
        self.report["tests"]["n_files"] = resultat
        return resultat

    def validar_duplicats(self, df, nom):
        """
        Detecta duplicats en la clau primària (Suposem que sempre hi haurà clau primària). En cas que hi hagi duplicats aixeca error.
        """
        #Totes les taules han de tenir clau primària
        if not self.clau_primaria:
            raise Exception("Taula sense clau primaria")
            return None
        #Detectar files duplicades amb mètode duplicated
        duplicated = df[df.duplicated(self.clau_primaria, keep=False)]
        fitxer_sortida = self.output_dir / f"duplicats_{nom}.csv"
        duplicated.to_csv(fitxer_sortida, index=False)
        result = {"dataset": nom,"n_duplicats": len(duplicated),"te_duplicats": len(duplicated) > 0,"fitxer_amb_duplicats": str(fitxer_sortida)}
        return result

    def comparar_dades(self, csv_antic, csv_nou):
        """
        Comparació fila a fila de valors, evitem comparar Nulls. No aixeca error, simplement crea arxiu amb linies amb diferència
        """
        #Seleccionem les columnes del csv_antic per comparar, s'han corregut altres tests abans i per tant csv_nou té les mateixes que l'àntic.
        columnes_comparar = []
        for col in csv_antic.columns:
            if col not in self.columnes_ignorar and col in csv_nou.columns:
                columnes_comparar.append(col)

        csv_antic=csv_antic[columnes_comparar]
        csv_nou=csv_nou[columnes_comparar]
        #Ordenem i reiniciem els index per poder comparar línia a línia.
        if self.clau_primaria:
            csv_antic=csv_antic.sort_values(self.clau_primaria)
            csv_nou=csv_nou.sort_values(self.clau_primaria)

        csv_antic=csv_antic.reset_index(drop=True)
        csv_nou=csv_nou.reset_index(drop=True)
        #En cas de que no tinguessim el test validar_files, caldria agafar el mateix número de files (ja ho tenen)
        #min_rows = min(len(csv_antic), len(csv_nou))
        #old_df = csv_antic.iloc[:min_rows]
        #new_df = csv_nou.iloc[:min_rows]

        diferencies = []
        for col in columnes_comparar:
            valors_antics=csv_antic[col]
            valors_nous=csv_nou[col]
            #mascara per comparar files
            mascara = (valors_antics.fillna("<NULL>")!=valors_nous.fillna("<NULL>"))
            diff_rows = csv_antic[mascara]
            for index in diff_rows.index:
                diferencies.append({"fila": index,"columna": col,"valor_antic": valors_antics.iloc[index],"valor_nou": valors_nous.iloc[index]})

        diff_df = pd.DataFrame(diferencies)
        diff_arxiu = self.output_dir / "diferencies.csv"
        diff_df.to_csv(diff_arxiu, index=False)
        resultat = {"total_differences": len(diff_df),"fitxer_diferencies": str(diff_arxiu)}
        self.report["tests"]["comparacio_valors_files"] = resultat
        return diff_df

    """def validar_nulls(self, csv_antic, csv_nou):
        #Test comparació número de nulls per columnes
        resultats=[]
        columnes_comunes=set(csv_antic.columns).intersection(csv_nou.columns)
        for col in columnes_comunes:
            nulls_antics=csv_antic[col].isna().sum()
            nulls_nous=csv_nou[col].isna().sum()
            resultats.append({"columna": col,"n_nulls_antic": int(nulls_antics),"n_nulls_nou": int(nulls_nous),"diferencia_numero": int(nulls_nous-nulls_antics)})
        df_resultat=pd.DataFrame(resultats)
        fitxer_sortida=self.output_dir / "N_nuls.csv"
        df_resultat.to_csv(fitxer_sortida, index=False)
        return df_resultat"""

    def validar_num(self, csv_antic, csv_nou):
        """
        Estadístiques numèriques. Validem la suma, mitjana, màxim i mínim per cada columna numèrica.
        """
        llista=[]
        for col in self.columnes_numeriques:
            #Comprovem que la columna estigui als csv, en cas contrari aixequem error (json entrada està malament).
            if col not in csv_antic.columns or col not in csv_nou.columns:
                continue
            columnes_num_antigues = pd.to_numeric(csv_antic[col], errors="coerce")
            columnes_num_noves = pd.to_numeric(csv_nou[col], errors="coerce")
            llista.append({"columna": col,"suma_antiga": columnes_num_antigues.sum(),"suma_nova": columnes_num_noves.sum(),"mitjana_antiga": columnes_num_antigues.mean(),"mitjana_nova": columnes_num_noves.mean(),"min_antic": columnes_num_antigues.min(),"min_nou": columnes_num_noves.min(),"max_antic": columnes_num_antigues.max(),"max_nou": columnes_num_noves.max()})
        df = pd.DataFrame(llista)
        output = self.output_dir / "Num_validacio.csv"
        df.to_csv(output, index=False)
        return df

    def generar_resum(self):
        """
        Generar el resum de tots els tests.
        """
        resum = self.output_dir / "resum.json"
        with open(resum, "w", encoding="utf-8") as f:
            json.dump(self.report, f, indent=2, ensure_ascii=False)
        return resum

    def main(self):

        print("Carregant CSV...")
        df_antic = self.carregar_csv(self.csv_antic)
        df_nou = self.carregar_csv(self.csv_nou)
        print("1. Normalització...")
        df_antic = self.normalitzar_dataframe(df_antic)
        df_nou = self.normalitzar_dataframe(df_nou)
        print("2. Validació estructura...")
        structure = self.validar_estructura(df_antic, df_nou)
        print(structure)
        print("3. Validació files...")
        rows = self.validar_files(df_antic, df_nou)
        print(rows)
        print("4. Validació duplicats...")
        a_duplicats=self.validar_duplicats(df_antic, "antic")
        n_duplicats=self.validar_duplicats(df_nou, "nou")
        print(a_duplicats)
        print(n_duplicats)
        print("5. Comparació dades...")
        diff_df = self.comparar_dades(df_antic, df_nou)
        print(f"Diferències trobades: {len(diff_df)}")
        print("6. Validació nulls...")
        #self.validar_nulls(df_antic, df_nou)
        #print("7. Estadístiques numèriques...")
        self.validate_numeric_stats(df_antic, df_nou)
        print("7. Generació del resum...")
        resum = self.generar_resum()
        print(f"Resum generat: {resum}")
        print("Tests aprovats")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    #Direcció csv nous i antics per comparar
    parser.add_argument("--o", required=True)
    parser.add_argument("--n", required=True)
    #Json amb configuració dels fitxers csv
    parser.add_argument("--config")
    #Direcció de sortida dels fitxers
    parser.add_argument("--s")
    args = parser.parse_args()
    config = {}
    if args.config:
        with open(args.config, "r", encoding="utf-8") as f:
            config = json.load(f)
    comparator = DataQualityTests(csv_antic=args.o,csv_nou=args.n,config=config,output_dir=args.s)
    comparator.main()