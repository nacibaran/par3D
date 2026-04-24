#include "vcucommunication.h"
#include <QTcpSocket>
#include <QDataStream>
#include <QDebug>
#include <QtEndian>
#include <cmath>

// ── Constructor / Destructor ──────────────────────────────

VcuCommunication::VcuCommunication(QObject *parent) : QObject(parent)
{
    m_socket = new QTcpSocket(this);
    QObject::connect(m_socket, &QTcpSocket::connected,    this, &VcuCommunication::onConnected);
    QObject::connect(m_socket, &QTcpSocket::disconnected, this, &VcuCommunication::onDisconnected);
    QObject::connect(m_socket, &QTcpSocket::readyRead,    this, &VcuCommunication::onReadyRead);
    QObject::connect(m_socket, &QAbstractSocket::errorOccurred,this, &VcuCommunication::onSocketError);

    m_heartbeatTimer = new QTimer(this);
    m_heartbeatTimer->setInterval(HEARTBEAT_INTERVAL);
    QObject::connect(m_heartbeatTimer, &QTimer::timeout, this, &VcuCommunication::sendHeartbeat);

    m_reconnectTimer = new QTimer(this);
    m_reconnectTimer->setSingleShot(true);
    m_reconnectTimer->setInterval(RECONNECT_INTERVAL);
    QObject::connect(m_reconnectTimer, &QTimer::timeout, this, &VcuCommunication::tryReconnect);



    m_vcuAliveTimer = new QTimer(this);
    m_vcuAliveTimer->setSingleShot(true);
    m_vcuAliveTimer->setInterval(1000); // 1 saniye
    QObject::connect(m_vcuAliveTimer, &QTimer::timeout, this, [this]() {if (m_vcuAlive) {m_vcuAlive = false;emit vcuAliveChanged(false);}});


}

VcuCommunication::~VcuCommunication()
{
    m_destroyed = true;
    disconnect();
}

// ── Public connect / disconnect ───────────────────────────

void VcuCommunication::connect(const QString &ip, int port)
{
    if (m_destroyed) return;
    m_lastIp   = ip;
    m_lastPort = port;

    m_reconnectTimer->stop();
    m_heartbeatTimer->stop();
    m_socket->abort();
    m_receiveBuffer.clear();

    m_socket->connectToHost(ip, static_cast<quint16>(port));
}

void VcuCommunication::disconnect()
{
    m_destroyed = true;
    m_reconnectTimer->stop();
    m_heartbeatTimer->stop();
    m_socket->abort();
}

// ── Socket slots ─────────────────────────────────────────

void VcuCommunication::onConnected()
{
    m_connected = true;
    m_reconnectTimer->stop();
    m_heartbeatTimer->start();
    emit connectionStatusChanged(true);
    qDebug() << "[VcuCommunication] Connected";
}

void VcuCommunication::onDisconnected()
{
    m_connected = false;
    m_heartbeatTimer->stop();
    emit connectionStatusChanged(false);
    qDebug() << "[VcuCommunication] Disconnected";
    if (!m_destroyed) m_reconnectTimer->start();
}

void VcuCommunication::onSocketError(QAbstractSocket::SocketError /*err*/)
{
    qWarning() << "[VcuCommunication] Socket error:" << m_socket->errorString();
    if (!m_connected && !m_destroyed && !m_reconnectTimer->isActive())
        m_reconnectTimer->start();
}

void VcuCommunication::tryReconnect()
{
    if (m_destroyed || m_connected || m_lastIp.isEmpty()) return;
    qDebug() << "[VcuCommunication] Reconnecting...";
    connect(m_lastIp, m_lastPort);
}

void VcuCommunication::sendHeartbeat()
{
    sendData(HEARTBEAT_MESSAGE_ADDRESS, makePayload8());
}

// ── Read ─────────────────────────────────────────────────

void VcuCommunication::onReadyRead()
{
    m_receiveBuffer.append(m_socket->readAll());
    processReceivedData(m_receiveBuffer);
}

// ── Protocol parsing ─────────────────────────────────────

void VcuCommunication::processReceivedData(QByteArray &data)
{
    int offset = 0;

    while (offset < data.size()) {
        quint8 headerByte = static_cast<quint8>(data.at(offset));

        // Header prefix kontrolü: üst 4 bit 0x8 olmalı
        if ((headerByte & 0xF0) != 0x80) {
            offset++;
            continue;
        }

        int payloadLength = headerByte & 0x0F;
        int packetSize    = 1 + ADDRESS_SIZE + payloadLength;

        // Yeterli veri gelmediyse bekle (TCP fragmentation)
        if (offset + packetSize > data.size()) break;

        QByteArray packetData = data.mid(offset + 1, ADDRESS_SIZE + payloadLength);
        parseCANPayload(packetData, payloadLength);

        offset += packetSize;
    }

    // İşlenen kısmı buffer'dan temizle
    data.remove(0, offset);
}

