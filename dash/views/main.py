from flask import Blueprint, flash, redirect, render_template, request, session, abort
import os
import json
import requests
import apps

main = Blueprint('index', __name__)

@main.route('/')
def index():
    endpoints = json.loads(os.environ['MARATHON_ENDPOINTS'])
    envs = endpoints.keys()
    selectedEnvs = envs
    env = request.args.get('env')
    if env and env in envs:
        selectedEnvs = [env]
    app_data = apps.getAppDetails(selectedEnvs)
    return render_template('index.html',**locals())

@main.route('/ping')
def ping():
    return 'PONG'
