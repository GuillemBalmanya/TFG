# Comparador genèric CSV per regressions ODI (XML vs JSON)

## Objectiu

Aquest script permet comparar:

* CSV generats pel procés antic (XML)
* CSV generats pel procés nou (JSON)

amb validacions:

* estructurals
* funcionals
* semàntiques
* de qualitat de dades
* i regressió completa.

La idea és que sigui reutilitzable per qualsevol entitat:

* awards
* projects
* persons
* organisations
* publications
* etc.

---

# Característiques principals

## Validacions incloses

### 1. Validació estructura

* columnes mancants
* columnes extra
* ordre de columnes
* tipus de dades inferits

---

### 2. Validació dades

* recompte files
* duplicats
* nulls
* espais
* encoding
* decimals
* dates

---

### 3. Validació funcional

* comparació semàntica
* tolerància de formats
* ordenació automàtica
* normalització de nulls

---

### 4. Reports

Genera:

* resum global
* CSV de diferències
* CSV de files només antigues
* CSV de files només noves
* estadístiques

---

# Instal·lació

```bash
pip install pandas numpy python-dateutil
```

---

# Estructura recomanada

```text
project/
│
├── compare_csv.py
├── config/
│   └── awards_config.json
├── input/
│   ├── awards_xml.csv
│   └── awards_json.csv
└── output/
```

---

# Configuració opcional

## Exemple awards_config.json

```json
{
  "primary_key": ["uuid"],
  "ignore_columns": [
    "workflow"
  ],
  "date_columns": [
    "awardDate",
    "actualPeriodStartDate",
    "actualPeriodEndtDate"
  ],
  "numeric_columns": [
    "totalAwardedAmount",
    "totalSpendAmount"
  ],
  "trim_strings": true,
  "case_sensitive": false,
  "null_values": [
    "",
    "NULL",
    "null",
    "None"
  ]
}
```

---

# Script complet

## compare_csv.py