void VcuCommunication::parseCANPayload(const QByteArray &packetData, int payloadLength)
{
    if (packetData.size() < ADDRESS_SIZE) return;

    // Adres: Big-Endian 4 byte
    quint32 address = qFromBigEndian<quint32>(
        reinterpret_cast<const uchar*>(packetData.constData()));

    quint8 msgType = static_cast<quint8>((address >> 24) & 0xFF);

    // Payload: Little-Endian
    QByteArray payload = packetData.mid(ADDRESS_SIZE, payloadLength);
    QDataStream ds(payload);
    ds.setByteOrder(QDataStream::LittleEndian);



    switch (msgType) {
    case MSG_ERROR:      parseErrorMsg(address, ds);     break;
    case MSG_TELEMETRY:  parseTelemetryMsg(address, ds); break;
    case MSG_CONFIG:     parseConfigMsg(address, ds);    break;
    default: break;
    }
}

// ── Telemetry ─────────────────────────────────────────────

void VcuCommunication::parseTelemetryMsg(quint32 address, QDataStream &ds)
{
    switch (address) {
    case TELEMETRY_ID_HEARTBEAT:    resetHeartbeat();  break;
    case TELEMETRY_ID_IMU:           parseImuData(ds);         break;
    case TELEMETRY_ID_DRIVE_MAST:    parseMastData(ds);        break;
    case TELEMETRY_ID_BATTERY_NODE1: parseDrivingBattery(ds);  break;
    case TELEMETRY_ID_BATTERY_NODE2: parseElectronicBattery(ds); break;
    default: break;
    }
}

void VcuCommunication::parseImuData(QDataStream &ds)
{
    qint16 roll, pitch;
    ds >> roll >> pitch;
    m_imuRoll  = static_cast<float>(roll);
    m_imuPitch = static_cast<float>(pitch);
    emit imuDataChanged();
}

void VcuCommunication::parseMastData(QDataStream &ds)
{
    qint8 angle;
    ds >> angle;
    m_mastAngle = angle;
    emit mastDataChanged();
}

void VcuCommunication::parseDrivingBattery(QDataStream &ds)
{
    qint32 v, c;
    ds >> v >> c;
    m_drivingVoltage = v;
    m_drivingCurrent = c;
    emit drivingBatteryChanged();
}

void VcuCommunication::parseElectronicBattery(QDataStream &ds)
{
    qint32 v_mV, c_mA;
    ds >> v_mV >> c_mA;
    m_electronicVoltage = static_cast<int>(
        std::round((std::max(21000, std::min(v_mV, 29400)) - 21000) / 8400.0f * 100.0f));
    m_electronicCurrent = c_mA;
    emit electronicBatteryChanged();
}

// ── Error messages ────────────────────────────────────────

void VcuCommunication::parseErrorMsg(quint32 address, QDataStream &ds)
{
    switch (address) {
    case ERROR_ID_IMU_NODE_1:              parseImuError(ds);       break;
    case ERROR_ID_BATTERY_ALL:             parseBatteryAllError(ds);break;
    case ERROR_ID_MAST:                    parseMastError(ds);      break;
    case ERROR_ID_LIGHTNING_HEADLIGHT_ALL: parseHeadlightError(ds); break;
    case ERROR_ID_LIGHTNING_SOMA_ALL:      parseSomaError(ds);      break;
    case ERROR_ID_LIGHTNING_IR_ALL:        parseIrError(ds);        break;
    case ERROR_ID_BRAKE_ALL:               parseBrakeError(ds);     break;
    case ERROR_ID_ROBOT_FAN_NODE:
        emit errorsReceived("ROBOT_FAN", {});
        break;
    default: break;
    }
}

void VcuCommunication::parseImuError(QDataStream &ds)
{
    quint8 b; ds >> b;
    QStringList errs;
    if (b & 0x01) errs << "ERR_IMU_COMM_FAIL";
    if (b & 0x02) errs << "ERR_IMU_SELF_TEST_FAIL";
    if (b & 0x04) errs << "ERR_IMU_GYRO_FAULT";
    if (b & 0x08) errs << "ERR_IMU_ACCEL_FAULT";
    if (b & 0x10) errs << "ERR_IMU_MAG_FAULT";
    if (b & 0x20) errs << "ERR_IMU_TEMP_FAULT";
    if (b & 0x40) errs << "ERR_IMU_TIMESTAMP_DRIFT";
    if (b & 0x80) errs << "ERR_IMU_UNKNOWN";
    emit errorsReceived("IMU", errs);
}

