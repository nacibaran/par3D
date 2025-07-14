#include "serialreceiver.h"
#include <QDebug>
#include <QtEndian>

SerialReceiver::SerialReceiver(QObject *parent)
    : QObject(parent)
{
    connect(&serial, &QSerialPort::readyRead, this, &SerialReceiver::handleReadyRead);
    connect(&serial, &QSerialPort::errorOccurred, this, &SerialReceiver::handleError);
    connect(&reconnectTimer, &QTimer::timeout, this, &SerialReceiver::attemptReconnect);
    reconnectTimer.setInterval(1000); // 1 saniyede bir yeniden dene .// Cihaz usb cihazından önce devreye girerse diye timer ekledik. Her saniye bağlantı deneyecek.
}

void SerialReceiver::start(const QString &portName, int baudRate) {
    lastPortName = portName;
    lastBaudRate = baudRate;

    serial.setPortName(portName);
    serial.setBaudRate(baudRate);

    if (!serial.open(QIODevice::ReadOnly)) {
        qWarning() << "Port açılamadı:" << portName << ", yeniden denenecek...";
        reconnectTimer.start();
    } else {
        qDebug() << "Port başarıyla açıldı:" << portName;
        reconnectTimer.stop();
    }
}

void SerialReceiver::attemptReconnect() {
    if (!serial.isOpen()) {
        qDebug() << "Porta yeniden bağlanılıyor...";
        start(lastPortName, lastBaudRate);
    }
}

void SerialReceiver::handleError(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::ResourceError || error == QSerialPort::DeviceNotFoundError) {
        qWarning() << "Port bağlantısı kesildi. Yeniden bağlanma denenecek.";
        serial.close();
        reconnectTimer.start();
    }
}

void SerialReceiver::handleReadyRead() {
    buffer.append(serial.readAll());

    while (buffer.size() >= 10) {
        qint16 deg1 = qFromLittleEndian<qint16>((const uchar*)buffer.constData());
        qint16 deg2 = qFromLittleEndian<qint16>((const uchar*)(buffer.constData() + 2));
        qint16 length = qFromLittleEndian<qint16>((const uchar*)(buffer.constData() + 4));
        qint16 imuX = qFromLittleEndian<qint16>((const uchar*)(buffer.constData() + 6));
        qint16 imuY = qFromLittleEndian<qint16>((const uchar*)(buffer.constData() + 8));

        emit dataReceived(deg1, deg2, length, imuX, imuY);

        buffer.remove(0, 10);
    }
}