```python
import json
import argparse
from pathlib import Path
from datetime import datetime

import numpy as np
import pandas as pd


class CSVComparator:

    def __init__(self, old_file, new_file, config=None, output_dir="output"):
        self.old_file = old_file
        self.new_file = new_file
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        self.config = config or {}

        self.primary_key = self.config.get("primary_key", [])
        self.ignore_columns = set(self.config.get("ignore_columns", []))
        self.date_columns = set(self.config.get("date_columns", []))
        self.numeric_columns = set(self.config.get("numeric_columns", []))
        self.trim_strings = self.config.get("trim_strings", True)
        self.case_sensitive = self.config.get("case_sensitive", False)
        self.null_values = self.config.get(
            "null_values",
            ["", "NULL", "null", "None", np.nan]
        )

        self.report = {
            "timestamp": str(datetime.now()),
            "tests": {}
        }

    def load_csv(self, path):
        """
        Carrega CSV detectant separador i encoding.
        """

        separators = [";", ",", "\t", "|"]

        for sep in separators:
            try:
                df = pd.read_csv(
                    path,
                    sep=sep,
                    dtype=str,
                    encoding="utf-8",
                    keep_default_na=False
                )

                if len(df.columns) > 1:
                    return df

            except Exception:
                pass

        raise Exception(f"No s'ha pogut llegir el CSV: {path}")

    def normalize_dataframe(self, df):
        """
        Normalització general.
        """

        df = df.copy()

        for col in df.columns:

            if col in self.ignore_columns:
                continue

            df[col] = df[col].replace(self.null_values, np.nan)

            if self.trim_strings:
                df[col] = df[col].astype(str).str.strip()

            if not self.case_sensitive:
                df[col] = df[col].astype(str).str.lower()

            if col in self.date_columns:
                df[col] = self.normalize_dates(df[col])

            if col in self.numeric_columns:
                df[col] = self.normalize_numeric(df[col])

        return df

    def normalize_dates(self, series):
        """
        Normalitza dates.
        """

        return pd.to_datetime(
            series,
            errors="coerce",
            utc=True
        ).dt.strftime("%Y-%m-%d")

    def normalize_numeric(self, series):
        """
        Normalitza decimals.
        """

        return pd.to_numeric(
            series,
            errors="coerce"
        ).round(2)

    def validate_structure(self, old_df, new_df):
        """
        Compara estructura.
        """

        old_cols = set(old_df.columns) - self.ignore_columns
        new_cols = set(new_df.columns) - self.ignore_columns

        missing_in_new = old_cols - new_cols
        extra_in_new = new_cols - old_cols

        result = {
            "missing_columns": sorted(list(missing_in_new)),
            "extra_columns": sorted(list(extra_in_new)),
            "same_structure": (
                len(missing_in_new) == 0 and
                len(extra_in_new) == 0
            )
        }

        self.report["tests"]["structure"] = result

        return result

    def validate_row_counts(self, old_df, new_df):
        """
        Valida nombre de files.
        """

        result = {
            "old_rows": len(old_df),
            "new_rows": len(new_df),
            "difference": len(new_df) - len(old_df),
            "same_count": len(old_df) == len(new_df)
        }

        self.report["tests"]["row_counts"] = result

        return result

    def validate_duplicates(self, df, name):
        """
        Detecta duplicats.
        """

        if not self.primary_key:
            return None

        duplicated = df[df.duplicated(self.primary_key, keep=False)]

        output_file = self.output_dir / f"duplicates_{name}.csv"

        duplicated.to_csv(output_file, index=False)

        result = {
            "dataset": name,
            "duplicate_count": len(duplicated),
            "has_duplicates": len(duplicated) > 0,
            "output_file": str(output_file)
        }

        return result

    def compare_data(self, old_df, new_df):
        """
        Comparació principal.
        """

        compare_columns = [
            c for c in old_df.columns
            if c not in self.ignore_columns
            and c in new_df.columns
        ]

        old_df = old_df[compare_columns]
        new_df = new_df[compare_columns]

        if self.primary_key:
            old_df = old_df.sort_values(self.primary_key)
            new_df = new_df.sort_values(self.primary_key)

        old_df = old_df.reset_index(drop=True)
        new_df = new_df.reset_index(drop=True)

        min_rows = min(len(old_df), len(new_df))

        old_df = old_df.iloc[:min_rows]
        new_df = new_df.iloc[:min_rows]

        differences = []

        for col in compare_columns:

            old_values = old_df[col]
            new_values = new_df[col]

            diff_mask = (
                old_values.fillna("<NULL>") !=
                new_values.fillna("<NULL>")
            )

            diff_rows = old_df[diff_mask]

            for idx in diff_rows.index:
                differences.append({
                    "row": idx,
                    "column": col,
                    "old_value": old_values.iloc[idx],
                    "new_value": new_values.iloc[idx]
                })

        diff_df = pd.DataFrame(differences)

        diff_file = self.output_dir / "differences.csv"
        diff_df.to_csv(diff_file, index=False)

        result = {
            "total_differences": len(diff_df),
            "same_data": len(diff_df) == 0,
            "output_file": str(diff_file)
        }

        self.report["tests"]["data_comparison"] = result

        return diff_df

    def validate_nulls(self, old_df, new_df):
        """
        Compara nulls.
        """

        results = []

        common_columns = set(old_df.columns).intersection(new_df.columns)

        for col in common_columns:

            old_nulls = old_df[col].isna().sum()
            new_nulls = new_df[col].isna().sum()

            results.append({
                "column": col,
                "old_nulls": int(old_nulls),
                "new_nulls": int(new_nulls),
                "difference": int(new_nulls - old_nulls)
            })

        result_df = pd.DataFrame(results)

        output_file = self.output_dir / "null_analysis.csv"
        result_df.to_csv(output_file, index=False)

        return result_df

    def validate_numeric_stats(self, old_df, new_df):
        """
        Estadístiques numèriques.
        """

        stats = []

        for col in self.numeric_columns:

            if col not in old_df.columns or col not in new_df.columns:
                continue

            old_series = pd.to_numeric(old_df[col], errors="coerce")
            new_series = pd.to_numeric(new_df[col], errors="coerce")

            stats.append({
                "column": col,
                "old_sum": old_series.sum(),
                "new_sum": new_series.sum(),
                "old_mean": old_series.mean(),
                "new_mean": new_series.mean(),
                "old_min": old_series.min(),
                "new_min": new_series.min(),
                "old_max": old_series.max(),
                "new_max": new_series.max()
            })

        stats_df = pd.DataFrame(stats)

        output_file = self.output_dir / "numeric_stats.csv"
        stats_df.to_csv(output_file, index=False)

        return stats_df

    def generate_summary(self):
        """
        Genera resum.
        """

        summary_file = self.output_dir / "summary.json"

        with open(summary_file, "w", encoding="utf-8") as f:
            json.dump(self.report, f, indent=2, ensure_ascii=False)

        return summary_file

    def run(self):

        print("=" * 80)
        print("CSV REGRESSION COMPARATOR")
        print("=" * 80)

        old_df = self.load_csv(self.old_file)
        new_df = self.load_csv(self.new_file)

        print("[1] Normalització...")

        old_df = self.normalize_dataframe(old_df)
        new_df = self.normalize_dataframe(new_df)

        print("[2] Validació estructura...")
        structure = self.validate_structure(old_df, new_df)

        print(structure)

        print("[3] Validació files...")
        rows = self.validate_row_counts(old_df, new_df)

        print(rows)

        print("[4] Validació duplicats...")

        old_duplicates = self.validate_duplicates(old_df, "old")
        new_duplicates = self.validate_duplicates(new_df, "new")

        print(old_duplicates)
        print(new_duplicates)

        print("[5] Comparació dades...")

        diff_df = self.compare_data(old_df, new_df)

        print(f"Diferències trobades: {len(diff_df)}")

        print("[6] Validació nulls...")
        self.validate_nulls(old_df, new_df)

        print("[7] Estadístiques numèriques...")
        self.validate_numeric_stats(old_df, new_df)

        print("[8] Generació resum...")
        summary = self.generate_summary()

        print(f"Resum generat: {summary}")

        print("=" * 80)
        print("FINALITZAT")
        print("=" * 80)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument("--old", required=True)
    parser.add_argument("--new", required=True)
    parser.add_argument("--config")
    parser.add_argument("--output", default="output")

    args = parser.parse_args()

    config = {}

    if args.config:
        with open(args.config, "r", encoding="utf-8") as f:
            config = json.load(f)

    comparator = CSVComparator(
        old_file=args.old,
        new_file=args.new,
        config=config,
        output_dir=args.output
    )

    comparator.run()
```

