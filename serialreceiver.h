#pragma once

#include <QObject>
#include <QSerialPort>
#include <QTimer>

class SerialReceiver : public QObject
{
    Q_OBJECT
public:
    explicit SerialReceiver(QObject *parent = nullptr);

    Q_INVOKABLE void start(const QString &portName, int baudRate = 115200);

signals:
    void dataReceived(int deg1, int deg2, int length, int imuX, int imuY);

private slots:
    void handleReadyRead();
    void attemptReconnect();
    void handleError(QSerialPort::SerialPortError error);

private:
    QSerialPort serial;
    QByteArray buffer;

    QString lastPortName;
    int lastBaudRate;

    QTimer reconnectTimer;
};
