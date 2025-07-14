#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "serialreceiver.h" // SerialReceiver sınıfının header dosyası

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Oluştur
    SerialReceiver receiver;

    // QML tarafına context property olarak ekle
    engine.rootContext()->setContextProperty("serialReceiver", &receiver);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Burada loadFromModule yerine resource ile yükleme yapabilirsin.
    // Senin modül yapına göre değişebilir.
    engine.loadFromModule("par3D", "Main");

    // Eğer yüklenen obje yoksa çık
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
