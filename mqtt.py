import time
import threading
import paho.mqtt.client as paho
from paho import mqtt
from opcua import Client, ua

# todo OPCUA CONNECTION
# distribution_nodes
dist_start_node_id = 'ns=3;s="PYTHON_COMM"."START"'
dist_stop_node_id = 'ns=3;s="PYTHON_COMM"."STOP"'
dist_reset_node_id = 'ns=3;s="PYTHON_COMM"."RESET"'
dist_code_step_node_id = 'ns=3;s="PYTHON_COMM"."CODE_STEP"'
dist_manual_auto_mode_node_id = 'ns=3;s="PYTHON_COMM"."MANUAL_AUTO_MODE"'
dist_manual_step_node_id = 'ns=3;s="PYTHON_COMM"."MANUAL_STEP"'
dist_system_on_node_id = 'ns=3;s="PYTHON_COMM"."SYSTEM_ON"'

# sorting_nodes
sort_start_node_id = 'ns=3;s="PYTHON_COMM_2"."START"'
sort_stop_node_id = 'ns=3;s="PYTHON_COMM_2"."STOP"'
sort_reset_node_id = 'ns=3;s="PYTHON_COMM_2"."RESET"'
sort_code_step_node_id = 'ns=3;s="PYTHON_COMM_2"."CODE_STEP"'
sort_manual_auto_mode_node_id = 'ns=3;s="PYTHON_COMM_2"."MANUAL_AUTO_MODE"'
sort_manual_step_node_id = 'ns=3;s="PYTHON_COMM_2"."MANUAL_STEP"'
sort_system_on_node_id = 'ns=3;s="PYTHON_COMM_2"."SYSTEM_ON"'
sort_workpiece_node_id = 'ns=3;s="PYTHON_COMM_2"."WORKPIECE"'
sort_metallic_number_node_id = 'ns=3;s="PYTHON_COMM_2"."METALLIC NUMBER" '
sort_red_number_node_id = 'ns=3;s="PYTHON_COMM_2"."RED NUMBER" '
sort_black_number_node_id = 'ns=3;s="PYTHON_COMM_2"."BLACK NUMBER" '
sort_total_number_node_id = 'ns=3;s="PYTHON_COMM_2"."TOTAL NUMBER" '


def establish_opc_conn(port):
    url = "opc.tcp://192.168.0." + port
    client_conn = Client(url)
    client_conn.connect()
    client_conn.get_root_node()
    return client_conn


def read_input_value(client_fn, node_id):
    client_node = Client.get_node(client_fn, node_id)  # get node
    client_node_value = client_node.get_value()  # read node value
    return client_node_value


def write_value_bool(node_id, value, client_fn):
    client_node = client_fn.get_node(node_id)  # get node
    client_node_value = value
    client_node_dv = ua.DataValue(ua.Variant(
        client_node_value, ua.VariantType.Boolean))
    client_node.set_value(client_node_dv)


def write_value_int(node_id, value, client_fn):
    client_node = Client.get_node(client_fn, node_id)  # get node
    client_node_value = value
    client_node_dv = ua.DataValue(ua.Variant(
        client_node_value, ua.VariantType.Int16))
    client_node.set_value(client_node_dv)


def on_connect(client_conn, userdata, flags, rc, properties=None):
    publish_data('REQUEST INIT', 'true')
    print('MQTT INITIALIZATION SUCCESSFUL')


def on_publish(client_pub, userdata, mid, properties=None):
    print("publish mid: " + str(mid))


def on_subscribe(client_sub, userdata, mid, granted_qos, properties=None):
    print("Subscribed: " + str(mid) + " " + str(granted_qos))


