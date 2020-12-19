#!/usr/bin/python

#import RPi.GPIO as GPIO
import logging, time, json, sys, subprocess, os
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
#from blinkt import set_clear_on_exit, set_brightness, set_pixel, show

thingname = "lebkuchenhaus1"
broker = "..."

rootCAPath = "root-CA.crt"
certificatePath = thingname + ".cert.pem"
privateKeyPath = thingname + ".private.key"

# init relais and set them to off to be consistent!
#GPIO.setwarnings(False)
#GPIO.setmode(GPIO.BCM)
#GPIO.setup(22, GPIO.OUT)
#GPIO.output(22, GPIO.LOW)
#GPIO.setup(23, GPIO.OUT)
#GPIO.output(23, GPIO.LOW)

state = {"lights": {"r": 10, "g": 10, "b": 10, "brightness": 0.05}, "memory": {}, "relais": {"relais1": "off", "relais2": "off"}, "sensors": {}}

# set_clear_on_exit(False)

# Configure logging
logger = logging.getLogger("AWSIoTPythonSDK.core")
#logger.setLevel(logging.DEBUG)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)


def getState():

    global state

    temperatureFile = open("/sys/class/thermal/thermal_zone0/temp", "r")
    temperature = float(temperatureFile.read(5))
    temperatureFile.close()
    state['temperature'] = round(temperature/1000, 1)

    uptimeProcess = subprocess.Popen(['uptime'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = uptimeProcess.communicate()
    uptime = stdout.splitlines()[0]
    uptimeLoad = uptime.split(',  load average: ')
    state['uptime'] = uptimeLoad[0]
    state['load'] = uptimeLoad[1]

    memoryFile = open("/proc/meminfo", "r")
    memory = memoryFile.read().splitlines()
    memoryFile.close
    state['memory']['total'] = int(memory[0].split()[1])/1000
    state['memory']['free'] = int(memory[1].split()[1])/1000
    state['memory']['available'] = int(memory[2].split()[1])/1000

    state['sensors']['sensor1'] = 0
    state['sensors']['sensor2'] = 0
    #state['sensors']['sensor1'] = getTemperature('...')
    #state['sensors']['sensor2'] = getTemperature('...')

    message = {"state": {"reported": state}}

    return json.dumps(message)


def getTemperature(sensorID):
    sensorFile = open("/sys/bus/w1/devices/"+ sensorID +"/temperature", "r")
    sensorValue = float(sensorFile.read())
    temperature = round(sensorValue/1000, 1)
    sensorFile.close()
    return temperature


def setColor():

    global state

    ### blinkt! 8x RGB LED Modul
    #set_brightness(state["lights"]["brightness"])

    #for pixel in range(8):

        #set_pixel(pixel, state["lights"]["r"], state["lights"]["g"], state["lights"]["b"])

    #show()

    ### blink(1) USB LED Modul
    #os.popen('echo ' + str(state["lights"]["r"]) + ' | sudo tee /sys/class/leds/thingm0\:red\:led0/brightness')
    #os.popen('echo ' + str(state["lights"]["r"]) + ' | sudo tee /sys/class/leds/thingm0\:red\:led1/brightness')
    #os.popen('echo ' + str(state["lights"]["g"]) + ' | sudo tee /sys/class/leds/thingm0\:green\:led0/brightness')
    #os.popen('echo ' + str(state["lights"]["g"]) + ' | sudo tee /sys/class/leds/thingm0\:green\:led1/brightness')
    #os.popen('echo ' + str(state["lights"]["b"]) + ' | sudo tee /sys/class/leds/thingm0\:blue\:led0/brightness')
    #os.popen('echo ' + str(state["lights"]["b"]) + ' | sudo tee /sys/class/leds/thingm0\:blue\:led1/brightness')


def publishState():

    global thingname
    global MQQTclient

    message = getState()
    topic = "$aws/things/" + thingname + "/shadow/update"
    MQTTclient.publish(topic, message, 0)
    print(message + " > " + topic)


def processMessage(client, userdata, message):

    global state

    response = json.loads(message.payload)['state']

    print(message.topic + " > " + json.dumps(response))


    if "lights" in response:

        if "brightness" in response["lights"]:

            state["lights"]["brightness"] = response["lights"]["brightness"]

        if "r" in response["lights"]:

            state["lights"]["r"] = response["lights"]["r"]

        if "g" in response["lights"]:

            state["lights"]["g"] = response["lights"]["g"]

        if "b" in response["lights"]:

            state["lights"]["b"] = response["lights"]["b"]

        setColor()


    if "relais" in response:

        if "relais1" in response["relais"]:

            print("setting relais1 to " + response["relais"]["relais1"])

            #if state["relais"]["relais1"] == 'on':
    
                #GPIO.output(22, GPIO.LOW)
    
            #elif state["relais"]["relais1"] == 'off':
    
                #GPIO.output(22, GPIO.HIGH)

            state["relais"]["relais1"] = response["relais"]["relais1"]

        if "relais2" in response["relais"]:

            print("setting relais2 to " + response["relais"]["relais2"])

            #if state["relais"]["relais2"] == 'on':

                #GPIO.output(23, GPIO.LOW)

            #elif state["relais"]["relais2"] == 'off':

                #GPIO.output(23, GPIO.HIGH)

            state["relais"]["relais2"] = response["relais"]["relais2"]


    publishState()


MQTTclient = None
MQTTclient = AWSIoTMQTTClient(thingname)
MQTTclient.configureEndpoint(broker, 8883)
MQTTclient.configureCredentials(rootCAPath, privateKeyPath, certificatePath)
MQTTclient.configureAutoReconnectBackoffTime(1, 32, 20)
MQTTclient.configureOfflinePublishQueueing(-1)  # Infinite offline Publish queueing
MQTTclient.configureDrainingFrequency(2)  # Draining: 2 Hz
MQTTclient.configureConnectDisconnectTimeout(10)  # 10 sec
MQTTclient.configureMQTTOperationTimeout(5)  # 5 sec

MQTTclient.connect()
MQTTclient.subscribe("$aws/things/" + thingname + "/shadow/update/delta", 1, processMessage)


setColor()

while True:
    publishState()
    time.sleep(60)