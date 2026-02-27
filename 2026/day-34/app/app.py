from flask import Flask
import mysql.connector
import redis
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Flask + MySQL + Redis!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)