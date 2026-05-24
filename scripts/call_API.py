import urllib.request
import urllib.error
import json
import os
import argparse
from urllib.parse import urlencode

def call_API(url: str, output: str, name: str, api_key: str) -> dict:
    #Check directory exists
    os.makedirs(output, exist_ok=True)
    path = os.path.join(output, name)
    #Headers
    headers = {"Content-Type": "application/json", "Accept-Charset": "UTF-8","api-key": api_key}
    try:
        #HTTP request
        request = urllib.request.Request(url=url,headers=headers,method="GET")
        #Call API
        with urllib.request.urlopen(request) as response:
            #Read response
            raw_data = response.read().decode("utf-8")
            json_data = json.loads(raw_data)
            #Save file
            with open(path, "w", encoding="utf-8") as file:
                json.dump(json_data, file, ensure_ascii=False, indent=4)
            return json_data

    # Error handling
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"Connection Error: {e.reason}")
    except json.JSONDecodeError:
        print("Invalid JSON response")
    except Exception as e:
        print(f"Exception: {e}")
    return None

if __name__ == "__main__":
    # CLI arguments
    parser = argparse.ArgumentParser(description="Download JSON data from API")
    parser.add_argument("--base-url", required=True,help="Base API URL")
    parser.add_argument("--size", type=int, default=1,help="Size parameter")
    parser.add_argument("--output", required=True,help="Output directory")
    parser.add_argument("--filename", required=True,help="Output JSON filename")
    parser.add_argument("--api-key", required=True,help="API key")
    args = parser.parse_args()

    # Build URL with params / other arguments such as page can be added
    params = {"size": args.size}

    url_api = f"{args.base_url}?{urlencode(params)}"
    # Call API
    result = call_API(url=url_api,output=args.output,name=args.filename,api_key=args.api_key)