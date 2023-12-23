#!/usr/bin/env python3

import subprocess
import time
import sys
from pyudev import Context, Monitor, MonitorObserver

# Global variable to keep track of the running process and device state
lnxrouter_process = None
device_connected = False

def device_event(device):
    global lnxrouter_process, device_connected

    if device.action == "add" and device.get('ID_VENDOR_ID') == '0cf3' and device.get('ID_MODEL_ID') == '9271':
        print("AR9271 chipset USB device connected. Activating WiFi AP.")
        device_connected = True
        start_lnxrouter()

    elif device.action == "remove" and device_connected:
        print("AR9271 chipset USB device removed.")
        device_connected = False
        stop_lnxrouter()

def start_lnxrouter():
    global lnxrouter_process
    print("Activating WiFi AP.")
    time.sleep(10)  # Wait for 10 seconds for the USB interface to be ready
    lnxrouter_process = subprocess.Popen(['sudo', '/usr/local/bin/lnxrouter'] + sys.argv[1:])

def stop_lnxrouter():
    global lnxrouter_process
    if lnxrouter_process:
        print("Stopping WiFi AP.")
        lnxrouter_process.terminate()
        lnxrouter_process = None

context = Context()

# Check for already connected devices at startup
for device in context.list_devices(subsystem='usb'):
    if device.get('ID_VENDOR_ID') == '0cf3' and device.get('ID_MODEL_ID') == '9271':
        print("AR9271 chipset USB device already connected.")
        device_connected = True
        start_lnxrouter()
        break

monitor = Monitor.from_netlink(context)
monitor.filter_by(subsystem='usb')
observer = MonitorObserver(monitor, callback=device_event, name='monitor-observer')
observer.start()

try:
    print("Listening for USB devices...")
    while True:
        pass
except KeyboardInterrupt:
    print("\nStopping USB monitor...")
    observer.send_stop()
    stop_lnxrouter()