---

# Exemple d'execució

## Comparació simple

```bash
python compare_csv.py \
  --old input/awards_xml.csv \
  --new input/awards_json.csv
```

---

## Comparació amb configuració

```bash
python compare_csv.py \
  --old input/awards_xml.csv \
  --new input/awards_json.csv \
  --config config/awards_config.json
```

---

# Sortides generades

## differences.csv

Conté:

* fila
* columna
* valor XML
* valor JSON

---

## duplicates_old.csv

Duplicats dataset antic.

---

## duplicates_new.csv

Duplicats dataset nou.

---

## null_analysis.csv

Comparació de nulls.

---

## numeric_stats.csv

Validació imports i mètriques.

---

## summary.json

Resum global.

---

# Recomanacions per ODI

## Integració recomanada

### Workflow

```text
ODI XML FLOW
    ↓
CSV XML

ODI JSON FLOW
    ↓
CSV JSON

Comparator Python
    ↓
Report regressió
```

---

# Millores futures recomanades

## 1. Comparació tolerant

Exemple:

```python
abs(old - new) < 0.01
```

per decimals.

---

## 2. Mapping de columnes

Per casos:

```text
customerId ↔ customer_id
```

---

## 3. Reports HTML

Amb:

* colors
* dashboards
* mètriques

---

## 4. Integració Jenkins / GitLab

Per regressió automàtica nightly.

---

# Recomanació important

Per datasets grans:

* evitar compare fila-a-fila textual
* comparar per primary key
* fer particions
* usar hashes

---

# Recomanació per les teves dades d'exemple

Als fitxers adjunts s'observa:

* mateix esquema parcial
* diferència de columnes
* molts camps opcionals
* camps numèrics
* camps de dates
* UUID com a clau principal

Per tant, recomano:

```json
{
  "primary_key": ["uuid"],
  "date_columns": [
    "awardDate",
    "actualPeriodStartDate",
    "actualPeriodEndtDate",
    "expectedPeriodStartDate",
    "expectedPeriodEndtDate"
  ],
  "numeric_columns": [
    "totalAwardedAmount",
    "totalSpendAmount"
  ],
  "case_sensitive": false,
  "trim_strings": true
}
```

Això et donarà una validació molt robusta per migracions XML → JSON.
