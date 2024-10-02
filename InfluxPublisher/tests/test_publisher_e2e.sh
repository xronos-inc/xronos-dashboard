#!/bin/bash

set -euo pipefail

# load the influx db variables
source ../../influxdb/influx.env

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # default color

#for storing output data from the influx query so we can parse. Deleted at end of run.
output_file="influx_query_test_res.csv"

sleep 6 # when triggered on an action, ensure it's been up long enought to have generated data

curl -sS -X POST http://localhost:8086/api/v2/query?org=$DOCKER_INFLUXDB_INIT_ORG \
    --output $output_file \
    --header "Authorization: Token $DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" \
    --header "Accept: application/csv" \
    --header "Content-type: application/vnd.flux" \
    --data 'from(bucket:"'$DOCKER_INFLUXDB_INIT_BUCKET'")
        |> range(start: -5s)
        |> filter(fn: (r) => r._measurement == "xronos-dashboard-test")
        |> aggregateWindow(every: 1s, fn: mean)
        '
    
        
# Load the CSV file and count the number of lines
line_count=$(wc -l < $output_file)  

# Check if line count is less than 20 (we have ten for both the the c and python publishers)
if [ "$line_count" -lt 10 ]; then
    echo -e "${RED}fail - influx db missing data  -- found " + $line_count + " lines, expected greater than 10${NC}"
    exit 1
else
    echo -e "${GREEN}pass - influx db has expected data quantity.${NC}"
fi

# Find the minimum and maximum _value in the file. Min value should always be negative (since we are testing the c and python code, which generate sin and cos functions). Their averages should be opposite of each other.
min_value=$(cut -d',' -f7 "$output_file" | tail -n +2 | sort -n | head -n 1)
max_value=$(cut -d',' -f7 "$output_file" | tail -n +2 | sort -n | tail -n 1)

# Calculate the difference
difference=$(echo "$max_value + $min_value" | bc)

# Check if the difference is within 0.01
if (( $(echo "$difference <= 0.1" | bc -l) )); then
    echo -e "${GREEN}pass - influx db has expected data range.${NC}"
else
    echo -e "${RED}fail - influx db does not have expected data range. Found difference of $difference${NC}"
    exit 1
fi


 
# Clean up the output file
rm $output_file

# GRAFANA TESTS

GRAFANA_URL="http://admin:linguafranca@localhost:3000"


#this is the same query as above, but this time passing it through the grafana datasource api.
RESULT=$(curl -sS -X POST \
  $GRAFANA_URL/api/ds/query \
  -H "Content-Type: application/json" \
  -d '{
    "queries": [
      {
        "refId": "A",
        "datasourceId": 1,
        "rawQuery": true,
        "query": "from(bucket:\"'$DOCKER_INFLUXDB_INIT_BUCKET'\") |> range(start: -5s) |> filter(fn: (r) => r._measurement == \"xronos-dashboard-test\") |> aggregateWindow(every: 1s, fn: mean)",
        "queryType": "flux"
      }
    ],
    "range": {
      "from": "now-10s",
      "to": "now"
    }
  }' | jq '[.results.A.frames[] | .schema.fields[1].labels.language as $name | .data.values | {name: $name, Time: .[0], Data: .[1]}]')


# ensure that we have data for every second we have queried
py_length=$(echo "$RESULT" | jq '.[] | select(.name == "py") | .Data | length')
c_length=$(echo "$RESULT" | jq '.[] | select(.name == "c") | .Data | length')

# Check if both lengths are at least 5
if [[ "$py_length" -ge 5 && "$c_length" -ge 5 ]]; then
    echo -e "${GREEN}pass - Both py and c have published data every second for the last ten seconds.${NC}"
else
    echo -e "${RED}Failed the data length check. It is possible that we have missing data. Of the last ten seconds, the following publishers only have data for Py: $py_length, C: $c_length${NC}"
    exit 1
fi

# Define a small tolerance for checking approximate equality
tolerance=0.01

# the averages of any points besides the first and last should be approximately equal if things are working correctly. We compare the absolute value of the mean of seconds 3 and 4 to ensure data is streaming correctly.
py_valid=$(echo "$RESULT" | jq --argjson tol "$tolerance" '
  def abs(x): if x < 0 then -x else x end;
  .[] | select(.name == "py") | .Data as $data |
  (abs($data[3]) <= 1) and
  (abs($data[4]) <= 1) and
  ((abs($data[3]) - abs($data[4]))  <= $tol)
')

c_valid=$(echo "$RESULT" | jq --argjson tol "$tolerance" '
  def abs(x): if x < 0 then -x else x end;
  .[] | select(.name == "c") | .Data as $data |
  (abs($data[3]) <= 1) and
  (abs($data[4]) <= 1) and
  ((abs($data[3]) - abs($data[4]))  <= $tol)
')

# Validate the results
if [[ "$py_valid" == "true" && "$c_valid" == "true" ]]; then
    echo -e "${GREEN}pass - PY and C arrays pass the mean value data quality test.${NC}"
else
    echo -e "${RED}Failed the data value check, we have an unexpected drift in mean values across seconds. 
    It is possible that we are dropping some data packets. Test results: Py: $py_valid, C: $c_valid${NC}"
    exit 1  
fi

exit 0
