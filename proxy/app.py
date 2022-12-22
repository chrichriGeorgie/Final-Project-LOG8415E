#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# app.py
# Python file of the Flask app implementing the proxy

from flask import Flask, request
import pymysql
import database


app = Flask(__name__)

# Default route
@app.route('/')
def base():
    return f'Please use the direct, random or smart routes.'

# Direct master hit route
@app.route('/direct', methods=['GET'])
def direct():
    app.config.from_prefixed_env()
    master = app.config['MASTERIP']
    connection = pymysql.connect(host=master, 
                                user=database.DB_USR, 
                                password=database.DB_PWD, 
                                database=database.DB_NAME, 
                                cursorclass=pymysql.cursors.DictCursor)
    results = 'No result fetched'
    with connection:
        with connection.cursor() as cursor:
            query = request.args.get('query')
            cursor.execute(query)
            results = cursor.fetchall()
        connection.commit()

    return str(results)

# Random node hit route
@app.route('/random')
def random():
    return 'Random'

# Smart route: Ping instances and take the fastest
@app.route('/smart')
def smart():
    return 'smart'
