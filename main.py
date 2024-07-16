import sys
from pathlib import Path
from os import environ

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

import modelPersonal
import modelShedule
import helpersWrapper
import resources_rc

if __name__ == "__main__":

    environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    QQuickStyle.setStyle("Material")

    mPersonal = modelPersonal.modelPersonal()
    engine.rootContext().setContextProperty("modelPersonal", mPersonal)

    mShedule = modelShedule.modelShedule()
    engine.rootContext().setContextProperty("modelShedule", mShedule)

    hw = helpersWrapper.helpersWrapper()
    engine.rootContext().setContextProperty("helpers", hw)
    
    engine.load(Path(__file__).parent / "qml/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())