# Blending Images
# ------------------------------------------
# Работа с бд
# ------------------------------------------

from PySide6.QtCore import QObject, QDate
from PySide6.QtSql import QSqlDatabase, QSqlQuery

from helpers import Helpers

class Database(QObject):

    connection_name: str

    T_PERSONAL = 'Personal'
    T_SHEDULE = 'Shedule'

    SHEDULE_ALL = 11


    def __init__(self, conn: str, parent = None):
        super().__init__(parent)
        self.connection_name = conn
        self.message_error_connect = "Нет соединения с базой данных"
        self.connectDB()


    def connectDB(self):
        db = QSqlDatabase.addDatabase('QSQLITE', self.connection_name)
        db.setDatabaseName("base.db3")
        db.open()
        if db.isOpen():
            qstr = [
                "CREATE TABLE IF NOT EXISTS Personal (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, pos TEXT, start INTEGER, end INTEGER)",
                "CREATE TABLE IF NOT EXISTS Shedule (id INTEGER PRIMARY KEY AUTOINCREMENT, personal INTEGER, testdate INTEGER, testtype STRING, reason TEXT)",
            ]
            for q in qstr:
                query = QSqlQuery(q, db)
                query.exec()

    # GENERAL FUNCTION

    # получение данных
    def db_get(self, table: str, filter = None):
        db = QSqlDatabase.database(self.connection_name)
        
        if db.isOpen():
            data = []
            if table == self.T_PERSONAL:
                qstr = "SELECT * FROM Personal WHERE Personal.id > '0' ORDER BY Personal.start "

            if table == self.T_SHEDULE:
                qstr = ''' SELECT Shedule.*, Personal.name as personalName, Personal.pos as personalPos  
                FROM Shedule 
                INNER JOIN Personal ON Personal.id = Shedule.personal 
                WHERE Shedule.id > \'0\' 
                ORDER BY Shedule.testdate '''

            query = QSqlQuery(qstr, db)            
            while query.next():
                d = {}
                for i in range(0, query.record().count()):
                    field = query.record().field(i)
                    d[field.name()] = query.value(i)

                data.append(d)
            return {'r':True, 'message':"", 'data':data}
        else:
            return {'r':False, 'message':self.message_error_connect, 'data':[]}

    # сохранение данных
    def db_save(self, card: dict, table:str):
        db = QSqlDatabase.database(self.connection_name)
        if db.isOpen():
            id = card.get('id')
            if id == 0:

                if table == self.T_PERSONAL:
                    qstr = "INSERT INTO Personal (name, pos, start, end) VALUES (?, ?, ?, ?)"
                    query = QSqlQuery(qstr, db)
                    query.bindValue(0, card.get('name'))
                    query.bindValue(1, card.get('pos'))
                    query.bindValue(2, card.get('start'))
                    query.bindValue(3, card.get('end'))
                
                if table == self.T_SHEDULE:
                    qstr = "INSERT INTO Shedule (personal, testdate, testtype, reason) VALUES (?, ?, ?, ?)"
                    query = QSqlQuery(qstr, db)
                    query.bindValue(0, card.get('personal'))
                    query.bindValue(1, card.get('testdate'))
                    query.bindValue(2, card.get('testtype'))
                    query.bindValue(3, card.get('reason'))

                r = query.exec()
                if r:
                    return {'r':r, 'message':'', 'id':int(query.lastInsertId()),}
                else:
                    return {'r':r, 'message':query.lastError().text(), 'id':0,}
            elif id > 0:

                if table == self.T_PERSONAL:
                    qstr = f'''UPDATE Personal SET name = \'{card.get("name")}\', pos = \'{card.get("pos")}\', 
                    start = \'{card.get("start")}\', end = \'{card.get("end")}\' WHERE Personal.id = \'{id}\' '''
                
                if table == self.T_SHEDULE:
                    qstr = f'''UPDATE Shedule SET personal = \'{card.get("personal")}\', testdate = \'{card.get("testdate")}\', 
                    testtype = \'{card.get("testtype")}\', reason = \'{card.get("reason")}\' WHERE Shedule.id = \'{id}\' '''

                query = QSqlQuery(qstr, db)
                r = query.exec()
                if r:
                    return {'r':r, 'message':'', 'id':id,}
                else:
                    return {'r':r, 'message':query.lastError().text(), 'id':0,}
        else:
            return {'r':False, 'message':self.message_error_connect,}



    # удаление данных
    def db_del(self, id: int, table: str, param: int = 0):
        db = QSqlDatabase.database(self.connection_name)
        if db.isOpen():
            if table == self.T_PERSONAL:            
                qstr = f"DELETE FROM Shedule WHERE Shedule.personal > \'{id}\'"
                query = QSqlQuery(qstr, db)
                r = query.exec()
                if r:
                    qstr = f"DELETE FROM Personal WHERE Personal.id = \'{id}\';"
                else:
                    return {'r': False, 'message': query.lastError().text}

            if table == self.T_SHEDULE:               

                if param == self.SHEDULE_ALL:
                    qstr = f'''DELETE FROM Shedule WHERE Shedule.id > \'0\'
                    AND (Shedule.testtype = \'{Helpers.TTYPES.value[0]}\' OR Shedule.testtype = \'{Helpers.TTYPES.value[1]}\') '''
                else:
                    qstr = f"DELETE FROM Shedule WHERE Shedule.id = \'{id}\' "
                    
            
            query = QSqlQuery(qstr, db)
            r = query.exec()
            if r:
                message = "Operation successful."
            else:
                message = query.lastError().text()
            return {'r': r, 'message': message}
        else:
            return {'r': False, 'message': self.message_error_connect}


    