def on_message(client_msg, userdata, msg):
    topic = str(msg.topic)
    payload = str(msg.payload)
    delay = 0.2

    if topic == 'REQUEST INIT' and payload == 'b\'true\'':
        print('request init successful')

        publish_data("CODE STEP DISTRIBUTION", str(read_input_value(
            plc_client_1, dist_code_step_node_id)))
        publish_data("MANUAL STEP DISTRIBUTION", str(read_input_value(
            plc_client_1, dist_manual_step_node_id)))
        publish_data("MANUAL AUTO MODE DISTRIBUTION", str(read_input_value(
            plc_client_1, dist_manual_auto_mode_node_id)))
        publish_data("SYSTEM ON DISTRIBUTION", str(read_input_value(
            plc_client_1, dist_system_on_node_id)))

        sort_wp = str(read_input_value(
            plc_client_2, sort_total_number_node_id))
        sort_red = str(read_input_value(
            plc_client_2, sort_red_number_node_id))
        sort_black = str(read_input_value(
            plc_client_2, sort_black_number_node_id))
        sort_metal = str(read_input_value(
            plc_client_2, sort_metallic_number_node_id))
        sort_total = str(read_input_value(
            plc_client_2, sort_total_number_node_id))
        publish_data("CODE STEP SORTING",
                     str(read_input_value(
                         plc_client_2, sort_code_step_node_id)) + ':' + sort_wp + ':' + sort_black +
                     ':' + sort_metal +
                     ':' + sort_red +
                     ':' + sort_total
                     )
        publish_data("MANUAL STEP SORTING", str(read_input_value(
            plc_client_2, sort_manual_step_node_id)))
        publish_data("MANUAL AUTO MODE SORTING", str(read_input_value(
            plc_client_2, sort_manual_auto_mode_node_id)))
        publish_data("SYSTEM ON SORTING", str(read_input_value(
            plc_client_2, sort_system_on_node_id)))

        dist_on = str(read_input_value(
            plc_client_1, dist_system_on_node_id))
        sort_on = str(read_input_value(
            plc_client_2, sort_system_on_node_id))
        new_all_system_on = 'true' if (dist_on == 'true'
                                       and sort_on == 'true') \
            else 'false'
        publish_data("SYSTEM ON ALL", new_all_system_on)

        code_step_number_1 = str(read_input_value(
            plc_client_1, dist_code_step_node_id))
        code_step_number_2 = str(read_input_value(
            plc_client_2, sort_code_step_node_id))
        new_all_code_step = (code_step_number_1 if int(code_step_number_1) <= 7
                             else '1' + code_step_number_2)
        new_all_code_step = (code_step_number_1 if int(code_step_number_1) <= 7
                             else '1' + code_step_number_2)
        publish_data("CODE STEP ALL", new_all_code_step)

    if topic == 'START DISTRIBUTION' and payload == 'b\'true\'':
        print('start dist')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_start_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_start_node_id, value=False)

    if topic == 'STOP DISTRIBUTION' and payload == 'b\'true\'':
        print('stop dist')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_stop_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_stop_node_id, value=False)

    if topic == 'RESET DISTRIBUTION' and payload == 'b\'true\'':
        print('reset dist')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_reset_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_reset_node_id, value=False)

    if topic == 'START SORTING' and payload == 'b\'true\'':
        print('start sorting')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_start_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_start_node_id, value=False)

    if topic == 'STOP SORTING' and payload == 'b\'true\'':
        print('stop sorting')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_stop_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_stop_node_id, value=False)

    if topic == 'RESET SORTING' and payload == 'b\'true\'':
        print('reset sorting')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_reset_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_reset_node_id, value=False)

    if topic == 'START ALL' and payload == 'b\'true\'':
        print('start all')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_start_node_id, value=True)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_start_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_start_node_id, value=False)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_start_node_id, value=False)

    if topic == 'STOP ALL' and payload == 'b\'true\'':
        print('stop all')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_stop_node_id, value=True)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_stop_node_id, value=True)
        time.sleep(delay)
        print('revert')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_stop_node_id, value=False)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_stop_node_id, value=False)

    if topic == 'RESET ALL' and payload == 'b\'true\'':
        print('reset all')
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_reset_node_id, value=True)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_reset_node_id, value=True)
        time.sleep(delay)
        write_value_bool(client_fn=plc_client_1,
                         node_id=dist_reset_node_id, value=False)
        write_value_bool(client_fn=plc_client_2,
                         node_id=sort_reset_node_id, value=False)


# todo MQTT INITIALIZATION
quality = 1
update_time = 0.01


