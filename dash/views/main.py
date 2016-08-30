from flask import Blueprint, flash, redirect, render_template, request, session, abort
import os
import json
import requests
import apps
import utils
import tasks
import resources

main = Blueprint('index', __name__)

@main.route('/ping')
def ping():
    return 'PONG'

@main.route('/index-old')
def index():
    endpoints = json.loads(os.environ['MARATHON_ENDPOINTS'])
    envs = endpoints.keys()
    selectedEnvs = envs
    env = request.args.get('env')
    if env and env in envs:
        selectedEnvs = [env]
    app_data = apps.getAppDetails(selectedEnvs)
    return render_template('index_old.html',**locals())

@main.route('/')
def index2():
    data_w, data_h = 2, 3

    endpoints = json.loads(os.environ['MESOS_ENDPOINTS'])
    envs = endpoints.keys()
    selectedEnvs = envs
    env = request.args.get('env')
    if env and env in envs:
        selectedEnvs = [env]
    raw_tasks_data = tasks.get_tasks_data(selectedEnvs)
    app_data = tasks.get_apps_data(raw_tasks_data)
    groups = json.loads(os.environ['GROUP_DATA'])
    default_grp = 'others'
    app_data_w_grp = utils.apply_group_by_key(app_data, groups, default_grp)

    alertd_endpoints = json.loads(os.environ['ALERTD_ENDPOINTS'])
    selected_alertd_env ='prod'
    if env:
        selected_alertd_env = env
    selected_alertd_endpoint = alertd_endpoints[selected_alertd_env]

    apps = {}
    tasks_data = {}
    cpus = {}
    mem = {}
    # initialize everything to 0
    totals = { 'apps':0, 'tasks_data':0, 'cpus': 0, 'mem': 0 }
    for grp in groups.keys() + [default_grp]:
        apps[grp] = 0
        tasks_data[grp] = 0
        cpus[grp] = 0
        mem[grp] = 0
    # find task, app, cpu, mem by group
    for appid, data in app_data_w_grp.items():
        grp = data['group']

        apps[grp] += 1
        totals['apps'] += 1

        tasks_data[grp] += data['count']
        totals['tasks_data'] += data['count']

        cpus[grp] += data['cpus']
        totals['cpus'] += data['cpus']

        mem[grp] += data['mem']
        totals['mem'] += data['mem']

    # get res data
    res_data = resources.get_resources_data(selectedEnvs)
    print res_data

    retdata = [[0 for x in range(data_w)] for y in range(data_h)]
    title = [[0 for x in range(data_w)] for y in range(data_h)]

    retdata[0][0] = tasks_data
    title[0][0] = '{} tasks are running on RogerOS ({})...'.format(totals['tasks_data'], '+'.join(selectedEnvs))
    retdata[0][1] = apps
    title[0][1] = '...which are instances of {} applicatons.'.format(totals['apps'])

    retdata[1][0] = cpus
    title[1][0] = '{} cpus are currently allocated to these tasks...'.format(totals['cpus'])
    retdata[1][1] = { 'allocated': res_data['allocated_cpus'], 'available': res_data['total_cpus'] - res_data['allocated_cpus']}
    title[1][1] = '...out of a total of {} cpus across the cluster.'.format(res_data['total_cpus'])

    retdata[2][0] = mem
    title[2][0] = '{} mb of memory is allocated to these tasks...'.format(totals['mem'])
    retdata[2][1] = { 'allocated': res_data['allocated_mem'], 'available': res_data['total_mem'] - res_data['allocated_mem']}
    title[2][1] = '...out of a total of {} mb across the cluster.'.format(res_data['total_mem'])

    return render_template('index.html',**locals())
