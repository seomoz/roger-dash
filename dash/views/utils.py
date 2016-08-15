def apply_group_by_key(a_dict, groups, default_group=None):
    if not default_group:
        default_group = 'others'
    for k, v in a_dict.items():
        group = default_group
        for group_name, patterns in groups.items():
            if isMatchingName(k, patterns):
                    group = group_name
                    break
        v['group'] = group
    return a_dict

def isMatchingName(name, patterns):
    for item in patterns:
        if item in name:
            return True
    return False

def merge_dicts_in_dict_by_key(a_dict_with_dicts):
    ret_data = {}
    for k, dicts_data in a_dict_with_dicts.items():
        for k2, data in dicts_data.items():
            if k2 not in ret_data:
                ret_data[k2] = data
            else:
                # add values
                ret_data[k2] += data
    return ret_data
