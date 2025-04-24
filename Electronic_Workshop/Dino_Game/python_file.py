import subprocess   
import time
import pyautogui
import serial



subprocess.call([r'firefox', '-new-tab', 'https://chromedino.com/'])  


#time.sleep(6)                 	#give a short time to open and setup all.
print("All set :\)")

ser = serial.Serial('/dev/ttyACM0')		#Update with your arduino [port]
ser.baudrate = '9600'			#set baudRate

while True:
    h1=ser.readline() 			#reading serial data. 
    if h1:
      ss = int(h1.decode('utf-8')) # decode and make a int value
    if ss== 1:					# true while obstacle. 
      #print("Oh :< Jump!! ")
      pyautogui.press('space')

# while True:						# looping. 
#   h1=ser.readline() 			#reading serial data. 
#   if h1:
#    ss = int(h1.decode('utf-8')) # decode and make a int value
#    if ss== 1:					# true while obstacle. 
#       print("Oh :< Jump!! ")
#       pyautogui.press('up') 		#Auto press [UP] key