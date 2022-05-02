#!/bin/sh

while getopts :u:p: flag
do
    case "${flag}" in
        u) USER_NAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
        *)
    esac
done

for i in $(seq 100); do
    USER_CREATED=$(curl POST "https://lb:8080/api/v2/login/" --insecure -s -i -d "username=${USER_NAME}&password=${PASSWORD}" | head -1)

    case "$USER_CREATED" in
    *200*)
      echo "User ${USER_NAME} exists"
      echo "Execute $5"
      eval "$5"
      break
      ;;
    *)
      echo "User ${USER_NAME} doesn't exist. Sleep for 5 seconds"
      sleep 5
      echo "Trying again..."
      ;;
    esac

done
