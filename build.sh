#!/bin/bash
docker login
docker build -t vitalyven/docker-postgresql-large-cube:13.1-alpine .
docker push vitalyven/docker-postgresql-large-cube:13.1-alpine
docker logou