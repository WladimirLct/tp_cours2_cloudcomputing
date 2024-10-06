from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return {'message': 'Hello, World!'}

@app.route('/insert_data')
def insert_data():
    return {'message': 'Data inserted successfully!'}

@app.route('/get_data')
def get_data():
    return {'message': 'Data fetched successfully!'}