#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# app.py
# Python file of the Flask app implementing the proxy

from flask import Flask

app = Flask(__name__)

# Default route
@app.route('/')
def base():
    app.config.from_prefixed_env()
    master = app.config['MASTERIP']
    node_1 = app.config['NODE0IP']
    node_2 = app.config['NODE1IP']
    node_3 = app.config['NODE2IP']
    return f'Please use the direct, random or smart routes. IPs: {master} {node_1} {node_2} {node_3}'

# Direct master hit route
@app.route('/direct')
def direct():
    return 'Direct'

# Random node hit route
@app.route('/random')
def random():
    return 'Random'

# Smart route: Ping instances and take the fastest
@app.route('/smart')
def smart():
    return 'smart'
