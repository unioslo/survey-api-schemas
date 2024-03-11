#!/usr/bin/env python3
from enum import Enum, auto
from getpass import getpass
from typing import Any, Dict, List
import requests
from datetime import datetime, date
import json
import os

"""
 - for all forms that do not have any generatedDate in metadata:
   - loop over each form
   - use current dataloader approach to identify the most recent metadata entry of a form
   - using that entry, add a generated date field ('value_new_generated_date' as value)
   - submit this patched entry to the form's metadata without changing the existing entries

 - start with p11 selected forms
 - p11 all forms
 - all tsd projects
 - educloud
"""


api_key = os.getenv("API_KEY")
api_url = "https://internal.api.tsd.usit.no"
config_dry_run = False
key_generated_date = "generatedDate"
key_modified_date = "modifiedDate"
key_elements = "elements"
value_new_generated_date = "2023-11-11T11:11:11.111Z"

#-------------------------------------------------------------------------------

def get_access_token(project_number: str) -> str:
    api_key_headers = {"Authorization": f"Bearer {api_key}"}
    resp = requests.post(f"{api_url}/v1/{project_number}/auth/basic/token?type=survey_batch", headers=api_key_headers)
    resp.raise_for_status()
    token = resp.json()["token"]
    return token

#-------------------------------------------------------------------------------

def get_form_ids(project_number: str, access_token: str) -> List[str]:
    headers = {"Authorization": f"Bearer {access_token}"}
    resp = requests.get(f"{api_url}/v1/{project_number}/survey", headers=headers)
    resp.raise_for_status()
    form_ids = [x for x in resp.json()["tables"] if "task" not in x]
    return form_ids

#-------------------------------------------------------------------------------

def get_generated_date_exists(metadatas):
    return any(key_generated_date in md for md in metadatas)


#-------------------------------------------------------------------------------

def get_updated_metadata(project_number: str, form_id: str, access_token: str) -> "Any | None":
    headers = {"Authorization": f"Bearer {access_token}"}
    resp = requests.get(f"{api_url}/v1/{project_number}/survey/{form_id}/metadata", headers=headers)
    if resp.status_code == 404:
        print(f"form {project_number}/{form_id} /metadata not found")
        return None
    try:
        resp.raise_for_status()
    except:
        print(f"form {project_number}/{form_id} error fetching metadata")
        return None
    metadatas = resp.json()
    if len(metadatas) == 0:
        print(f"form {project_number}/{form_id} no metadata entries")
        return None
    has_generated_date = get_generated_date_exists(metadatas)
    if has_generated_date:
        return None
    # guess new entry by using modifiedDate timestamp
    #
    # - modified date - sometimes (on manually created forms?), the most recent
    #     "modifiedDate" is not found in the most recent metadata
    # - number of elements - sometimes (on manually created forms?), the number of
    #     elements can be reduced for the last entries of metadata
    #     (example: tsd application form 297978)
    new_metadata_entry = sorted(
        metadatas,
        key=lambda m: (
            m.get(key_modified_date, "1970-01-01T00:00:00.000+0100")
        ),
        reverse=True,
    )[0]
    # add generatedDate
    new_metadata_entry[key_generated_date] = value_new_generated_date
    return new_metadata_entry

#-------------------------------------------------------------------------------

def submit_new_metadata(project_number: str, form_id: str, access_token: str, metadata: Dict[str, Any]):
    headers = {"Authorization": f"Bearer {access_token}"}
    resp = requests.put(f"{api_url}/v1/{project_number}/survey/{form_id}/metadata", headers=headers, data=metadata)
    resp.raise_for_status()

#-------------------------------------------------------------------------------

if __name__ == "__main__":
    project_numbers = ["p11"]
    for project_number in project_numbers:
        print(f"updating project {project_number}")
        access_token = get_access_token(project_number=project_number)
        form_ids = get_form_ids(project_number=project_number, access_token=access_token)

        num_complete = 0
        stats: Dict[str, List[str]] = {
             "receives_update": [],
             "new_metadata": [],
        }
        for form_id in form_ids:
            new_metadata = get_updated_metadata(project_number=project_number, form_id=form_id, access_token=access_token)
            if new_metadata != None:
                stats["receives_update"].append(form_id)
                stats["new_metadata"].append(new_metadata)
            num_complete += 1
            # submit new entry?
            if (not config_dry_run) and (new_metadata != None):
                if form_id == "281680": # TODO: remove me
                    print(f"updating {form_id}")
                    submit_new_metadata(project_number=project_number, form_id=form_id, access_token=access_token, metadata=new_metadata)
            print(project_number, "complete: ", num_complete, "/", len(form_ids), "\r", end="")
        print("\ndone\n")

        print(project_number, "forms that were updated:", len(stats["receives_update"]))
        with open(f"output_{project_number}.json", "w") as f:
            d = json.dumps(stats["new_metadata"], indent=2)
            f.write(d)

exit(0)
