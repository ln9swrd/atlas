
import configparser

class connection_info():
    #def __init__(self, database_host, database_port, database_username, database_password, database_name):
    def __init__(self):    
        config = configparser.ConfigParser()
        config.read('config.ini')

        # DB 연결 정보 읽기
        self.database_host = config.get('database', 'host')
        self.database_port = config.get('database', 'port')
        self.database_username = config.get('database', 'username')
        self.database_password = config.get('database', 'password')
        self.database_name = config.get('database', 'database')
        
        self.upbit_access_key = config.get('upbit', 'access_key')
        self.upbit_secret_key = config.get('upbit', 'secret_key')
        #self.upbit_server_url = config.get('upbit', 'server_url')