# publish data
def publish_data(topic, payload):
    return client.publish(topic=topic, payload=payload, qos=quality)


# define the thread functions
def stream_subscription():
    client.subscribe([('REQUEST INIT', quality), ("START DISTRIBUTION", quality),
                      ("STOP DISTRIBUTION", quality), ("RESET DISTRIBUTION",
                                                       quality), ("START SORTING", quality),
                      ("STOP SORTING", quality), ("RESET SORTING",
                                                  quality), ("START ALL", quality),
                      ("STOP ALL", quality), ("RESET ALL", quality), ], qos=1)
    client.loop_forever()


def stream_code_step_dist():
    old_dist_code_step = ''
    while True:
        new_dist_code_step = str(read_input_value(
            plc_client_1, dist_code_step_node_id))
        if old_dist_code_step != new_dist_code_step:
            publish_data("CODE STEP DISTRIBUTION", new_dist_code_step)
            old_dist_code_step = new_dist_code_step
        time.sleep(update_time)


def stream_manual_step_dist():
    old_dist_manual_step = ''
    while True:
        new_dist_manual_step = str(read_input_value(
            plc_client_1, dist_manual_step_node_id))
        if old_dist_manual_step != new_dist_manual_step:
            publish_data("MANUAL STEP DISTRIBUTION", new_dist_manual_step)
            old_dist_manual_step = new_dist_manual_step
        time.sleep(update_time)


def stream_manual_auto_mode_dist():
    old_dist_manual_auto = ''
    while True:
        new_dist_manual_auto = str(read_input_value(
            plc_client_1, dist_manual_auto_mode_node_id))
        if old_dist_manual_auto != new_dist_manual_auto:
            publish_data("MANUAL AUTO MODE DISTRIBUTION", new_dist_manual_auto)
            old_dist_manual_auto = new_dist_manual_auto
        time.sleep(update_time)


def stream_system_on_dist():
    old_dist_system_on = ''
    while True:
        new_dist_system_on = str(read_input_value(
            plc_client_1, dist_system_on_node_id))
        if old_dist_system_on != new_dist_system_on:
            publish_data("SYSTEM ON DISTRIBUTION", new_dist_system_on)
            old_dist_system_on = new_dist_system_on
        time.sleep(update_time)


def stream_code_step_sort():
    old_sort_code_step = ''
    while True:
        new_sort_code_step = str(read_input_value(
            plc_client_2, sort_code_step_node_id))
        if old_sort_code_step != new_sort_code_step:
            sort_wp = str(read_input_value(
                plc_client_2, sort_total_number_node_id))
            sort_red = str(read_input_value(
                plc_client_2, sort_red_number_node_id))
            sort_black = str(read_input_value(
                plc_client_2, sort_black_number_node_id))
            sort_metal = str(read_input_value(
                plc_client_2, sort_metallic_number_node_id))
            sort_total = str(read_input_value(
                plc_client_2, sort_total_number_node_id))
            publish_data("CODE STEP SORTING",
                         new_sort_code_step + ':' + sort_wp + ':' + sort_black +
                         ':' + sort_metal +
                         ':' + sort_red +
                         ':' + sort_total
                         )
            old_sort_code_step = new_sort_code_step
        time.sleep(update_time)


def stream_manual_step_sort():
    old_sort_manual_step = ''
    while True:
        new_sort_manual_step = str(read_input_value(
            plc_client_2, sort_manual_step_node_id))
        if old_sort_manual_step != new_sort_manual_step:
            publish_data("MANUAL STEP SORTING", new_sort_manual_step)
            old_sort_manual_step = new_sort_manual_step
        time.sleep(update_time)


def stream_manual_auto_mode_sort():
    old_sort_manual_auto = ''
    while True:
        new_sort_manual_auto = str(read_input_value(
            plc_client_2, sort_manual_auto_mode_node_id))
        if old_sort_manual_auto != new_sort_manual_auto:
            publish_data("MANUAL AUTO MODE SORTING", new_sort_manual_auto)
            old_sort_manual_auto = new_sort_manual_auto
        time.sleep(update_time)


