#!/bin/bash

set -e

#############################################
# Grafana Public Dashboard Creator
# VOIPIRAN
#############################################

GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASS="admin"

OUTPUT_DIR="/var/lib/voipiran"
OUTPUT_FILE="${OUTPUT_DIR}/grafana_links.conf"

mkdir -p "${OUTPUT_DIR}"
> "${OUTPUT_FILE}"

echo ""
echo "===================================================="
echo " Creating Grafana Public Dashboards"
echo "===================================================="

#############################################
# Wait for Grafana
#############################################

echo -n "Waiting for Grafana API"

until curl -sf "${GRAFANA_URL}/api/health" >/dev/null
do
    echo -n "."
    sleep 2
done

echo " OK"
echo ""

#############################################
# Dashboard List
#############################################

DASHBOARDS=$(curl -s \
    -u "${GRAFANA_USER}:${GRAFANA_PASS}" \
    "${GRAFANA_URL}/api/search?type=dash-db")

COUNT=$(echo "$DASHBOARDS" | python3 -c '
import json,sys
print(len(json.load(sys.stdin)))
')

echo "Found ${COUNT} dashboard(s)"
echo ""

#############################################
# Process Dashboards
#############################################

export DASHBOARDS

python3 <<'PYTHON'

import json
import os
import urllib.request
import urllib.error
import base64
import sys

URL="http://localhost:3000"
USER="admin"
PASS="admin"

LINK_FILE="/var/lib/voipiran/grafana_links.conf"

auth=base64.b64encode(f"{USER}:{PASS}".encode()).decode()

dashboards = json.loads(os.environ["DASHBOARDS"])

def api(method,url,data=None):

    req=urllib.request.Request(url,method=method)
    req.add_header("Authorization","Basic "+auth)
    req.add_header("Content-Type","application/json")

    if data is not None:
        data=data.encode()

    try:
        with urllib.request.urlopen(req,data=data) as r:
            return r.read().decode(),r.status
    except urllib.error.HTTPError as e:
        return e.read().decode(),e.code


for index,d in enumerate(dashboards,1):

    uid=d["uid"]
    title=d["title"]

    print("----------------------------------------------------")
    print(f"[{index}/{len(dashboards)}] {title}")

    #
    # Create Public Dashboard
    #

    body,status=api(
        "POST",
        f"{URL}/api/dashboards/uid/{uid}/public-dashboards/",
        "{}"
    )

    if status==200:
        print("  ✔ Public dashboard created")

    elif status==400:
        print("  ✔ Already public")

    else:
        print(body)
        continue

    #
    # Read Information
    #

    body,status=api(
        "GET",
        f"{URL}/api/dashboards/uid/{uid}/public-dashboards/"
    )

    info=json.loads(body)

    public_uid=info["uid"]

    #
    # Enable
    #

    body,status=api(
        "PATCH",
        f"{URL}/api/dashboards/uid/{uid}/public-dashboards/{public_uid}",
        json.dumps({
            "isEnabled":True,
            "timeSelectionEnabled":False,
            "annotationsEnabled":False,
            "share":"public"
        })
    )

    print("  ✔ Enabled")

    #
    # Read Again
    #

    body,status=api(
        "GET",
        f"{URL}/api/dashboards/uid/{uid}/public-dashboards/"
    )

    info=json.loads(body)

    token=info["accessToken"]

    url=f"{URL}/public-dashboards/{token}"

    print("  ✔ "+url)

    with open(LINK_FILE,"a") as f:
        f.write(f'{uid}="{url}"\n')

print("")
print("====================================================")
print("Public dashboard links created successfully.")
print("====================================================")
print("")
print("Configuration file:")
print(LINK_FILE)
print("")

PYTHON