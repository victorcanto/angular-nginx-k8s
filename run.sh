docker build -t ssr-nginx-poc .
docker run -it --rm --name ssr-nginx-poc -p 80:80 ssr-nginx-poc
