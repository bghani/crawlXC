#!/bin/bash

# Define the query parameter
query="grp:2"

# Convert the query parameter to a filename-friendly format
filename_friendly_query=$(echo "$query" | tr ':' '_')

# Download the first JSON file to get the number of pages
wget -O noca-query.json "https://xeno-canto.org/api/2/recordings?query=$query"

# Extract the number of pages using jq
numPages=$(jq '.numPages' noca-query.json)

# Generate a header for the csv file
csv_filename="${filename_friendly_query}_recordings.csv"
echo "id,gen,sp,ssp,group,en,rec,cnt,loc,lat,lng,alt,type,sex,stage,method,url,file,file-name,lic,q,length,time,date,uploaded,rmk,bird-seen,animal-seen,playback-used,temp,regnr,auto,dvc,mic,smp" > "$csv_filename"

# Loop through all the pages and download them
for ((i=1; i<=$numPages; i++)); do
    wget -O "noca-query-$i.json" "https://xeno-canto.org/api/2/recordings?query=$query&page=$i"

    # Convert the combined JSON file to a single CSV file
    jq -r '.recordings[] | [.id, .gen, .sp, .ssp, .group, .en, .rec, .cnt, .loc, .lat, .lng, .alt, .type, .sex, .stage, .method, .url, .file, ."file-name", .lic, .q, .length, .time, .date, .uploaded, .rmk, ."bird-seen", ."animal-seen", ."playback-used", .temp, .regnr, .auto, .dvc, .mic, .smp] | @csv' "noca-query-$i.json" >> "$csv_filename"
done

# Remove temporary files if needed
rm noca-query-*.json
