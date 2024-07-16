from PySide6.QtCore import QObject, Property
from datetime import date

from helpers import Helpers

class helpersWrapper(QObject):

    def __init__(self, parent = None):
        super().__init__(parent)
    

    @Property(list, constant=True)
    def testTypes(self):
        return Helpers.TTYPES.value
    
    @Property(int, constant=True)
    def interval(self):
        return Helpers.INTERVAL.value
    
    @Property(str, constant=True)
    def currentDate(self):
        return date.today().strftime("%d.%m.%Y")