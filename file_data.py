def read_plc1_state():
    plc_values1 = {}
    with open("plc_values_1.txt", "r") as file:
        for line in file.readlines():
            a, b = line.split(":")
            plc_values1[a.strip()] = b.strip()
    return plc_values1


def read_plc2_state():
    plc_values2 = {}
    with open("plc_values_2.txt", "r") as file:
        for line in file.readlines():
            a, b = line.split(":")
            plc_values2[a.strip()] = b.strip()
    return plc_values2


def dist_code_step():
    return read_plc1_state()['code_step']


def dist_manual_step():
    return read_plc1_state()['manual_step']


def dist_manual_auto_mode():
    return read_plc1_state()['manual_auto_mode']


def dist_system_on():
    return read_plc1_state()['system_on']


def sort_code_step():
    return read_plc2_state()['code_step']


def sort_manual_step():
    return read_plc2_state()['manual_step']


def sort_manual_auto_mode():
    return read_plc2_state()['manual_auto_mode']


def sort_system_on():
    return read_plc2_state()['system_on']


def sort_workpiece():
    return read_plc2_state()['workpiece']


def sort_workpiece_total():
    return read_plc2_state()['total']


def sort_workpiece_red():
    return read_plc2_state()['red']


def sort_workpiece_black():
    return read_plc2_state()['black']


def sort_workpiece_metallic():
    return read_plc2_state()['metallic']


def all_system_on():
    return 'true' if (read_plc1_state()['system_on'] == 'true'
                      and read_plc2_state()['system_on'] == 'true') \
        else 'false'


def all_code_step():
    code_step_number_1 = read_plc1_state()['code_step']
    code_step_number_2 = read_plc2_state()['code_step']
    return (code_step_number_1 if int(code_step_number_1) <= 7
            else '1' + code_step_number_2) + ':' + code_step_number_2


update_time = 0.05
