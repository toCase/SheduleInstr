from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Signal, Slot, QUrl
from datetime import date, datetime
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Side, Border, Alignment

from database import Database
from helpers import Helpers

class modelShedule(QAbstractListModel):
    MAP = []
    
    ID = Qt.UserRole + 1
    TESTDATE = Qt.UserRole + 2
    TESTTYPE = Qt.UserRole + 3
    NAME = Qt.UserRole + 4
    CLR = Qt.UserRole + 5
    REASON = Qt.UserRole + 6

    error = Signal(str, arguments=['error'])

    def __init__(self, parent=None):
        super().__init__(parent)
        self.BASE = Database("SHED")
        self.load()
    
    def rowCount(self, parent=QModelIndex()):
        return len(self.MAP)

    def columnCount(self, parent=QModelIndex()):
        return 4
    
    def data(self, index, role=Qt.DisplayRole):
        col = index.column()
        if len(self.MAP) > 0:
            map = self.MAP[index.row()]
            
            if role == self.ID:
                return map["id"]
            if role == self.NAME:
                return map["personalName"]
            if role == self.TESTDATE:
                return  date.fromordinal(int(map['testdate'])).strftime("%d.%m.%Y")
            if role == self.TESTTYPE:
                return map["testtype"]
            if role == self.CLR:
                clr:str = "transparent"
                if map["testtype"] == Helpers.TTYPES.value[0]:
                    clr = "#f4c430"
                elif map["testtype"] == Helpers.TTYPES.value[1]:
                    clr = "#f9e6bc"
                elif map["testtype"] == Helpers.TTYPES.value[2]:
                    clr = "#D7BCE2"
                elif map["testtype"] == Helpers.TTYPES.value[3]:
                    clr = "#c7e2bc"
                return clr
            if role == self.REASON:
                return map['reason']
        return None
    
    def roleNames(self):
        return {
            self.ID: b"pk",
            self.NAME: b"personal",
            self.TESTDATE: b"testdate",
            self.TESTTYPE: b"testtype",
            self.CLR: b"clr",
            self.REASON: b"reason",
        }
    
    @Slot()
    def load(self):
        self.beginResetModel()

        self.MAP.clear()
        res = self.BASE.db_get(table=Database.T_SHEDULE)
        if res['r']:
            self.MAP = res['data']
        else:
            self.error.emit(res['message'])

        self.endResetModel()
    
    @Slot(int, result=dict)
    def getCard(self, idx:int):
        card = self.MAP[idx]
        td = date.fromordinal(int(card['testdate'])).strftime("%d.%m.%Y")        
        card["testdate"] = td
        return card
    
    @Slot(int, result=bool)
    def delCard(self, idx:int):
        res = self.BASE.db_del(idx, Database.T_SHEDULE)
        print(res)
        if res['r']:
            self.load()
            return True
        else:
            self.error.emit(res['message'])
            return False
    
    @Slot(dict, result = bool)
    def saveCard(self, card:dict):
        if card['personal']:
            if card['testtype']:
                if card['testdate']:
                    ds = datetime.strptime(card["testdate"], "%d.%m.%Y").toordinal()                    
                    
                    card["testdate"] = ds
                    print("card :", card)

                    res = self.BASE.db_save(card, Database.T_SHEDULE)

                    if res['r']:
                        self.load()
                        return True
                    else:
                        self.error.emit(res['message'])
                        return False
                else:
                    self.error.emit("No test date")
                    return False
            else:
                self.error.emit("No test type")
                return False
        else:
            self.error.emit("No personal")
            return False
    
    @Slot(dict, result=bool)
    def generateShedule(self, params:dict):

        interval = int(params["interval"])
        fd = datetime.strptime('01.01.2000', "%d.%m.%Y").toordinal() 
        td = datetime.strptime(params["to"], "%d.%m.%Y").toordinal()
        
        #clear shedule        
        res_d = self.BASE.db_del(1, self.BASE.T_SHEDULE, self.BASE.SHEDULE_ALL)
        if res_d['r'] == False:
            self.error.emit(f"ERROR GEN DEL: {res_d['message']}")
            return False

        res_p = self.BASE.db_get(Database.T_PERSONAL)
        if res_p['r']:
            people = res_p['data']
            for card in people:
                personalID = card['id']
                start = card['start']
                end = card['end']

                if end == 0:
                    end = td
                else:
                    if td < end:
                        end = td
                
                for x in range(start, end, interval):
                    testDate = date.fromordinal(x)
                    if testDate.weekday() == 5:
                        testDate = date.fromordinal(x +  2)
                        if (x + 2) >= end:
                            testDate = date.fromordinal(x - 1)
                    elif testDate.weekday() == 6:
                        testDate = date.fromordinal(x + 1)
                        if (x + 1) >= end:
                            testDate = date.fromordinal(x - 2)
                    
                    if x == start:
                        testtype = Helpers.TTYPES.value[0]
                    else:
                        testtype = Helpers.TTYPES.value[1]

                    if testDate.toordinal() >= fd:
                        testcard = {
                            "personal": personalID,
                            "testdate": testDate.toordinal(),
                            "testtype": testtype,
                            "id": 0,
                            "reason": "",
                        }

                        res_s = self.BASE.db_save(testcard, self.BASE.T_SHEDULE)
                        if res_s['r'] == False:
                            self.error.emit(f"ERROR GEN SAVING: {res_s['message']}")
                            return False

            self.load()
            return True

        else:
            self.error.emit(f"ERROR GENERATION: {res_p['message']}")
            return False
    
    @Slot(QUrl, result=bool)
    def makeXLS(self, fileName:QUrl):
        file = QUrl(fileName).toLocalFile()
        print("file: ", file)

        workbook = load_workbook(filename="template.xlsx")
        sheet = workbook.active

        borderSide = Side(border_style="thin")
        cellBorder = Border(borderSide, borderSide, borderSide, borderSide)
        alignHCenter = Alignment(horizontal="center")

        columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']

        row:int = 4
        for card in self.MAP:  
            sheet[f"A{row}"] = row - 3            
            sheet[f"B{row}"] = date.fromordinal(int(card['testdate'])).strftime("%d.%m.%Y")
            sheet[f'C{row}'] = card['personalName']            
            sheet[f'D{row}'] = card['personalPos']
            sheet[f'E{row}'] = card['testtype']
            sheet[f'F{row}'] = card['reason']
            sheet[f"G{row}"] = "Борщов С.А."

            for col in columns:
                sheet[f'{col}{row}'].border = cellBorder
                sheet[f'{col}{row}'].alignment = alignHCenter

            row += 1
        workbook.save(filename=file)
        return True




    