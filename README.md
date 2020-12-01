# docker-postgres-large-cube
Postgres DB docker image with increased limit for CUBE datatype
Based on: https://github.com/docker-library/postgres/tree/master/13/alpine
The only differences: 
* block size set to 32
* `#define CUBE_MAX_DIM (100) -> #define CUBE_MAX_DIM (2048`

Docker Hub: https://hub.docker.com/r/vitalyven/docker-postgresql-large-cube