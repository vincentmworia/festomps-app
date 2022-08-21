import time
import threading
import paho.mqtt.client as paho
from paho import mqtt


def on_connect(client_conn, userdata, flags, rc, properties=None):
print("CONNACK<Response> received with code %s." % rc)


def on_publish(client_pub, userdata, mid, properties=None):
print("mid: " + str(mid))


def on_subscribe(client_sub, userdata, mid, granted_qos, properties=None):
print("Subscribed: " + str(mid) + " " + str(granted_qos))


def on_message(client_msg, userdata, msg):
topic = str(msg.topic)
payload = str(msg.payload)
print('asdf')

print(topic)
print(payload)

if topic == 'REQUEST INIT' and payload == 'b\'true\'':
client.publish("CODE STEP DISTRIBUTION",
payload=read_plc1_state()['code_step'], qos=1)
client.publish("MANUAL STEP DISTRIBUTION",
payload=read_plc1_state()['manual_step'], qos=1)
client.publish("MANUAL AUTO MODE DISTRIBUTION",
payload=read_plc1_state()['manual_auto_mode'], qos=1)
client.publish("SYSTEM ON DISTRIBUTION",
payload=read_plc1_state()['system_on'], qos=1)

client.publish("CODE STEP SORTING",
payload=read_plc2_state()['code_step'], qos=1)
client.publish("MANUAL STEP SORTING",
payload=read_plc2_state()['manual_step'], qos=1)
client.publish("MANUAL AUTO MODE SORTING",
payload=read_plc2_state()['manual_auto_mode'], qos=1)
client.publish("SYSTEM ON SORTING",
payload=read_plc2_state()['system_on'], qos=1)

client.publish("SYSTEM ON ALL",
payload='true' if (
read_plc1_state()['system_on'] == 'true' and read_plc2_state()['system_on'] == 'true') else 'false', qos=1)
code_step_number_1 = read_plc1_state()['code_step']

code_step_number_2 = read_plc2_state()['code_step']
client.publish("CODE STEP ALL",
payload=code_step_number_1 if int(
code_step_number_1) <= 7 else '1' + code_step_number_2, qos=1)

if topic == 'START DISTRIBUTION' and payload == 'b\'true\'':
print('start dist')

time.sleep(1)
print('revert')

if topic == 'STOP DISTRIBUTION' and payload == 'b\'true\'':
print('stop dist')
time.sleep(1)
print('revert')

if topic == 'RESET DISTRIBUTION' and payload == 'b\'true\'':
print('reset dist')
time.sleep(1)
print('revert')

if topic == 'START SORTING' and payload == 'b\'true\'':
print('start sorting')
time.sleep(1)
print('revert')

if topic == 'STOP SORTING' and payload == 'b\'true\'':
print('stop sorting')
time.sleep(1)
print('revert')

if topic == 'RESET SORTING' and payload == 'b\'true\'':
print('reset sorting')
time.sleep(1)
print('revert')

if topic == 'START ALL' and payload == 'b\'true\'':
print('start all')
time.sleep(1)
print('revert')

if topic == 'STOP ALL' and payload == 'b\'true\'':
print('stop all')
time.sleep(1)
print('revert')

if topic == 'RESET ALL' and payload == 'b\'true\'':
print('reset all')
time.sleep(1)
print('revert')

# client.publish("BUTTON STATE",
#                payload="TRUE", qos=1)


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


# cities = ['NAIROBI', 'MOMBASA', 'KISUMU', 'NAKURU', 'MERU', 'THIKA', 'KISII']
# states = ['KANSAS', 'VIRGINIA', 'LAS VEGAS',
#           'LOS ANGELOS', 'DUBAI', 'OHIO', 'FLORIDA', 'PHOENIX']
client = paho.Client(client_id="VINCENT", userdata=None, protocol=paho.MQTTv5)
client.on_connect = on_connect

client.tls_set(tls_version=mqtt.client.ssl.PROTOCOL_TLS)
client.username_pw_set("Vincent Mworia", "mwendamworia")
client.connect("8a32997794c84b92a769a6a46bb1582f.s1.eu.hivemq.cloud", 8883)

client.on_subscribe = on_subscribe
client.on_message = on_message
client.on_publish = on_publish


def subscription():
quality = 1
client.subscribe([('REQUEST INIT', quality), ("START DISTRIBUTION", quality),
("STOP DISTRIBUTION", quality), ("RESET DISTRIBUTION",
quality), ("START SORTING", quality),
("STOP SORTING", quality), ("RESET SORTING",
quality), ("START ALL", quality),
("STOP ALL", quality), ("RESET ALL", quality), ], qos=1)
client.loop_forever()


plc1 = read_plc1_state()
plc2 = read_plc2_state()
dist_code_step = plc1['code_step']
dist_manual_step = plc1['manual_step']
manual_auto_mode = plc1['manual_auto_mode']
dist_system_on = plc1['system_on']

