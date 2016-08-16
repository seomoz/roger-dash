from flask import flash
import os
import json
import requests
import re
import mesos
import utils

def get_resources_data(envs):
    endpoints = json.loads(os.environ['MESOS_ENDPOINTS'])
    res_data = {}
    res_data_by_env = {}
    for env in envs:
        master_url = endpoints[env]
        try:
            res_data_by_env[env] = mesos.get_resources(master_url)
        except Exception as e:
            print e
            flash('Had trouble accessing {} environment. Please try again soon.'.format(env))
            pass # possible connection error.. continue to next env
    #merge env
    res_data = utils.merge_dicts_in_dict_by_key(res_data_by_env)
    return res_data