void VcuCommunication::parseBatteryAllError(QDataStream &ds)
{
    quint8 n1, n2, n3; ds >> n1 >> n2 >> n3;
    QStringList errs;
    if (n1) errs << "BATTERY_NODE_1_ERROR";
    if (n2) errs << "BATTERY_NODE_2_ERROR";
    if (n3) errs << "BATTERY_NODE_3_ERROR";
    emit errorsReceived("BATTERY_NODES", errs);
}

void VcuCommunication::parseMastError(QDataStream &ds)
{
    quint8 b; ds >> b;
    QStringList errs;
    if (b & 0x01) errs << "ERR_MAST_COMM_FAIL";
    if (b & 0x80) errs << "ERR_MAST_UNKNOWN";
    emit errorsReceived("MAST", errs);
}

void VcuCommunication::parseHeadlightError(QDataStream &ds)
{
    quint8 b; ds >> b;
    QStringList errs;
    if (b & 0x01) errs << "P_HEADLIGHT_FRONT_LEFT_ERROR";
    if (b & 0x02) errs << "P_HEADLIGHT_FRONT_RIGHT_ERROR";
    if (b & 0x04) errs << "P_HEADLIGHT_REAR_LEFT_ERROR";
    if (b & 0x08) errs << "P_HEADLIGHT_REAR_RIGHT_ERROR";
    emit errorsReceived("HEADLIGHT", errs);
}

void VcuCommunication::parseSomaError(QDataStream &ds)
{
    quint8 fl, fr, rl, rr; ds >> fl >> fr >> rl >> rr;
    QStringList errs;
    if (fl) errs << "P_SOMA_FRONT_LEFT_ERROR";
    if (fr) errs << "P_SOMA_FRONT_RIGHT_ERROR";
    if (rl) errs << "P_SOMA_REAR_LEFT_ERROR";
    if (rr) errs << "P_SOMA_REAR_RIGHT_ERROR";
    emit errorsReceived("SOMA", errs);
}

void VcuCommunication::parseIrError(QDataStream &ds)
{
    quint8 front, rear; ds >> front >> rear;
    QStringList errs;
    if (front) errs << "P_IR_FRONT_ERROR";
    if (rear)  errs << "P_IR_REAR_ERROR";
    emit errorsReceived("IR", errs);
}

void VcuCommunication::parseBrakeError(QDataStream &ds)
{
    quint8 fr, fl; ds >> fr >> fl;
    QStringList errs;
    if (fr) errs << "P_BRAKE_FRONT_RIGHT_ERROR";
    if (fl) errs << "P_BRAKE_FRONT_LEFT_ERROR";
    emit errorsReceived("BRAKE", errs);
}

// ── Config ────────────────────────────────────────────────

void VcuCommunication::parseConfigMsg(quint32 address, QDataStream &ds)
{
    switch (address) {
    case CONFIG_READ_BATTERY_NODE_1: parseBatteryNode1Config(ds); break;
    case CONFIG_READ_BATTERY_NODE_2: parseBatteryNode2Config(ds); break;
    case CONFIG_READ_BATTERY_NODE_3: parseBatteryNode3Config(ds); break;
    case CONFIG_READ_IMU:            parseImuConfig(ds);          break;
    case CONFIG_READ_MAST:           parseMastConfig(ds);         break;
    default: break;
    }
}

void VcuCommunication::parseBatteryNode1Config(QDataStream &ds)
{ quint8 v; ds >> v; emit configBatteryNode1Data(v != 0); }

void VcuCommunication::parseBatteryNode2Config(QDataStream &ds)
{ quint8 v; ds >> v; emit configBatteryNode2Data(v != 0); }

void VcuCommunication::parseBatteryNode3Config(QDataStream &ds)
{ quint8 v; ds >> v; emit configBatteryNode3Data(v != 0); }

void VcuCommunication::parseImuConfig(QDataStream &ds)
{ quint8 v; ds >> v; emit configImuData(v != 0); }

void VcuCommunication::parseMastConfig(QDataStream &ds)
{ quint8 v; ds >> v; emit configMastData(v != 0); }

void VcuCommunication::getAllConfiguration()
{
    QByteArray empty = makePayload8();
    sendData(CONFIG_GET_BATTERY_NODE_1, empty);
    sendData(CONFIG_GET_BATTERY_NODE_2, empty);
    sendData(CONFIG_GET_BATTERY_NODE_3, empty);
    sendData(CONFIG_GET_MAST, empty);
    sendData(CONFIG_GET_IMU,  empty);
}

// ── Control setters ───────────────────────────────────────

