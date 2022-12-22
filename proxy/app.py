#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# app.py
# Python file of the Flask app implementing the proxy

# The SSHTunnelFowarder is inspired by ChatGPT (https://chat.openai.com/chat/7357f263-5143-4631-91eb-561068494350) (accessed 21-12-2022)

from flask import Flask, request
import pymysql
import database
from sshtunnel import SSHTunnelForwarder
import random


app = Flask(__name__)

def contact_master(sql_query: str):
    app.config.from_prefixed_env() 
    connection = pymysql.connect(host=app.config['MASTERIP'], 
                                user=database.DB_USR, 
                                password=database.DB_PWD, 
                                database=database.DB_NAME, 
                                cursorclass=pymysql.cursors.DictCursor)
    results = 'No result fetched'
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(sql_query)
            results = cursor.fetchall()
        connection.commit()

    return str(results)

def contact_node(node_ip: str, sql_query: str):
    app.config.from_prefixed_env()
    with SSHTunnelForwarder(
            (node_ip, 22),
            ssh_username="ubuntu",
            ssh_pkey="/proxy/final_project.pem",
            remote_bind_address=(app.config['MASTERIP'], 3306)
        ) as tunnel:
            connection = pymysql.connect(host='127.0.0.1',
                                port=tunnel.local_bind_port, 
                                user=database.DB_USR, 
                                password=database.DB_PWD, 
                                database=database.DB_NAME, 
                                cursorclass=pymysql.cursors.DictCursor)
            with connection:
                with connection.cursor() as cursor:
                    cursor.execute(sql_query)
                    results = cursor.fetchall()
            connection.commit()

    return str(results)

# Default route
@app.route('/')
def base():
    return f'Please use the direct, random or smart routes.'

# Direct master hit route
@app.route('/direct', methods=['GET'])
def direct():
    query = request.args.get('query')
    
    return contact_master(query)

# Random node hit route
@app.route('/randhit')
def randhit():
    query = request.args.get('query')

    app.config.from_prefixed_env()
    nodes = [app.config['MASTERIP'], app.config['NODE0IP'], app.config['NODE1IP'], app.config['NODE2IP']]
    id = random.randint(0, 3)
    results = 'No results returned!'

    #No tunnel need if the query passes through the master or if the query is not a read operation
    if id == 0 or query.lower().find('select') != 0:
        return 'Query made through the master node ' + contact_master(query)
    else:
        selected_ip = nodes[id]
        results = contact_node(selected_ip, query)
    return f'Query made through secondary node {id - 1}' + results

# Smart route: Ping instances and take the fastest
@app.route('/smart')
def smart():
    return 'smart'
