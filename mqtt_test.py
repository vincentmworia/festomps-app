import time
import threading
import paho.mqtt.client as paho
from paho import mqtt
from file_data import *


# todo temporary read values from external file


def on_connect(client_conn, userdata, flags, rc, properties=None):
    publish_data('REQUEST INIT', 'true')


def on_publish(client_pub, userdata, mid, properties=None):
    print("publish mid: " + str(mid))


def on_subscribe(client_sub, userdata, mid, granted_qos, properties=None):
    print("Subscribed: " + str(mid) + " " + str(granted_qos))


def on_message(client_msg, userdata, msg):
    topic = str(msg.topic)
    payload = str(msg.payload)
    delay = 0.2
    # print(topic)

    if topic == 'REQUEST INIT' and payload == 'b\'true\'':
        print('request init successful')

        publish_data("CODE STEP DISTRIBUTION", dist_code_step())
        publish_data("MANUAL STEP DISTRIBUTION", dist_manual_step())
        publish_data("MANUAL AUTO MODE DISTRIBUTION", dist_manual_auto_mode())
        publish_data("SYSTEM ON DISTRIBUTION", dist_system_on())

        publish_data("CODE STEP SORTING", sort_code_step() +
                     ':' + sort_workpiece()+':'+sort_workpiece_black() +
                     ':' + sort_workpiece_metallic() +
                     ':' + sort_workpiece_red() +
                     ':' + sort_workpiece_total())
        publish_data("MANUAL STEP SORTING", sort_manual_step())
        publish_data("MANUAL AUTO MODE SORTING", sort_manual_auto_mode())
        publish_data("SYSTEM ON SORTING", sort_system_on())
        publish_data("WORKPIECE COUNT", sort_workpiece_black() +
                     ':' + sort_workpiece_metallic() +
                     ':' + sort_workpiece_red() +
                     ':' + sort_workpiece_total())

        publish_data("SYSTEM ON ALL", all_system_on())
        publish_data("CODE STEP ALL", all_code_step())

    if topic == 'START DISTRIBUTION' and payload == 'b\'true\'':
        print('start dist')
        time.sleep(delay)
        print('revert')

    if topic == 'STOP DISTRIBUTION' and payload == 'b\'true\'':
        print('stop dist')
        time.sleep(delay)
        print('revert')

    if topic == 'RESET DISTRIBUTION' and payload == 'b\'true\'':
        print('reset dist')
        time.sleep(delay)
        print('revert')

    if topic == 'START SORTING' and payload == 'b\'true\'':
        print('start sorting')
        time.sleep(delay)
        print('revert')

    if topic == 'STOP SORTING' and payload == 'b\'true\'':
        print('stop sorting')
        time.sleep(delay)
        print('revert')

    if topic == 'RESET SORTING' and payload == 'b\'true\'':
        print('reset sorting')
        time.sleep(delay)
        print('revert')

    if topic == 'START ALL' and payload == 'b\'true\'':
        print('start all')
        time.sleep(delay)
        print('revert')

    if topic == 'STOP ALL' and payload == 'b\'true\'':
        print('stop all')
        time.sleep(delay)
        print('revert')

    if topic == 'RESET ALL' and payload == 'b\'true\'':
        print('reset all')
        time.sleep(delay)
        print('revert')


quality = 1


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
        new_dist_code_step = dist_code_step()
        if old_dist_code_step != new_dist_code_step:
            publish_data("CODE STEP DISTRIBUTION",  new_dist_code_step)
            old_dist_code_step = new_dist_code_step
        time.sleep(update_time)


def stream_manual_step_dist():
    old_dist_manual_step = ''
    while True:
        new_dist_manual_step = dist_manual_step()
        if old_dist_manual_step != new_dist_manual_step:
            publish_data("MANUAL STEP DISTRIBUTION", new_dist_manual_step)
            old_dist_manual_step = new_dist_manual_step
        time.sleep(update_time)


def stream_manual_auto_mode_dist():
    old_dist_manual_auto = ''
    while True:
        new_dist_manual_auto = dist_manual_auto_mode()
        if old_dist_manual_auto != new_dist_manual_auto:
            publish_data("MANUAL AUTO MODE DISTRIBUTION", new_dist_manual_auto)
            old_dist_manual_auto = new_dist_manual_auto
        time.sleep(update_time)


def stream_system_on_dist():
    old_dist_system_on = ''
    while True:
        new_dist_system_on = dist_system_on()
        if old_dist_system_on != new_dist_system_on:
            publish_data("SYSTEM ON DISTRIBUTION", new_dist_system_on)
            old_dist_system_on = new_dist_system_on
        time.sleep(update_time)


def stream_code_step_sort():
    old_sort_code_step = ''
    while True:
        new_sort_code_step = sort_code_step()
        if old_sort_code_step != new_sort_code_step:
            publish_data("CODE STEP SORTING",
                         new_sort_code_step + ':' + sort_workpiece()+':'+sort_workpiece_black() +
                         ':' + sort_workpiece_metallic() +
                         ':' + sort_workpiece_red() +
                         ':' + sort_workpiece_total()
                         )
            old_sort_code_step = new_sort_code_step
        time.sleep(update_time)


def stream_manual_step_sort():
    old_sort_manual_step = ''
    while True:
        new_sort_manual_step = sort_manual_step()
        if old_sort_manual_step != new_sort_manual_step:
            publish_data("MANUAL STEP SORTING", new_sort_manual_step)
            old_sort_manual_step = new_sort_manual_step
        time.sleep(update_time)


def stream_manual_auto_mode_sort():
    old_sort_manual_auto = ''
    while True:
        new_sort_manual_auto = sort_manual_auto_mode()
        if old_sort_manual_auto != new_sort_manual_auto:
            publish_data("MANUAL AUTO MODE SORTING", new_sort_manual_auto)
            old_sort_manual_auto = new_sort_manual_auto
        time.sleep(update_time)


def stream_system_on_sort():
    old_sort_system_on = ''
    while True:
        new_sort_system_on = sort_system_on()
        if old_sort_system_on != new_sort_system_on:
            publish_data("SYSTEM ON SORTING", new_sort_system_on)
            old_sort_system_on = new_sort_system_on
        time.sleep(update_time)


# def stream_init():
#     publish_data("REQUEST INIT", 'APP ALIVE')


def stream_system_on_all():
    old_all_system_on = ''
    while True:
        new_all_system_on = all_system_on()
        if old_all_system_on != new_all_system_on:
            publish_data("SYSTEM ON ALL", new_all_system_on)
            old_all_system_on = new_all_system_on
        time.sleep(update_time)


def stream_code_step_all():
    old_all_code_step = ''
    while True:
        new_all_code_step = all_code_step()
        if old_all_code_step != new_all_code_step:
            publish_data("CODE STEP ALL", new_all_code_step)
            old_all_code_step = new_all_code_step
        time.sleep(update_time)


if __name__ == '__main__':
    # mqtt connection
    client = paho.Client(client_id="VINCENT", userdata=None,
                         protocol=paho.MQTTv5)
    client.will_set(topic="REQUEST INIT", payload="terminated")
    # client.birth
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
    print('init successful')