void VcuCommunication::setMastDrive(int command)
{ sendData(ID_DRIVE_MAST, makePayload8(command)); }

void VcuCommunication::setRearPalDrive(int state)
{ sendData(ID_ROBOT_PAL_REAR, makePayload8(state)); }

void VcuCommunication::setFrontPalDrive(int state)
{ sendData(ID_ROBOT_PAL_FRONT, makePayload8(state)); }

void VcuCommunication::setHeadlightFront(bool on, int brightness, int flash)
{ sendData(ID_LIGHTNING_HEADLIGHT_FRONT, makePayload8(on?1:0, brightness, flash)); }

void VcuCommunication::setHeadlightRear(bool on, int brightness, int flash)
{ sendData(ID_LIGHTNING_HEADLIGHT_REAR, makePayload8(on?1:0, brightness, flash)); }

void VcuCommunication::setSomaLeft(bool on, int brightness, int flash)
{ sendData(ID_LIGHTNING_SOMA_LEFT, makePayload8(on?1:0, brightness, flash)); }

void VcuCommunication::setSomaRight(bool on, int brightness, int flash)
{ sendData(ID_LIGHTNING_SOMA_RIGHT, makePayload8(on?1:0, brightness, flash)); }

void VcuCommunication::setIRFront(bool on)
{ sendData(ID_LIGHTNING_IR_FRONT, makePayload8(on?1:0)); }

void VcuCommunication::setIRRear(bool on)
{ sendData(ID_LIGHTNING_IR_REAR, makePayload8(on?1:0)); }

void VcuCommunication::setCoolerFanSpeed(bool on)
{ sendData(ID_COOLER_FAN, makePayload8(on?100:0)); }

void VcuCommunication::setCoolerPumpSpeed(bool on)
{ sendData(ID_COOLER_PUMP_NODE_1, makePayload8(on?100:0)); }

void VcuCommunication::setContactorState(bool on)
{ sendData(ID_CONTACTOR, makePayload8(on?1:0)); }

void VcuCommunication::setEmergencyState(bool on)
{ sendData(ID_EMERGENCY_BUTTON, makePayload8(on?1:0)); }

void VcuCommunication::setBrakeState(int brakePercent)
{
    qDebug() << "[VcuCommunication] setBrakeState ->" << brakePercent;

    sendData(ID_BREAK_ALL, makePayload8(brakePercent, brakePercent));  }

void VcuCommunication::setCloseRobot(bool on)
{ sendData(ID_CLOSE_ROBOT, makePayload8(!on?1:0)); }

void VcuCommunication::setSmokeFireState(QList<int> firedIndexes)
{
    for (int idx : firedIndexes) {
        quint32 addr = 0;
        switch(idx) {
        case 0: addr = ID_SMOKE_FRONT_LEFT;  break;
        case 1: addr = ID_SMOKE_FRONT_RIGHT; break;
        case 2: addr = ID_SMOKE_REAR_LEFT;   break;
        case 3: addr = ID_SMOKE_REAR_RIGHT;  break;
        default: continue;
        }
        sendData(addr, makePayload8(0x46));
    }
}

// ── sendData ──────────────────────────────────────────────

void VcuCommunication::sendData(quint32 address, const QByteArray &payload)
{
    if (!m_connected || !m_socket) return;

    int actualLen = std::min(static_cast<int>(payload.size()), MAX_PAYLOAD_SIZE);
    quint8 header = static_cast<quint8>(0x80 | actualLen);

    QByteArray packet;
    packet.reserve(1 + ADDRESS_SIZE + actualLen);
    packet.append(static_cast<char>(header));

    // Address: Big-Endian
    packet.append(static_cast<char>((address >> 24) & 0xFF));
    packet.append(static_cast<char>((address >> 16) & 0xFF));
    packet.append(static_cast<char>((address >>  8) & 0xFF));
    packet.append(static_cast<char>( address        & 0xFF));

    packet.append(payload.left(actualLen));

    m_socket->write(packet);
    m_socket->flush();
}

// ── Helper ────────────────────────────────────────────────

QByteArray VcuCommunication::makePayload8(
    quint8 b0, quint8 b1, quint8 b2, quint8 b3,
    quint8 b4, quint8 b5, quint8 b6, quint8 b7)
{
    QByteArray ba(8, 0);
    ba[0]=b0; ba[1]=b1; ba[2]=b2; ba[3]=b3;
    ba[4]=b4; ba[5]=b5; ba[6]=b6; ba[7]=b7;
    return ba;
}

void VcuCommunication::resetHeartbeat(){ qDebug("pass");  m_vcuAliveTimer->start(); if (!m_vcuAlive) {m_vcuAlive = true;emit vcuAliveChanged(true);}}


