import json
import csv
import urllib.request
import os
import shutil

#Requisits to run
#secrets.json

def load_secrets(path):

    if not os.path.exists(path):
        raise FileNotFoundError('Secret file not found')

    with open(path, 'r') as f:
        #Mirar si això funciona
        secrets = json.load(f)
        for key,value in secrets.items():
            os.environ[key.strip()] = value.strip()

def api_request(url, header, method, out_path):

    #We use shutil to mitigate MemoryError due to memory being full because of huge petitions

    request = urllib.request.Request(url, headers=header, method=str(method))

    try:
        with urllib.request.urlopen(request) as response:

            with open(out_path, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)

            print('File correctly saved')
            return True
    except urllib.error.HTTPError as e:
        print(f'HTTP error: \n {e}')
    except urllib.error.URLError as e:
        print(f'URL error: \n {e}')
    except Exception as e:
        print(f'Error while making the API request, Error: \n {e}')

    return False

class awards_object():

    def __init__(self, out_path):
        self.json_file_path = out_path

    def load_json(self):
        with open(self.json_file_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    #Get main Information
    def get_awards(self, data):
        # Get award holders
        # És possible que faltin camps

# --------------------------------------------------------------------------------------------- #
        # Get award holders
        def get_awards_holders(item):
            all_holders_rows = []
            #Pot ser que no faci falta iterar cada vegada per tots els items, safety mesure
            holders = item.get("awardHolders", [])

            for h in holders:
                name_info = h.get("name", {})
                role_info = h.get("role", {})
                term_info = role_info.get("term", {})
                person_info = h.get("person", {})

                # Creem un diccionari pla per a cada holder
                holder_row = {
                    "typeDiscriminator": h.get("typeDiscriminator"),
                    "pureId": h.get("pureId"),
                    "academicOwnershipPercentage": h.get("academicOwnershipPercentage"),
                    "plannedResearcherCommitmentPercentage": h.get("plannedResearcherCommitmentPercentage"),
                    "firstName": name_info.get("firstName"),
                    "lastName": name_info.get("lastName"),
                    "role_uri": role_info.get("uri"),
                    "role_en": term_info.get("en_GB"),
                    "role_es": term_info.get("es_ES"),
                    "role_ca": term_info.get("ca_ES"),
                    "person_uuid": person_info.get("uuid"),
                    "person_systemName": person_info.get("systemName")
                }
                all_holders_rows.append(holder_row)

            return all_holders_rows

# --------------------------------------------------------------------------------------------- #
        # Get award fundings
        # És possible que faltin camps
        def get_awards_fundings(item):
            rows = []
            fundings = item.get("fundings", [])

            for f in fundings:
                row = {
                    "funding_pureId": f.get("pureId"),
                    "funder_uuid": f.get("funder", {}).get("uuid"),
                    "fundingProjectScheme": f.get("fundingProjectScheme"),
                    "currency": f.get("awardedAmount", {}).get("currency"),
                    "amount_value": f.get("awardedAmount", {}).get("value"),
                    "visibility_key": f.get("visibility", {}).get("key"),
                    "visibility_description_en_GB": f.get("visibility", {}).get("description").get("en_GB"),
                    "visibility_description_es_ES": f.get("visibility", {}).get("description").get("es_ES"),
                    "visibility_description_ca_ES": f.get("visibility", {}).get("description").get("ca_ES")
                }
                rows.append(row)

            return rows

# --------------------------------------------------------------------------------------------- #
        # Get award identifiers
        def get_awards_identifiers(item):
            rows = []

            identifiers = item.get("identifiers", [])

            for ident in identifiers:
                row = {
                    "typeDiscriminator": ident.get("typeDiscriminator"),
                    "pureId": ident.get("pureId"),
                    "id_value": ident.get("value") if "value" in ident else ident.get("id"),
                    "idSource": ident.get("idSource"),
                    "type_uri": ident.get("type", {}).get("uri"),
                    "type_term_gb": ident.get("type", {}).get("term", {}).get("en_GB"),
                    "type_term_es": ident.get("type", {}).get("term", {}).get("es_ES"),
                    "type_term_ca": ident.get("type", {}).get("term", {}).get("ca_ES")
                }
                rows.append(row)

            return rows
# --------------------------------------------------------------------------------------------- #
        #Get awards collaborators
        def get_awards_collaborators(item):
            rows = []
            collaborators = item.get("collaborators", [])

            for col in collaborators:
                row = {
                    "collab_pureId": col.get("pureId"),
                    "typeDiscriminator": col.get("typeDiscriminator"),
                    "is_lead": col.get("leadCollaborator"),
                    "ext_org_uuid": col.get("externalOrganization", {}).get("uuid"),
                    "ext_org_system": col.get("externalOrganization", {}).get("systemName")
                }
                rows.append(row)

            return rows
# --------------------------------------------------------------------------------------------- #
        # Get award descriptions
        def get_awards_descriptions(item):
            rows = []
            descriptions = item.get("descriptions", [])

            for desc in descriptions:
                # Extraiem el text de la descripció (si n'hi ha) i els termes del tipus
                term_info = desc.get("type", {}).get("term", {})

                row = {
                    "desc_pureId": desc.get("pureId"),
                    "type_uri": desc.get("type", {}).get("uri"),
                    "type_ca": term_info.get("ca_ES"),
                    "type_es": term_info.get("es_ES"),
                    "type_en": term_info.get("en_GB"),
                    # En alguns endpoints de Pure, el contingut real està a 'value' o 'text'
                    "content": desc.get("value") if "value" in desc else desc.get("text", "")
                }
                rows.append(row)

            return rows
# ---------------------------------------------------------------------------------------------#
        # Get all items
        items = data["items"]
        rows = []

        #For each item, extract all the data
        for item in items:
            # Extraiem dades de períodes
            actual = item.get("actualPeriod", {})
            expected = item.get("expectedPeriod", {})

            # Extraiem dades multilingües (títols i tipus)
            title_info = item.get("title", {})
            type_info = item.get("type", {}).get("term", {})
            workflow_info = item.get("workflow", {})
            visibility_info = item.get("visibility", {})

            holders = get_awards_holders(item)
            fundings = get_awards_fundings(item)
            identifiers = get_awards_identifiers(item)
            collaborators = get_awards_collaborators(item)
            descriptions = get_awards_descriptions(item)

            row = {
                "pureId": item.get("pureId"),
                "uuid": item.get("uuid"),
                "typeDiscriminator": item.get("typeDiscriminator"),
                "systemName": item.get("systemName"),
                "title_ca": title_info.get("ca_ES"),
                "title_es": title_info.get("es_ES"),
                "title_en": title_info.get("en_GB"),
                "awardDate": item.get("awardDate"),
                "actual_startDate": actual.get("startDate"),
                "actual_endDate": actual.get("endDate"),
                "expected_startDate": expected.get("startDate"),
                "expected_endDate": expected.get("endDate"),
                "createdBy": item.get("createdBy"),
                "createdDate": item.get("createdDate"),
                "modifiedBy": item.get("modifiedBy"),
                "modifiedDate": item.get("modifiedDate"),
                "version": item.get("version"),
                "workflow_step": workflow_info.get("step"),
                "workflow_ca": workflow_info.get("description", {}).get("ca_ES"),
                "visibility_key": visibility_info.get("key"),
                "award_type_ca": type_info.get("ca_ES"),
                "holders": holders,
                "fundings": fundings,
                "identifiers": identifiers,
                "collaborators": collaborators,
                "descriptions": descriptions,
            }
            rows.append(row)

        return rows


    def json_csv(out_path, ):

        #Maybe this has to change to chunk loading due to file size
        #To be defined

        return 0

if __name__ ==  "__main__":

    #Variables
    base_path = str(os.path.abspath(os.getcwd()))
    secrets_filepath = base_path + f'/secrets.json'
    out_path = base_path + f'/awards_petition.json'
    size = 10
    content_type = 'application/json'
    accept_charset = 'UTF-8'
    method = 'GET'

    load_secrets(secrets_filepath)

    api_url = os.getenv('API_URL')
    api_key = os.getenv("API_KEY")

    if api_url is None or api_key is None:
        raise Exception('API URL and API key are missing')

    headers = {
        "api-key": api_key,
        "Content-Type": content_type,
        "Accept-Charset": accept_charset,
        "size": size
    }

    json_data = api_request(api_url, headers, method, out_path)

    if json_data:
        json_object = awards_object(out_path)
        data = json_object.load_json()
        json_object.get_awards(data)
    else:
        print('Failure during JSON load')
