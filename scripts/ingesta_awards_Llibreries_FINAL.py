import json
import os
import argparse
import pandas as pd

# Mapeig exacte de les columnes per mantenir la consistència
CSV_HEADERS = {
    'awards': "uuid;text_ca_ES;text_en_GB;text_es_ES;typePureId;typeUri;type_term_text_ca_ES;type_term_text_en_GB;type_term_text_es_ES;managingOrganisationalUnit_Uuid;managingOrganisationalUnit_ExternaId;MOU_name_text_ca_ES;MOU_name_text_en_GB;MOU_name_text_es_ES;SN_collaborative;totalAwardedAmount;totalSpendAmount;actualPeriodStartDate;actualPeriodEndtDate;expectedPeriodStartDate;expectedPeriodEndtDate;awardDate;estatId;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason;sn_aCarrecId;sn_aCarrec_term_text_ca_ES;sn_aCarrec_term_text_en_GB;sn_aCarrec_term_text_es_ES;workflow;pureId;natureTypePureId;natureTypeUri;natureType_term_text_ca_ES;natureType_term_text_en_GB;natureType_term_text_es_ES;recompte;justificacioEconomica".split(";"),
    'awards-holders': "uuid;text_ca_ES;text_en_GB;text_es_ES;awhUuid;externalAwhUuid;externalAwhTypePureId;awhExternalId;externalAwhExternalId;awhFirstName;awhLastName;awhRolePureId; awhRoleUri; awhRole_term_text_ca_ES;awhRole_term_text_en_GB;awhRole_term_text_es_ES;startDate;endDate;PRCPercentage".split(";"),
    'awards-fundings': "uuid;fundingPureId;fundingExternalId;funder_uuid;fundingClassification_uri;fundingProjectScheme;financial;awardedAmount;institutionalPart;visibility".split(";"),
    'awards-ids': "uuid;text_ca_ES;text_en_GB;text_es_ES;idPureId;idValue;idTypePureId;idTypeUri;idType_term_text_ca_ES;idType_term_text_en_GB;idType_term_text_es_ES".split(";"),
    'awards-collaborators': "awardUuid;awardText_ca_ES;awardText_en_GB;awardText_es_ES;colPureId;colTypePureId;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;leadCollaborator;orgUuid;org_name_ca_ES;org_name_en_GB;org_name_es_ES;orgTypePureId;org_type_ca_ES;org_type_en_GB;org_type_es_ES".split(";"),
    'awards-natureTypes': "uuid;text_ca_ES;text_en_GB;text_es_ES;natureTypePureid;natureTypeUri;natureType_term_text_ca_ES;natureType_term_text_en_GB;natureType_term_text_es_ES".split(";"),
    'awards-budget-periodes': "awardUuid;periodeUri;inici_es;fi_es;inici_ca;fi_ca;inici_en;fi_en".split(";"),
    'awards-accounts': "awarduuId;fundingPureId; budgetPureId;budgetExternalId;costCode;classificationPureId;classificationUri;yearlyBugdetExternalId;year;budget".split(";"),
    'awards-budgetAndExpenditures': "awardUuid;fundingPureId; budgetPureId;budgetExternalId;costCode".split(";"),
    'awards-co-managers': "awuuid;awtext_ca_ES;awtext_en_GB;awtext_es_ES;cmuuid;cmexternalId;cmname_ca_ES;cmname_en_GB;cmname_es_ES;cmtype_pureId;cmtype_ca_ES".split(";"),
    'awards-estat': "uuid;externalId;text_ca_ES;text_en_GB;text_es_ES;estatId;estat_term_text_ca_ES;estat_term_text_en_GB;estat_term_text_es_ES;internallyApprovedDate;relinquished;relinquishmentDate;relinquishmentReason;declined;declinationDate;declinedReason".split(";"),
    'awards-fundings-collaborators': "uuid;fcFundingPureId; fcFunder_uuid;fcName_text_ca_ES;fcName_text_en_GB;fcName_text_es_ES;colType_term_text_ca_ES;colType_term_text_en_GB;colType_term_text_es_ES;fcInstitutionalPart".split(";"),
    'awards-relatedApplications': "uuid; text_ca_ES; text_en_GB; text_es_ES; relappUuid; relappExternalId; relapp_text_ca_ES; relapp_term_text_en_GB; relapp_term_text_es_ES; relappTyePureId; relappTypeUri; relapp_type_text_ca_ES; relapp_type_term_text_en_GB; relapp_type_term_text_es_ES".split(";")
}

