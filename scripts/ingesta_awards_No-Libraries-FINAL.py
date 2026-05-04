import json
import csv
import os
import argparse

class awards_object():
    def __init__(self, in_path, out_dir):
        self.json_file_path = in_path
        self.out_dir = out_dir
        
        # Mapping CSV filenames to exact headers based on XSLT <xsl:text> values
        self.csv_headers = {
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

    def _get_title(self, item):
        title = item.get("title", {})
        return {
            "ca": title.get("ca_ES", ""),
            "en": title.get("en_GB", ""),
            "es": title.get("es_ES", "")
        }

    def parse_awards(self, item):
        title = self._get_title(item)
        type_info = item.get("type", {})
        mou = item.get("managingOrganization", {})  # renamed from managingOrganisationalUnit
        return [{
            "uuid": item.get("uuid"),
            "text_ca_ES": title["ca"],
            "text_en_GB": title["en"],
            "text_es_ES": title["es"],
            "typePureId": type_info.get("pureId"),
            "typeUri": type_info.get("uri"),
            "type_term_text_ca_ES": type_info.get("term", {}).get("ca_ES"),
            "type_term_text_en_GB": type_info.get("term", {}).get("en_GB"),
            "type_term_text_es_ES": type_info.get("term", {}).get("es_ES"),
            "managingOrganisationalUnit_Uuid": mou.get("uuid"),
            "managingOrganisationalUnit_ExternaId": mou.get("externalId", ""),
            "MOU_name_text_ca_ES": mou.get("name", {}).get("ca_ES", ""),
            "MOU_name_text_en_GB": mou.get("name", {}).get("en_GB", ""),
            "MOU_name_text_es_ES": mou.get("name", {}).get("es_ES", ""),
            "SN_collaborative": item.get("collaborative", ""), # Missing in JSON
            "totalAwardedAmount": item.get("totalAwardedAmount", {}).get("value", ""), # Missing in JSON
            "totalSpendAmount": item.get("totalSpendAmount", {}).get("value", ""), # Missing in JSON
            "awardDate": item.get("awardDate"),
            "estatId": item.get("status", {}).get("pureId", ""),
            "pureId": item.get("pureId"),
            "createdDate": item.get("info", {}).get("createdDate"),
            "mofifiedDate": item.get("info", {}).get("modifiedDate"),
            "recompte": "",
            "justificacioEconomica": ""
        }]

    def parse_holders(self, item):
        rows = []
        title = self._get_title(item)
        for h in item.get("awardHolders", []):
            person = h.get("person", {})
            rows.append({
                "uuid": item.get("uuid"),
                "text_ca_ES": title["ca"],
                "text_en_GB": title["en"],
                "text_es_ES": title["es"],
                "awhUuid": person.get("uuid"),
                "awhFirstName": h.get("name", {}).get("firstName"),
                "awhLastName": h.get("name", {}).get("lastName"),
                "awhRolePureId": h.get("role", {}).get("pureId"),
                " awhRoleUri": h.get("role", {}).get("uri"),
                " awhRole_term_text_ca_ES": h.get("role", {}).get("term", {}).get("ca_ES"),
                "awhRole_term_text_en_GB": h.get("role", {}).get("term", {}).get("en_GB"),
                "awhRole_term_text_es_ES": h.get("role", {}).get("term", {}).get("es_ES"),
                "PRCPercentage": h.get("plannedResearcherCommitmentPercentage")
            })
        return rows

    def parse_fundings(self, item):
        rows = []
        for f in item.get("fundings", []):
            rows.append({
                "uuid": item.get("uuid"),
                "fundingPureId": f.get("pureId"),
                "fundingExternalId": f.get("externalId", ""),
                "funder_uuid": f.get("funder", {}).get("uuid", ""),
                "fundingClassification_uri": f.get("classification", {}).get("uri", ""),
                "fundingProjectScheme": f.get("fundingProjectScheme", ""),
                "financial": f.get("financial", ""), # Missing in JSON
                "awardedAmount": f.get("awardedAmount", {}).get("value", ""),
                "institutionalPart": f.get("institutionalPart", ""),
                "visibility": f.get("visibility", {}).get("key", "")
            })
        return rows

    def parse_identifiers(self, item):
        rows = []
        title = self._get_title(item)
        for ident in item.get("identifiers", []):
            rows.append({
                "uuid": item.get("uuid"),
                "text_ca_ES": title["ca"],
                "text_en_GB": title["en"],
                "text_es_ES": title["es"],
                "idPureId": ident.get("pureId", ""),
                "idValue": ident.get("value", "") if "value" in ident else ident.get("id", ""),
                "idTypePureId": ident.get("type", {}).get("pureId", ""), # Missing in JSON
                "idTypeUri": ident.get("type", {}).get("uri", ""),
                "idType_term_text_ca_ES": ident.get("type", {}).get("term", {}).get("ca_ES", ""),
                "idType_term_text_en_GB": ident.get("type", {}).get("term", {}).get("en_GB", ""),
                "idType_term_text_es_ES": ident.get("type", {}).get("term", {}).get("es_ES", "")
            })
        return rows

    def parse_collaborators(self, item):
        rows = []
        title = self._get_title(item)
        for col in item.get("collaborators", []):
            rows.append({
                "awardUuid": item.get("uuid"),
                "awardText_ca_ES": title["ca"],
                "awardText_en_GB": title["en"],
                "awardText_es_ES": title["es"],
                "colPureId": col.get("pureId"),
                "leadCollaborator": col.get("leadCollaborator"),
                "orgUuid": col.get("externalOrganization", {}).get("uuid")
            })
        return rows

    def parse_budget_periodes(self, item):
        rows = []
        # awardUuid;periodeUri;inici_es;fi_es;inici_ca;fi_ca;inici_en;fi_en
        for kc in item.get("keywordContainers", []):
            if "structuredKeyword" in kc:
                row = {
                    "awardUuid": item.get("uuid"),
                    "periodeUri": kc.get("structuredKeyword", {}).get("uri")
                }
                for fk_locale in kc.get("freeKeywords", {}).get("freeKeywords", []):
                    locale = fk_locale.get("locale")
                    fk_list = fk_locale.get("freeKeywords", [])
                    if locale == "es_ES":
                        row["inici_es"] = fk_list[0] if len(fk_list) > 0 else ""
                        row["fi_es"] = fk_list[1] if len(fk_list) > 1 else ""
                    elif locale == "ca_ES":
                        row["inici_ca"] = fk_list[0] if len(fk_list) > 0 else ""
                        row["fi_ca"] = fk_list[1] if len(fk_list) > 1 else ""
                    elif locale == "en_GB":
                        row["inici_en"] = fk_list[0] if len(fk_list) > 0 else ""
                        row["fi_en"] = fk_list[1] if len(fk_list) > 1 else ""
                rows.append(row)
        return rows

    def parse_accounts(self, item):
        rows = []
        for funding in item.get("fundings", []):
            for budget in funding.get("budgetAndExpenditures", []):
                for acc in budget.get("accounts", []):
                    for yb in acc.get("yearlyBudgets", []):
                        rows.append({
                            "awarduuId": item.get("uuid"),
                            "fundingPureId": funding.get("pureId"),
                            " budgetPureId": budget.get("pureId"),
                            "budgetExternalId": budget.get("externalId"),
                            "costCode": budget.get("costCode"),
                            "classificationPureId": acc.get("classification", {}).get("pureId"),
                            "classificationUri": acc.get("classification", {}).get("uri"),
                            "yearlyBugdetExternalId": yb.get("externalId"),
                            "year": yb.get("year"),
                            "budget": yb.get("budget")
                        })
        return rows

    def parse_budgetAndExpenditures(self, item):
        rows = []
        for funding in item.get("fundings", []):
            for budget in funding.get("budgetAndExpenditures", []):
                rows.append({
                    "awardUuid": item.get("uuid"),
                    "fundingPureId": funding.get("pureId"),
                    " budgetPureId": budget.get("pureId"),
                    "budgetExternalId": budget.get("externalId"),
                    "costCode": budget.get("costCode")
                })
        return rows

    def parse_co_managers(self, item):
        rows = []
        title = self._get_title(item)
        for cm in item.get("coManagingOrganisationalUnits", []):
            rows.append({
                "awuuid": item.get("uuid"),
                "awtext_ca_ES": title["ca"],
                "awtext_en_GB": title["en"],
                "awtext_es_ES": title["es"],
                "cmuuid": cm.get("uuid"),
                "cmexternalId": cm.get("externalId"),
                "cmname_ca_ES": cm.get("name", {}).get("ca_ES"),
                "cmname_en_GB": cm.get("name", {}).get("en_GB"),
                "cmname_es_ES": cm.get("name", {}).get("es_ES"),
                "cmtype_pureId": cm.get("type", {}).get("pureId"),
                "cmtype_ca_ES": cm.get("type", {}).get("term", {}).get("ca_ES")
            })
        return rows

    def parse_estat(self, item):
        title = self._get_title(item)
        sd = item.get("statusDetails", {})
        return [{
            "uuid": item.get("uuid"),
            "externalId": item.get("externalId"),
            "text_ca_ES": title["ca"],
            "text_en_GB": title["en"],
            "text_es_ES": title["es"],
            "estatId": sd.get("status", {}).get("key"),
            "estat_term_text_ca_ES": sd.get("status", {}).get("value", {}).get("ca_ES"),
            "estat_term_text_en_GB": sd.get("status", {}).get("value", {}).get("en_GB"),
            "estat_term_text_es_ES": sd.get("status", {}).get("value", {}).get("es_ES"),
            "internallyApprovedDate": sd.get("internallyApprovedDate"),
            "relinquished": sd.get("relinquished"),
            "relinquishmentDate": sd.get("relinquishmentDate"),
            "relinquishmentReason": sd.get("relinquishmentReason"),
            "declined": sd.get("declined"),
            "declinationDate": sd.get("declinationDate"),
            "declinedReason": sd.get("declinedReason")
        }]

    def parse_fundings_collaborators(self, item):
        rows = []
        for f in item.get("fundings", []):
            for fc in f.get("fundingCollaborator", []):
                col = fc.get("collaborator", {})
                rows.append({
                    "uuid": item.get("uuid"),
                    "fcFundingPureId": f.get("pureId"),
                    " fcFunder_uuid": col.get("uuid"),
                    "fcName_text_ca_ES": col.get("name", {}).get("ca_ES"),
                    "fcName_text_en_GB": col.get("name", {}).get("en_GB"),
                    "fcName_text_es_ES": col.get("name", {}).get("es_ES"),
                    "colType_term_text_ca_ES": col.get("type", {}).get("term", {}).get("ca_ES"),
                    "colType_term_text_en_GB": col.get("type", {}).get("term", {}).get("en_GB"),
                    "colType_term_text_es_ES": col.get("type", {}).get("term", {}).get("es_ES"),
                    "fcInstitutionalPart": fc.get("institutionalPart")
                })
        return rows

    def parse_natureTypes(self, item):
        rows = []
        title = self._get_title(item)
        nature_types = item.get("natureTypes", [])
        if isinstance(nature_types, dict):
            nature_types = nature_types.get("natureType", [])
            
        for nt in nature_types: 
            rows.append({
                "uuid": item.get("uuid"),
                "text_ca_ES": title["ca"],
                "text_en_GB": title["en"],
                "text_es_ES": title["es"],
                "natureTypePureid": nt.get("pureId", ""),
                "natureTypeUri": nt.get("uri", ""),
                "natureType_term_text_ca_ES": nt.get("term", {}).get("text", {}).get("ca_ES", "") if isinstance(nt.get("term", {}).get("text"), dict) else nt.get("term", {}).get("ca_ES", ""),
                "natureType_term_text_en_GB": nt.get("term", {}).get("text", {}).get("en_GB", "") if isinstance(nt.get("term", {}).get("text"), dict) else nt.get("term", {}).get("en_GB", ""),
                "natureType_term_text_es_ES": nt.get("term", {}).get("text", {}).get("es_ES", "") if isinstance(nt.get("term", {}).get("text"), dict) else nt.get("term", {}).get("es_ES", "")
            })
        return rows

    def parse_relatedApplications(self, item):
        rows = []
        title = self._get_title(item)
        for ra in item.get("relatedApplications", {}).get("relatedApplication", []):
            rows.append({
                "uuid": item.get("uuid"),
                " text_ca_ES": title["ca"],
                " text_en_GB": title["en"],
                " text_es_ES": title["es"],
                " relappUuid": ra.get("uuid"),
                " relappExternalId": ra.get("externalId"),
                " relapp_text_ca_ES": ra.get("name", {}).get("ca_ES"),
                " relapp_term_text_en_GB": ra.get("name", {}).get("en_GB"),
                " relapp_term_text_es_ES": ra.get("name", {}).get("es_ES"),
                " relappTyePureId": ra.get("type", {}).get("pureId"),
                " relappTypeUri": ra.get("type", {}).get("uri"),
                " relapp_type_text_ca_ES": ra.get("type", {}).get("term", {}).get("ca_ES"),
                " relapp_type_term_text_en_GB": ra.get("type", {}).get("term", {}).get("en_GB"),
                " relapp_type_term_text_es_ES": ra.get("type", {}).get("term", {}).get("es_ES")
            })
        return rows

    def process_and_write(self):
        # Obrim tots els fitxers en mode escriptura ("w") i configurem els dictwriters
        writers = {}
        files = {}
        os.makedirs(self.out_dir, exist_ok=True)
        
        try:
            for name, header in self.csv_headers.items():
                f = open(os.path.join(self.out_dir, f"{name}.csv"), 'w', newline='', encoding='utf-8')
                files[name] = f
                writer = csv.DictWriter(f, fieldnames=header, delimiter=';', extrasaction='ignore')
                writer.writeheader()
                writers[name] = writer

            # Llegim el JSON gran
            print("Carregant JSON...")
            with open(self.json_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            print("Processant items...")
            for item in data.get("items", []):
                # Extraure i escriure dades usant funcions parsejadores
                
                # Awards
                for row in self.parse_awards(item):
                    writers['awards'].writerow(row)
                    
                # Holders
                for row in self.parse_holders(item):
                    writers['awards-holders'].writerow(row)
                    
                # Fundings
                for row in self.parse_fundings(item):
                    writers['awards-fundings'].writerow(row)
                    
                # Identifiers
                for row in self.parse_identifiers(item):
                    writers['awards-ids'].writerow(row)
                    
                # Collaborators
                for row in self.parse_collaborators(item):
                    writers['awards-collaborators'].writerow(row)
                    
                # Budget periodes
                for row in self.parse_budget_periodes(item):
                    writers['awards-budget-periodes'].writerow(row)

                # Accounts
                for row in self.parse_accounts(item):
                    writers['awards-accounts'].writerow(row)

                # Budget And Expenditures
                for row in self.parse_budgetAndExpenditures(item):
                    writers['awards-budgetAndExpenditures'].writerow(row)

                # Co-managers
                for row in self.parse_co_managers(item):
                    writers['awards-co-managers'].writerow(row)

                # Estat
                for row in self.parse_estat(item):
                    writers['awards-estat'].writerow(row)

                # Fundings Collaborators
                for row in self.parse_fundings_collaborators(item):
                    writers['awards-fundings-collaborators'].writerow(row)

                # Nature Types
                for row in self.parse_natureTypes(item):
                    writers['awards-natureTypes'].writerow(row)

                # Related Applications
                for row in self.parse_relatedApplications(item):
                    writers['awards-relatedApplications'].writerow(row)

            print("Completat amb èxit. Fitxers CSV generats.")

        finally:
            # Assegurar-se de tancar tots els arxius oberts
            for f in files.values():
                f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse awards JSON and generate CSV files equivalent to XSLT templates.")
    parser.add_argument('-i', '--input', required=True, help="Ruta de l'arxiu JSON d'entrada (ex. /path/to/awards.json)")
    parser.add_argument('-o', '--outdir', required=True, help="Directori on es desaran els CSV resultants (ex. /path/to/csv_outputs)")
    
    args = parser.parse_args()

    try:
        json_object = awards_object(args.input, args.outdir)
        json_object.process_and_write()
    except Exception as e:
        print(f"S'ha produït un error: {e}")
