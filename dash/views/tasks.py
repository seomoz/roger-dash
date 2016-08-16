from flask import flash
import os
import json
import requests
import re
import mesos
import utils

def get_tasks_data(envs):
    endpoints = json.loads(os.environ['MESOS_ENDPOINTS'])
    tasks_data = {}
    tasks_data_by_env = {}
    for env in envs:
        master_url = endpoints[env]
        try:
            tasks_data_by_env[env] = mesos.get_tasks(master_url)
        except Exception as e:
            print e
            flash('Had trouble accessing {} environment. Please try again soon.'.format(env))
            pass # possible connection error.. continue to next env
    #merge env
    tasks_data = utils.merge_dicts_in_dict_by_key(tasks_data_by_env)
    return tasks_data

def get_apps_data(tasks):
    apps = {}
    for task, data in tasks.items():
        if '.' in task:
            appid = task[:task.rfind('.')]
            count = 1
            if appid in apps:
                count += apps[appid]['count']
                # merge other details
                for k,v in data.items():
                    apps[appid][k] += v
            else:
                apps[appid] = data
            apps[appid]['count'] = count
    return apps # { 'count': <count>, 'cpus': <cpus>, 'mem': <mem>, 'disk': <disk> }
