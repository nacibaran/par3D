#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "vcucommunication.h"
#include "thememanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Menü uygulama renk ve benzeri tema ayarlar erişimi için QML'e Erişim verdik -->
    ThemeManager* themeManager = new ThemeManager(qApp);
    engine.rootContext()->setContextProperty("themeManager", themeManager);


    VcuCommunication vcuCommunication;
    vcuCommunication.connect("192.168.3.30", 2005); // varsayılan IP/port ile bağlan

    engine.rootContext()->setContextProperty("vcuCommunication", &vcuCommunication);





    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("par3D", "Main");
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
