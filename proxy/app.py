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
import subprocess
import sys


app = Flask(__name__)

def contact_master(sql_query: str):
    '''
    Connects to the master node and perform a SQL query on it.

            Parameters:
                    sql_query (str): the SQL query to perform

            Returns:
                    results (str): Results of the performed SQL query
    '''
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
    '''
    Connects to a specific node and perform a SQL query on it through an SSH tunnel.

            Parameters:
                    node_ip (str): the IP of the node on which to perform the query
                    sql_query (str): the SQL query to perform

            Returns:
                    results (str): Results of the performed SQL query
    '''
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
    '''
    Basic route.
            Returns:
                    message (str): Message to tell the client to use a specific route 
    '''
    return f'Please use the direct, randhit or smart routes.'

# Direct master hit route
@app.route('/direct', methods=['GET'])
def direct():
    '''
    Implementation of the direct hit proxy mode. Connects directly to the master.

            Request Parameters:
                    query (str): the SQL query to perform

            Returns:
                    results (str): Results of the performed SQL query
    '''
    query = request.args.get('query')
    
    return contact_master(query)

# Random node hit route
@app.route('/randhit')
def randhit():
    '''
    Implementation of the random hit proxy mode. Connects to a randomly chosen node.

            Request Parameters:
                    query (str): the SQL query to perform

            Returns:
                    results (str): Results of the performed SQL query
    '''
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
    return f'Query made through secondary node {id - 1} ' + results

# Smart route: Ping instances and take the fastest
@app.route('/smart')
def smart():
    '''
    Implementation of the smart hit proxy mode. Connects to the node with the smallest ping response time.

            Request Parameters:
                    query (str): the SQL query to perform

            Returns:
                    results (str): Results of the performed SQL query
    '''
    query = request.args.get('query')
    app.config.from_prefixed_env()
    nodes = [app.config['MASTERIP'], app.config['NODE0IP'], app.config['NODE1IP'], app.config['NODE2IP']]
    
    best_node = 0
    current_node = 0
    best_time = 0

    #Ping all instances and get fastest node id
    for ip in nodes:
        ping = subprocess.check_output(["ping", "-c", "1", ip])
        current_time = float(str(ping).split('time=')[1].split(' ')[0])
        print(f'Evaluating current time: {current_time} for node {current_node}', file=sys.stdout)
        if current_node != 0:
            if current_time < best_time:
                best_node = current_node
                best_time = current_time
        else :
            best_time = current_time
        current_node += 1
    print(f'Best time: {best_time} is node {best_node}', file=sys.stdout)
    results = 'No results returned!'

    #No tunnel need if the query passes through the master or if the query is not a read operation
    if best_node == 0 or query.lower().find('select') != 0:
        return 'Query made through the master node ' + contact_master(query)
    else:
        selected_ip = nodes[best_node]
        results = contact_node(selected_ip, query)
    return f'Query made through secondary node {best_node - 1} ' + results
