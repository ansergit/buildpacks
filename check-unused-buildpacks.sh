#!/bin/bash

# Get all buildpacks
all_buildpacks=$(cf buildpacks | awk '{if(NR>4) print $2}')

# Get all orgs
orgs=$(cf orgs | awk '{if(NR>4) print $1}')

used_buildpacks=""

# Loop through all orgs and spaces to find used buildpacks
for org in $orgs; do
    echo "Checking organization: $org"
    spaces=$(cf spaces -o $org | awk '{if(NR>4) print $1}')
    for space in $spaces; do
        echo "  Checking space: $space"
        cf target -o $org -s $space > /dev/null 2>&1
        apps=$(cf apps | awk '{if(NR>4) print $1}')
        for app in $apps; do
            buildpack=$(cf app $app | grep "buildpack:" | awk '{print $2}')
            if [[ ! -z $buildpack ]]; then
                used_buildpacks="$used_buildpacks $buildpack"
            fi
        done
    done
done

# Deduplicate used buildpacks
used_buildpacks=$(echo $used_buildpacks | tr ' ' '\n' | sort | uniq)

# Compare with all buildpacks to find unused ones
echo "Unused Buildpacks:"
for bp in $all_buildpacks; do
    if [[ ! $used_buildpacks =~ $bp ]]; then
        echo $bp
    fi
done
