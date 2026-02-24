FROM ubuntu:latest

WORKDIR /app

COPY app.txt /app/

RUN apt update && apt install -y curl

EXPOSE 8080

CMD ["cat", "app.txt"]