sort_code_step = plc2['code_step']
sort_manual_step = plc2['manual_step']
sort_auto_mode = plc2['manual_auto_mode']
sort_system_on = plc2['system_on']
sort_workpiece = plc2['workpiece']


update_time = 0.001


def stream_code_step_dist():
old_dist_code_step = ''
while True:
new_dist_code_step = read_plc1_state()['code_step']
time.sleep(update_time)
if old_dist_code_step != new_dist_code_step:
client.publish("CODE STEP DISTRIBUTION",
payload=new_dist_code_step, qos=1)
old_dist_code_step = new_dist_code_step


def stream_manual_step_dist():
old_dist_manual_step = ''
while True:
new_dist_manual_step = read_plc1_state()['manual_step']
time.sleep(update_time)
if old_dist_manual_step != new_dist_manual_step:
client.publish("MANUAL STEP DISTRIBUTION",
payload=new_dist_manual_step, qos=1)
old_dist_manual_step = new_dist_manual_step


def stream_manual_auto_mode_dist():
old_dist_manual_auto = ''
while True:
new_dist_manual_auto = read_plc1_state()['manual_auto_mode']
time.sleep(update_time)
if old_dist_manual_auto != new_dist_manual_auto:
client.publish("MANUAL AUTO MODE DISTRIBUTION",
payload=new_dist_manual_auto, qos=1)
old_dist_manual_auto = new_dist_manual_auto


def stream_system_on_dist():
old_dist_system_on = ''
while True:
new_dist_system_on = read_plc1_state()['system_on']
time.sleep(update_time)
if old_dist_system_on != new_dist_system_on:
client.publish("SYSTEM ON DISTRIBUTION",
payload=new_dist_system_on, qos=1)
old_dist_system_on = new_dist_system_on


def stream_code_step_sort():
old_sort_code_step = ''
while True:
new_sort_code_step = read_plc2_state()['code_step']
time.sleep(update_time)
if old_sort_code_step != new_sort_code_step:
client.publish("CODE STEP SORTING",
payload=new_sort_code_step, qos=1)
old_sort_code_step = new_sort_code_step


def stream_manual_step_sort():
old_sort_manual_step = ''
while True:
new_sort_manual_step = read_plc2_state()['manual_step']
time.sleep(update_time)
if old_sort_manual_step != new_sort_manual_step:
client.publish("MANUAL STEP SORTING",
payload=new_sort_manual_step, qos=1)
old_sort_manual_step = new_sort_manual_step


def stream_manual_auto_mode_sort():
old_sort_manual_auto = ''
while True:
new_sort_manual_auto = read_plc2_state()['manual_auto_mode']
time.sleep(update_time)
if old_sort_manual_auto != new_sort_manual_auto:
client.publish("MANUAL AUTO MODE SORTING",
payload=new_sort_manual_auto, qos=1)
old_sort_manual_auto = new_sort_manual_auto


def stream_system_on_sort():
old_sort_system_on = ''
while True:
new_sort_system_on = read_plc2_state()['system_on']
time.sleep(update_time)
if old_sort_system_on != new_sort_system_on:
client.publish("SYSTEM ON SORTING",
payload=new_sort_system_on, qos=1)
old_sort_system_on = new_sort_system_on


def stream_system_on_all():
old_all_system_on = ''
while True:
new_all_system_on = 'true' if (
read_plc1_state()['system_on'] == 'true' and read_plc2_state()['system_on'] == 'true') else 'false'
time.sleep(update_time)
if old_all_system_on != new_all_system_on:
client.publish("SYSTEM ON ALL",
payload=new_all_system_on, qos=1)
old_all_system_on = new_all_system_on


def stream_code_step_all():
old_all_code_step = ''
while True:
code_step_number_1 = read_plc1_state()['code_step']

code_step_number_2 = read_plc2_state()['code_step']

new_all_code_step = code_step_number_1 if int(
code_step_number_1) <= 7 else '1' + code_step_number_2
time.sleep(update_time)
if old_all_code_step != new_all_code_step:
client.publish("CODE STEP ALL",
payload=new_all_code_step, qos=1)
old_all_code_step = new_all_code_step


if __name__ == '__main__':

thread_subscribe = threading.Thread(target=subscription)
thread_dist_code_step = threading.Thread(target=stream_code_step_dist)
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
# thread_sort_workpiece = threading.Thread(target=stream_workpiece_sort)

thread_all_system_on = threading.Thread(target=stream_system_on_all)
thread_all_code_step = threading.Thread(target=stream_code_step_all)

thread_subscribe.start()

thread_dist_code_step.start()
thread_dist_manual_step.start()
thread_dist_manual_auto_mode.start()
thread_dist_system_on.start()

thread_sort_code_step.start()
thread_sort_manual_step.start()
thread_sort_manual_auto_mode.start()
thread_sort_system_on.start()
# thread_sort_workpiece.start()

thread_all_system_on.start()
thread_all_code_step.start()
print('init successful')
