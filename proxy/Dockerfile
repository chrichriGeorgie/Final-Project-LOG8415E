# syntax=docker/dockerfile:1
#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# Dockerfile
# Docker description to build and run the Flask app implementing the proxy

FROM python:3.10-alpine

ENV FLASK_MASTERIP="10.0.2.7"

ENV FLASK_NODE0IP="10.0.2.14"

ENV FLASK_NODE1IP="10.0.2.13"

ENV FLASK_NODE2IP="10.0.2.10"

WORKDIR /proxy

COPY . .

RUN pip install -r requirements.txt

CMD [ "python3", "-m" , "-u", "flask", "run", "--host=0.0.0.0" ]