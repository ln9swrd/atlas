import toga
#import tkinter as tk
#from tkinter import *
#from toga.style import Pack
#from toga.style.pack import COLUMN

from main_view import build, button_setup_handler, button_test_handler
#from pyupbitpbit import * 
#from main_view import build
#from main_view import button_setup_handler, button_test_handler

#from dbconfig import connection_info






#root.mainloop()






def main():
    #app.main_loop()
    return toga.App('3GUpbit', 'com.3G.3GUpbit', startup=build)

if __name__ == '__main__':
    #main()
    main().main_loop()



#app = toga.App('Hide Menu Example', 'com.example.hidemenu', startup=build)
#app.main_loop()