def stream_system_on_sort():
    old_sort_system_on = ''
    while True:
        new_sort_system_on = str(read_input_value(
            plc_client_2, sort_system_on_node_id))
        if old_sort_system_on != new_sort_system_on:
            publish_data("SYSTEM ON SORTING", new_sort_system_on)
            old_sort_system_on = new_sort_system_on
        time.sleep(update_time)


def stream_system_on_all():
    old_all_system_on = ''
    while True:
        dist_on = str(read_input_value(
            plc_client_1, dist_system_on_node_id))
        sort_on = str(read_input_value(
            plc_client_2, sort_system_on_node_id))
        new_all_system_on = 'true' if (dist_on == 'True'
                                       and sort_on == 'True') \
            else 'false'
        if old_all_system_on != new_all_system_on:
            publish_data("SYSTEM ON ALL", new_all_system_on)
            old_all_system_on = new_all_system_on
        time.sleep(update_time)


def stream_code_step_all():
    old_all_code_step = ''
    while True:
        code_step_number_1 = str(read_input_value(
            plc_client_1, dist_code_step_node_id))
        code_step_number_2 = str(read_input_value(
            plc_client_2, sort_code_step_node_id))
        new_all_code_step = (code_step_number_1 if int(code_step_number_1) <= 7
                             else '1' + code_step_number_2)
        new_all_code_step = (code_step_number_1 if int(code_step_number_1) <= 7
                             else '1' + code_step_number_2)
        if old_all_code_step != new_all_code_step:
            publish_data("CODE STEP ALL", new_all_code_step)
            old_all_code_step = new_all_code_step
        time.sleep(update_time)


if __name__ == '__main__':
    plc_client_1 = establish_opc_conn("6:10000")
    print('OPCUA CONNECTION TO PLC1 IS SUCCESSFUL')
    plc_client_2 = establish_opc_conn("5:20000")
    print('OPCUA CONNECTION TO PLC2 IS SUCCESSFUL')

    # mqtt connection
    client = paho.Client(client_id="VINCENT", userdata=None,
                         protocol=paho.MQTTv5)
    client.will_set(topic="REQUEST INIT", payload="terminated")
    client.tls_set(tls_version=mqtt.client.ssl.PROTOCOL_TLS)
    client.username_pw_set("Vincent Mworia", "mwendamworia")
    client.connect("8a32997794c84b92a769a6a46bb1582f.s1.eu.hivemq.cloud", 8883)

    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_message = on_message
    client.on_publish = on_publish

    thread_subscribe = threading.Thread(target=stream_subscription)
    thread_dist_code_step = threading.Thread(target=stream_code_step_dist)
    # thread_stream_init = threading.Thread(target=stream_init)
    thread_dist_manual_step = threading.Thread(target=stream_manual_step_dist)
    thread_dist_manual_auto_mode = threading.Thread(
        target=stream_manual_auto_mode_dist)
    thread_dist_system_on = threading.Thread(target=stream_system_on_dist)

    thread_sort_code_step = threading.Thread(target=stream_code_step_sort)
    thread_sort_manual_step = threading.Thread(target=stream_manual_step_sort)
    thread_sort_manual_auto_mode = threading.Thread(
        target=stream_manual_auto_mode_sort)
    thread_sort_system_on = threading.Thread(
        target=stream_system_on_sort)
    # thread_sort_workpiece_number = threading.Thread(
    #     target=stream_workpiece_number_sort)

    thread_all_system_on = threading.Thread(target=stream_system_on_all)
    thread_all_code_step = threading.Thread(target=stream_code_step_all)

    thread_subscribe.start()
    # thread_stream_init.start()

    thread_dist_code_step.start()
    thread_dist_manual_step.start()
    thread_dist_manual_auto_mode.start()
    thread_dist_system_on.start()

    thread_sort_code_step.start()
    thread_sort_manual_step.start()
    thread_sort_manual_auto_mode.start()
    thread_sort_system_on.start()
    # thread_sort_workpiece_number.start()

    thread_all_system_on.start()
    thread_all_code_step.start()
    print('THREADS INITIALIZATION SUCCESSFUL')
