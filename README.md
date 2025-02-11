# docker.php5.6.apache

Docker container with php 5.6 and apache

## Build image

```
docker build -t jeffersonmello/php5.6:latest .
```

## Run container

To run the container on ports 8991 with info.php file in /var/www/html folder run the command below:

```
docker run -p 8991:80 -v ./var/www/html:/var/www/html jeffersonmello/php5.6:latest
```


## How to publish

````
docker push jeffersonmello/php5.6:latest
```