def extract_title(item):
    t = item.get("title", {})
    return t.get("ca_ES", ""), t.get("en_GB", ""), t.get("es_ES", "")

def process_awards_data(in_path, out_dir):
    print("Carregant JSON...")
    with open(in_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Diccionari per anar guardant totes les files de cada CSV
    tables = {name: [] for name in CSV_HEADERS.keys()}

    print("Processant items...")
    for item in data.get("items", []):
        uuid = item.get("uuid")
        t_ca, t_en, t_es = extract_title(item)
        
        # --- AWARDS ---
        mou = item.get("managingOrganization", {})
        type_info = item.get("type", {})
        status = item.get("statusDetails", {})
        
        tables['awards'].append({
            "uuid": uuid, "text_ca_ES": t_ca, "text_en_GB": t_en, "text_es_ES": t_es,
            "typePureId": type_info.get("pureId"), "typeUri": type_info.get("uri"),
            "type_term_text_ca_ES": type_info.get("term", {}).get("ca_ES"),
            "type_term_text_en_GB": type_info.get("term", {}).get("en_GB"),
            "type_term_text_es_ES": type_info.get("term", {}).get("es_ES"),
            "managingOrganisationalUnit_Uuid": mou.get("uuid"),
            "managingOrganisationalUnit_ExternaId": mou.get("externalId"),
            "MOU_name_text_ca_ES": mou.get("name", {}).get("ca_ES"),
            "MOU_name_text_en_GB": mou.get("name", {}).get("en_GB"),
            "MOU_name_text_es_ES": mou.get("name", {}).get("es_ES"),
            "awardDate": item.get("awardDate"),
            "estatId": item.get("status", {}).get("pureId"),
            "pureId": item.get("pureId"),
        })
        
        # --- ESTAT ---
        tables['awards-estat'].append({
            "uuid": uuid, "externalId": item.get("externalId"),
            "text_ca_ES": t_ca, "text_en_GB": t_en, "text_es_ES": t_es,
            "estatId": status.get("status", {}).get("key"),
            "estat_term_text_ca_ES": status.get("status", {}).get("value", {}).get("ca_ES"),
            "estat_term_text_en_GB": status.get("status", {}).get("value", {}).get("en_GB"),
            "estat_term_text_es_ES": status.get("status", {}).get("value", {}).get("es_ES"),
            "internallyApprovedDate": status.get("internallyApprovedDate"),
            "relinquished": status.get("relinquished"),
            "relinquishmentDate": status.get("relinquishmentDate"),
            "relinquishmentReason": status.get("relinquishmentReason"),
            "declined": status.get("declined"),
            "declinationDate": status.get("declinationDate"),
            "declinedReason": status.get("declinedReason")
        })

        # --- HOLDERS ---
        for h in item.get("awardHolders", []):
            role = h.get("role", {})
            tables['awards-holders'].append({
                "uuid": uuid, "text_ca_ES": t_ca, "text_en_GB": t_en, "text_es_ES": t_es,
                "awhUuid": h.get("person", {}).get("uuid"),
                "awhFirstName": h.get("name", {}).get("firstName"),
                "awhLastName": h.get("name", {}).get("lastName"),
                "awhRolePureId": role.get("pureId"),
                " awhRoleUri": role.get("uri"),
                " awhRole_term_text_ca_ES": role.get("term", {}).get("ca_ES"),
                "awhRole_term_text_en_GB": role.get("term", {}).get("en_GB"),
                "awhRole_term_text_es_ES": role.get("term", {}).get("es_ES"),
                "PRCPercentage": h.get("plannedResearcherCommitmentPercentage")
            })

        # --- IDENTIFIERS ---
        for ident in item.get("identifiers", []):
            itype = ident.get("type", {})
            tables['awards-ids'].append({
                "uuid": uuid, "text_ca_ES": t_ca, "text_en_GB": t_en, "text_es_ES": t_es,
                "idPureId": ident.get("pureId"),
                "idValue": ident.get("value", ident.get("id")),
                "idTypePureId": itype.get("pureId"), "idTypeUri": itype.get("uri"),
                "idType_term_text_ca_ES": itype.get("term", {}).get("ca_ES"),
                "idType_term_text_en_GB": itype.get("term", {}).get("en_GB"),
                "idType_term_text_es_ES": itype.get("term", {}).get("es_ES")
            })

        # --- COLLABORATORS ---
        for col in item.get("collaborators", []):
            tables['awards-collaborators'].append({
                "awardUuid": uuid, "awardText_ca_ES": t_ca, "awardText_en_GB": t_en, "awardText_es_ES": t_es,
                "colPureId": col.get("pureId"), "leadCollaborator": col.get("leadCollaborator"),
                "orgUuid": col.get("externalOrganization", {}).get("uuid")
            })

        # --- CO-MANAGERS ---
        for cm in item.get("coManagingOrganisationalUnits", []):
            tables['awards-co-managers'].append({
                "awuuid": uuid, "awtext_ca_ES": t_ca, "awtext_en_GB": t_en, "awtext_es_ES": t_es,
                "cmuuid": cm.get("uuid"), "cmexternalId": cm.get("externalId"),
                "cmname_ca_ES": cm.get("name", {}).get("ca_ES"), "cmname_en_GB": cm.get("name", {}).get("en_GB"), "cmname_es_ES": cm.get("name", {}).get("es_ES"),
                "cmtype_pureId": cm.get("type", {}).get("pureId"), "cmtype_ca_ES": cm.get("type", {}).get("term", {}).get("ca_ES")
            })

        # --- NATURE TYPES ---
        nt_data = item.get("natureTypes", [])
        if isinstance(nt_data, dict): nt_data = nt_data.get("natureType", [])
        for nt in nt_data:
            term = nt.get("term", {})
            text = term.get("text", term) # Gestió de l'estructura variable (str o dict)
            tables['awards-natureTypes'].append({
                "uuid": uuid, "text_ca_ES": t_ca, "text_en_GB": t_en, "text_es_ES": t_es,
                "natureTypePureid": nt.get("pureId"), "natureTypeUri": nt.get("uri"),
                "natureType_term_text_ca_ES": text.get("ca_ES") if isinstance(text, dict) else term.get("ca_ES"),
                "natureType_term_text_en_GB": text.get("en_GB") if isinstance(text, dict) else term.get("en_GB"),
                "natureType_term_text_es_ES": text.get("es_ES") if isinstance(text, dict) else term.get("es_ES")
            })

        # --- RELATED APPLICATIONS ---
        for ra in item.get("relatedApplications", {}).get("relatedApplication", []):
            tables['awards-relatedApplications'].append({
                "uuid": uuid, " text_ca_ES": t_ca, " text_en_GB": t_en, " text_es_ES": t_es,
                " relappUuid": ra.get("uuid"), " relappExternalId": ra.get("externalId"),
                " relapp_text_ca_ES": ra.get("name", {}).get("ca_ES"), " relapp_term_text_en_GB": ra.get("name", {}).get("en_GB"), " relapp_term_text_es_ES": ra.get("name", {}).get("es_ES"),
                " relappTyePureId": ra.get("type", {}).get("pureId"), " relappTypeUri": ra.get("type", {}).get("uri"),
                " relapp_type_text_ca_ES": ra.get("type", {}).get("term", {}).get("ca_ES"), " relapp_type_term_text_en_GB": ra.get("type", {}).get("term", {}).get("en_GB"), " relapp_type_term_text_es_ES": ra.get("type", {}).get("term", {}).get("es_ES")
            })

        # --- FUNDINGS & ACCOUNTS ---
        for f in item.get("fundings", []):
            f_pure_id = f.get("pureId")
            tables['awards-fundings'].append({
                "uuid": uuid, "fundingPureId": f_pure_id, "fundingExternalId": f.get("externalId"),
                "funder_uuid": f.get("funder", {}).get("uuid"), "fundingClassification_uri": f.get("classification", {}).get("uri"),
                "fundingProjectScheme": f.get("fundingProjectScheme"), "awardedAmount": f.get("awardedAmount", {}).get("value"),
                "institutionalPart": f.get("institutionalPart"), "visibility": f.get("visibility", {}).get("key")
            })
            
            for fc in f.get("fundingCollaborator", []):
                col = fc.get("collaborator", {})
                tables['awards-fundings-collaborators'].append({
                    "uuid": uuid, "fcFundingPureId": f_pure_id, " fcFunder_uuid": col.get("uuid"),
                    "fcName_text_ca_ES": col.get("name", {}).get("ca_ES"), "fcName_text_en_GB": col.get("name", {}).get("en_GB"), "fcName_text_es_ES": col.get("name", {}).get("es_ES"),
                    "colType_term_text_ca_ES": col.get("type", {}).get("term", {}).get("ca_ES"), "colType_term_text_en_GB": col.get("type", {}).get("term", {}).get("en_GB"), "colType_term_text_es_ES": col.get("type", {}).get("term", {}).get("es_ES"),
                    "fcInstitutionalPart": fc.get("institutionalPart")
                })

            for b in f.get("budgetAndExpenditures", []):
                b_pure_id, b_ext_id, cost_code = b.get("pureId"), b.get("externalId"), b.get("costCode")
                tables['awards-budgetAndExpenditures'].append({
                    "awardUuid": uuid, "fundingPureId": f_pure_id, " budgetPureId": b_pure_id,
                    "budgetExternalId": b_ext_id, "costCode": cost_code
                })
                
                for acc in b.get("accounts", []):
                    c_pure_id = acc.get("classification", {}).get("pureId")
                    c_uri = acc.get("classification", {}).get("uri")
                    for yb in acc.get("yearlyBudgets", []):
                        tables['awards-accounts'].append({
                            "awarduuId": uuid, "fundingPureId": f_pure_id, " budgetPureId": b_pure_id,
                            "budgetExternalId": b_ext_id, "costCode": cost_code,
                            "classificationPureId": c_pure_id, "classificationUri": c_uri,
                            "yearlyBugdetExternalId": yb.get("externalId"), "year": yb.get("year"), "budget": yb.get("budget")
                        })

        # --- BUDGET PERIODES ---
        for kc in item.get("keywordContainers", []):
            if "structuredKeyword" in kc:
                row = {"awardUuid": uuid, "periodeUri": kc.get("structuredKeyword", {}).get("uri")}
                for fk_locale in kc.get("freeKeywords", {}).get("freeKeywords", []):
                    loc, fk_list = fk_locale.get("locale"), fk_locale.get("freeKeywords", [])
                    if loc in ["es_ES", "ca_ES", "en_GB"]:
                        prefix = loc[:2] # 'es', 'ca', o 'en'
                        row[f"inici_{prefix}"] = fk_list[0] if len(fk_list) > 0 else ""
                        row[f"fi_{prefix}"] = fk_list[1] if len(fk_list) > 1 else ""
                tables['awards-budget-periodes'].append(row)

    # --- GENERACIÓ DE CSV AMB PANDAS ---
    print("Guardant els arxius CSV...")
    os.makedirs(out_dir, exist_ok=True)
    
    for name, cols in CSV_HEADERS.items():
        # Creem el DataFrame. Si la llista està buida, tindrà 0 files
        df = pd.DataFrame(tables[name])
        
        # MAGIA PANDAS: 'reindex' assegura que tenim EXACTAMENT les columnes de `cols`. 
        # Les columnes demanades que no existeixen (ex. 'SN_collaborative') es creen i queden buides (NaN).
        df = df.reindex(columns=cols)
        
        # Omplim els valors NaN/Nulls amb strings buits "" per estètica del CSV
        df = df.fillna("")
        
        # Exportem a CSV de forma extremadament neta
        csv_path = os.path.join(out_dir, f"{name}.csv")
        df.to_csv(csv_path, sep=';', index=False, encoding='utf-8')

    print(f"Procés finalitzat. S'han guardat {len(CSV_HEADERS)} arxius a '{out_dir}'.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generador optimitzat de CSV utilitzant Pandas")
    parser.add_argument('-i', '--input', required=True, help="Ruta de l'arxiu JSON")
    parser.add_argument('-o', '--outdir', required=True, help="Directori on es desaran els CSV")
    
    args = parser.parse_args()
    
    process_awards_data(args.input, args.outdir)
