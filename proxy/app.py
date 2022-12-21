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
    return 'Please use the direct, random or smart routes'

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
