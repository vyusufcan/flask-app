import os
from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def main():
    return render_template('index.html', version=os.getenv("version"))

@app.route('/status')
def status():
    return "ok"

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=8080)