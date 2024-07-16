from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Signal, Slot
from datetime import date, datetime


from database import Database

class modelPersonal(QAbstractListModel):

    MAP = []

    ID = Qt.UserRole + 1
    NAME = Qt.UserRole + 2
    POS = Qt.UserRole + 3
    START = Qt.UserRole + 4
    END = Qt.UserRole + 5

    error = Signal(str, arguments=['error'])


    def __init__(self, parent=None):
        super().__init__(parent)
        self.BASE = Database("PERS")
        self.load()


    def rowCount(self, parent=QModelIndex()):
        return len(self.MAP)


    def columnCount(self, parent=QModelIndex()):
        return 5


    def data(self, index, role=Qt.DisplayRole):
        col = index.column()
        if len(self.MAP) > 0:
            map = self.MAP[index.row()]
            
            if role == self.ID:
                return map["id"]
            if role == self.NAME:
                return map["name"]
            if role == self.POS:
                return  map["pos"]
            if role == self.START:
                return date.fromordinal(int(map['start'])).strftime("%d.%m.%Y")
            if role == self.END:
                if map['end'] == 0:
                    return str()
                else:
                    return date.fromordinal(int(map['end'])).strftime("%d.%m.%Y")
        
        return None
    
    
    def roleNames(self):
        return {
            self.ID: b"pk",
            self.NAME: b"name",
            self.POS: b"pos",
            self.START: b"start",
            self.END: b"end",
        }
    
    def load(self):
        self.beginResetModel()
        self.MAP.clear()
        res = self.BASE.db_get(table=Database.T_PERSONAL)
        if res['r']:
            self.MAP = res['data']
        else:
            self.error.emit(res['message'])
        self.endResetModel()

    @Slot(dict, result = bool)
    def saveCard(self, card:dict):
        if card['name']:
            if card['pos']:
                if card['start']:
                    ds = datetime.strptime(card["start"], "%d.%m.%Y").toordinal()
                    if card["end"]:
                        de = datetime.strptime(card['end'], "%d.%m.%Y").toordinal()
                    else:
                        de = 0
                    
                    card["start"] = ds
                    card["end"] = de

                    print("card :", card)

                    res = self.BASE.db_save(card, Database.T_PERSONAL)

                    if res['r']:
                        self.load()
                        return True
                    else:
                        self.error.emit(res['message'])
                        return False
                else:
                    self.error.emit("No start")
                    return False
            else:
                self.error.emit("No pos")
                return False
        else:
            self.error.emit("No name")
            return False
    
    @Slot(int, result=dict)
    def getCard(self, idx:int):

        card = self.MAP[idx]
        ds = date.fromordinal(int(card['start'])).strftime("%d.%m.%Y")
        if card['end'] == 0:
            de = ""
        else:
            de = date.fromordinal(int(card['end'])).strftime("%d.%m.%Y")

        card["start"] = ds
        card["end"] = de
        return card
    
    @Slot(int, result=bool)
    def delCard(self, idx:int):
        res = self.BASE.db_del(idx, Database.T_PERSONAL)
        print(res)
        if res['r']:
            self.load()
            return True
        else:
            self.error.emit(res['message'])
            return False


