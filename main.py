import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

from csv_controller import CSVController


def main() -> int:
    app = QApplication(sys.argv)

    # Disponibiliza CSVController no QML via: import App 1.0
    qmlRegisterType(CSVController, "App", 1, 0, "CSVController")

    engine = QQmlApplicationEngine()
    qml_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "main.qml")
    engine.load(qml_path)

    if not engine.rootObjects():
        print("Erro: não foi possível carregar a interface QML.")
        return 1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())