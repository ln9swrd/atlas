'''
Created on 2023. 10. 29.

@author: ln9swrd
'''
#from dbconfig import connection_info
import toga
from toga.style.pack import Pack, COLUMN
#from tkinter import *
from dbconfig import connection_info
#from Upbit import upbit_exp

import tkinter as tk

import jwt
import hashlib
import os
import requests
import uuid
from urllib.parse import urlencode, unquote
import pyupbit
from django.core.checks.security.base import _check_secret_key


def build(app):
    # 메인 윈도우 생성
    #main_box = toga.Box(style=Pack(direction=COLUMN))
    
    app.main_window = toga.MainWindow(title='3GUpbit', size=(540, 960))
    
    
    #window = toga.MainWindow(title='3GUpbit', size=(540, 960))    
    
    
    #content = toga.Box()
    #window.content = content
    #app.main_window.content = content
    
    main_box = toga.Box(style=Pack(direction=COLUMN, padding_top=50))
    #main_box = toga.Box(style=toga.style.Pack(direction=toga.style.COLUMN, padding_top=50))
    

    window1 = toga.Window(title='창 1', size=(200, 200))
    window2 = toga.Window(title='창 2', size=(200, 200))
    
    
    # Create the buttons
    button1 = toga.Button('Open Window 1', on_press=open_window1)
    button2 = toga.Button('Open Window 2', on_press=open_window2)




    
    
    # 버튼 생성
    button_test = toga.Button('upbit', on_press=button_test_handler)
    main_box.add(button_test)    
    
    # 버튼을 메인 윈도우에 추가
    # 기어 아이콘 생성
    #gear_icon = toga.Icon('resources/icon/gear-1294576_1280.png')
    #gear_image = toga.Image('resources/icon/gear-1294576_1280.png')
    
    
    #main_box = toga.Box(style=Pack(direction=COLUMN, padding_top=50))
    settings_icon = "resources/icon/gear-1294576_1280.png"

    toolbar_grp = toga.Group('Toolbar')

    settings_cmd = toga.Command(
        settings_action,
        label='Settings',
        tooltip='Change Settings',
        # shortcut=toga.Key.MOD_1 + 'k',
        icon=settings_icon,
        group=toolbar_grp
    )


    #button_setup = toga.Button('설정', on_press=button_setup_handler, icon=gear_image)
    #button_setup = toga.Button('설정', on_press=button_setup_handler, icon=settings_icon)
    button_setup = toga.Button('설정', on_press=button_setup_handler)
    #button_setup.image = gear_image
    main_box.add(button_setup)        
    
    
    # Add the buttons to a box
    button_box = toga.Box(children=[button1, button2])
    button_box = toga.Box(children=[button1, button2])
    #app.main_window.content = button_box

    

    app.commands.add(settings_cmd)
    app.main_window.toolbar.add(settings_cmd)
    
    # Add the box to the main window
    app.main_window.content = button_box
    
    
    #app.main_window.toolbar.hidden = True
    app.connection_info = connection_info()    

    # 메인 윈도우를 앱에 추가
    #app.main_window = toga.MainWindow(title='설정', content=main_box)
    
    #app.main_window = toga.MainWindow(title='설정화면', size=(540, 960))    
    #main_window = toga.MainWindow(title='설정화면', size=(540, 960))

    # Add the main box to the main window
    #main_window.content = main_box

    # Set the main window as the app's main window
    #app.main_window = main_window
    #app.main_window = toga.MainWindow(title='Toga 버튼에 기어 아이콘 적용', content=main_box)
    #app.main_window = toga.MainWindow(title='Toga 버튼에 기어 아이콘 적용')    
    #app.main_window = main_window
    
    
    app.main_window = toga.MainWindow(title='3GUpbit', size=(540, 960))

    main_box = toga.Box(style=Pack(direction=COLUMN, padding_top=50))

    button_test = toga.Button('upbit', on_press=button_test_handler)
    button_setup = toga.Button('설정', on_press=button_setup_handler)

    button_box = toga.Box(children=[button_test, button_setup])
    app.main_window.content = button_box
    
    return main_box

def button_test_handler(widget):
    # Access the connection_info object from the app instance
    connection_info = widget.app.connection_info

    # Access the database connection information
    database_host = connection_info.database_host
    database_port = connection_info.database_port
    database_username = connection_info.database_username
    database_password = connection_info.database_password
    database_name = connection_info.database_name
    
    
    access_key = connection_info.upbit_access_key
    secret_key = connection_info.upbit_secret_key
    server_url = 'https://api.upbit.com'

    # Print the database connection information
    #print(database_host)
    #print(database_port)
    #print(database_username)
    #print(database_password)
    #print(database_name)
    
    #print(access_key)
    #print(secret_key)
    #print(server_url)
    
    '''
    payload = {
        'access_key' : access_key,
        'nonce' : str(uuid.uuid4()),
        }

    jwt_token = jwt.encode(payload, secret_key)
    autohorization = 'Bearer {}'.format(jwt_token)
    headers = {
        'Autohorization' : autohorization,
        }
    
    res = requests.get(server_url + '/v1/accounts', headers=headers)
    data = res.json()
    
    if isinstance(data, dict):
        # 딕셔너리 타입인 경우 처리
        currency = data.get('currency')
        balance = data.get('balance')
        locked = data.get('locked')
    
        if balance is None:
            print("잘못된 잔고 값입니다.")
        elif float(balance) == 0:
            print(currency, locked)
        elif float(balance) > 0.0001:
            print(currency, balance)
    else:
        # 데이터가 올바른 형식이 아닌 경우 처리
        print('잘못된 데이터 형식입니다.')
    '''
    
    '''
    url = 'https://api.upbit.com/v1/market/all?Details=false'
    headers = {"accept" : "application/json"}
    response = requests.get(url, headers=headers)
    
    for row in response.json():
        korean_name = row.get('korean_name')
        market = row.get('market')
        
        print(market, korean_name)

    '''
    
    '''
    import jwt
    import hashlib
    import os
    import requests
    import uuid
    from urllib.parse import urlencode, unquote
    
    
    #access_key = os.environ['UPBIT_OPEN_API_ACCESS_KEY']
    #secret_key = os.environ['UPBIT_OPEN_API_SECRET_KEY']
    #server_url = os.environ['UPBIT_OPEN_API_SERVER_URL']
    
    
    payload = {
        'access_key': access_key,
        'nonce': str(uuid.uuid4()),
    }
    
    jwt_token = jwt.encode(payload, secret_key)
    authorization = 'Bearer {}'.format(jwt_token)
    headers = {
      'Authorization': authorization,
    }
    
    #res = requests.get(server_url + '/v1/accounts', params=params, headers=headers)
    res = requests.get(server_url + '/v1/accounts', headers=headers)
    res.json()    
    print(res)
    '''
   
def open_window1(widget):
    window1 = toga.Window(title='Window 1', size=(200, 200))
    window1.show()

def open_window2(widget):
    window2 = toga.Window(title='Window 2', size=(200, 200))
    window2.show()

def button_setup_handler(widget):
    # Add your variable setup logic here
    print("setup")    
    
def settings_action(widget):
    print("toolbar")
        