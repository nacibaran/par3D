#pragma once

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QByteArray>
#include <QDataStream>

class VcuCommunication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)

    // Telemetry properties - QML'den okumak için
    Q_PROPERTY(float imuRoll    READ imuRoll    NOTIFY imuDataChanged)
    Q_PROPERTY(float imuPitch   READ imuPitch   NOTIFY imuDataChanged)
    Q_PROPERTY(int   mastAngle  READ mastAngle  NOTIFY mastDataChanged)

    Q_PROPERTY(int drivingBatteryVoltage READ drivingBatteryVoltage NOTIFY drivingBatteryChanged)
    Q_PROPERTY(int drivingBatteryCurrent READ drivingBatteryCurrent NOTIFY drivingBatteryChanged)
    Q_PROPERTY(int electronicBatteryVoltage READ electronicBatteryVoltage NOTIFY electronicBatteryChanged)
    Q_PROPERTY(int electronicBatteryCurrent READ electronicBatteryCurrent NOTIFY electronicBatteryChanged)
    Q_PROPERTY(bool vcuAlive READ vcuAlive NOTIFY vcuAliveChanged)


public:
    explicit VcuCommunication(QObject *parent = nullptr);
    ~VcuCommunication();

    bool isConnected() const { return m_connected; }

    float imuRoll()  const { return m_imuRoll; }
    float imuPitch() const { return m_imuPitch; }
    int   mastAngle() const { return m_mastAngle; }
    bool vcuAlive() const { return m_vcuAlive; }

    int drivingBatteryVoltage() const { return m_drivingVoltage; }
    int drivingBatteryCurrent() const { return m_drivingCurrent; }
    int electronicBatteryVoltage() const { return m_electronicVoltage; }
    int electronicBatteryCurrent() const { return m_electronicCurrent; }

    // ── Control ──────────────────────────────────────────
    Q_INVOKABLE void connect(const QString &ip = DEFAULT_IP, int port = DEFAULT_PORT);
    Q_INVOKABLE void disconnect();

    Q_INVOKABLE void setMastDrive(int command);
    Q_INVOKABLE void setRearPalDrive(int state);
    Q_INVOKABLE void setFrontPalDrive(int state);
    Q_INVOKABLE void setHeadlightFront(bool on, int brightness, int flash);
    Q_INVOKABLE void setHeadlightRear(bool on, int brightness, int flash);
    Q_INVOKABLE void setSomaLeft(bool on, int brightness, int flash);
    Q_INVOKABLE void setSomaRight(bool on, int brightness, int flash);
    Q_INVOKABLE void setIRFront(bool on);
    Q_INVOKABLE void setIRRear(bool on);
    Q_INVOKABLE void setCoolerFanSpeed(bool on);
    Q_INVOKABLE void setCoolerPumpSpeed(bool on);
    Q_INVOKABLE void setContactorState(bool on);
    Q_INVOKABLE void setEmergencyState(bool on);
    Q_INVOKABLE void setBrakeState(int brakePercent);
    Q_INVOKABLE void setCloseRobot(bool on);
    Q_INVOKABLE void setSmokeFireState(QList<int> firedIndexes);

    // ── Config ────────────────────────────────────────────
    Q_INVOKABLE void getAllConfiguration();

signals:
    void connectionStatusChanged(bool connected);
    void imuDataChanged();
    void mastDataChanged();
    void drivingBatteryChanged();
    void electronicBatteryChanged();
    void errorsReceived(const QString &errorType, const QStringList &errors);

    // Config signals
    void configBatteryNode1Data(bool state);
    void configBatteryNode2Data(bool state);
    void configBatteryNode3Data(bool state);
    void configImuData(bool state);
    void configMastData(bool state);
    void vcuAliveChanged(bool alive);

private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();
    void onSocketError(QAbstractSocket::SocketError err);
    void sendHeartbeat();
    void tryReconnect();

private:
    // ── Address constants ─────────────────────────────────
    static constexpr quint32 ID_DRIVE_MAST               = 0x1554210C;
    static constexpr quint32 ID_ROBOT_PAL_FRONT           = 0x1556670C;
    static constexpr quint32 ID_ROBOT_PAL_REAR            = 0x15566B0C;
    static constexpr quint32 ID_LIGHTNING_HEADLIGHT_FRONT = 0x1555240C;
    static constexpr quint32 ID_LIGHTNING_HEADLIGHT_REAR  = 0x1555280C;
    static constexpr quint32 ID_LIGHTNING_SOMA_LEFT       = 0x1555450C;
    static constexpr quint32 ID_LIGHTNING_SOMA_RIGHT      = 0x1555460C;
    static constexpr quint32 ID_LIGHTNING_IR_FRONT        = 0x1555670C;
    static constexpr quint32 ID_LIGHTNING_IR_REAR         = 0x15556B0C;
    static constexpr quint32 ID_COOLER_FAN                = 0x1556450C;
    static constexpr quint32 ID_COOLER_PUMP_NODE_1        = 0x1556A10C;
    static constexpr quint32 ID_SMOKE_FRONT_LEFT          = 0x1554450C;
    static constexpr quint32 ID_SMOKE_FRONT_RIGHT         = 0x1554460C;
    static constexpr quint32 ID_SMOKE_REAR_LEFT           = 0x1554490C;
    static constexpr quint32 ID_SMOKE_REAR_RIGHT          = 0x15554A0C;
    static constexpr quint32 ID_CONTACTOR                 = 0x1557410C;
    static constexpr quint32 ID_EMERGENCY_BUTTON          = 0x1556820C;
    static constexpr quint32 ID_BREAK_ALL                 = 0x1556240C;
    static constexpr quint32 ID_CLOSE_ROBOT               = 0x1556810C;
    static constexpr quint32 HEARTBEAT_MESSAGE_ADDRESS    = 0x15512000;

    static constexpr quint32 ERROR_ID_IMU_NODE_1               = 0x0C53210C;
    static constexpr quint32 ERROR_ID_BATTERY_ALL              = 0x0C53401A;
    static constexpr quint32 ERROR_ID_MAST                     = 0x0C54210C;
    static constexpr quint32 ERROR_ID_LIGHTNING_HEADLIGHT_ALL  = 0x0C55200C;
    static constexpr quint32 ERROR_ID_LIGHTNING_SOMA_ALL       = 0x0C55400C;
    static constexpr quint32 ERROR_ID_LIGHTNING_IR_ALL         = 0x0C55600C;
    static constexpr quint32 ERROR_ID_BRAKE_ALL                = 0x0C56240C;
    static constexpr quint32 ERROR_ID_ROBOT_FAN_NODE           = 0x0C56450C;

    static constexpr quint32 TELEMETRY_ID_DRIVE_MAST    = 0x1954201A;
    static constexpr quint32 TELEMETRY_ID_IMU           = 0x1953210C;
    static constexpr quint32 TELEMETRY_ID_HEARTBEAT     = 0x19512000;
    static constexpr quint32 TELEMETRY_ID_BATTERY_NODE1 = 0x1953410C;
    static constexpr quint32 TELEMETRY_ID_BATTERY_NODE2 = 0x1953420C;
    static constexpr quint32 TELEMETRY_ID_BATTERY_NODE3 = 0x1953430C;

    static constexpr quint32 CONFIG_GET_BATTERY_NODE_1  = 0x1E53410C;
    static constexpr quint32 CONFIG_GET_BATTERY_NODE_2  = 0x1E53420C;
    static constexpr quint32 CONFIG_GET_BATTERY_NODE_3  = 0x1E53430C;
    static constexpr quint32 CONFIG_GET_IMU             = 0x1E53210C;
    static constexpr quint32 CONFIG_GET_MAST            = 0x1E54210C;

    static constexpr quint32 CONFIG_READ_BATTERY_NODE_1 = 0x1F53410C;
    static constexpr quint32 CONFIG_READ_BATTERY_NODE_2 = 0x1F53420C;
    static constexpr quint32 CONFIG_READ_BATTERY_NODE_3 = 0x1F53430C;
    static constexpr quint32 CONFIG_READ_IMU            = 0x1F53210C;
    static constexpr quint32 CONFIG_READ_MAST           = 0x1F54210C;

    static constexpr quint32 CONFIG_WRITE_BATTERY_NODE_1 = 0x1D53410C;
    static constexpr quint32 CONFIG_WRITE_BATTERY_NODE_2 = 0x1D53420C;
    static constexpr quint32 CONFIG_WRITE_BATTERY_NODE_3 = 0x1D53430C;
    static constexpr quint32 CONFIG_WRITE_IMU            = 0x1D53210C;
    static constexpr quint32 CONFIG_WRITE_MAST           = 0x1D54210C;

    static constexpr int ADDRESS_SIZE        = 4;
    static constexpr int MAX_PAYLOAD_SIZE    = 8;
    static constexpr int HEARTBEAT_INTERVAL  = 500;
    static constexpr int RECONNECT_INTERVAL  = 3000;
    static constexpr int TIMEOUT_MS          = 5000;

    static constexpr quint8  MSG_ERROR      = 0x0C;
    static constexpr quint8  MSG_TELEMETRY  = 0x19;
    static constexpr quint8  MSG_RES_STATUS = 0x12;
    static constexpr quint8  MSG_CONFIG     = 0x1F;

    static constexpr const char* DEFAULT_IP   = "192.168.3.30"; // AppConfig'den al
    static constexpr int         DEFAULT_PORT  = 5000;

    QTimer *m_vcuAliveTimer = nullptr;
    bool    m_vcuAlive      = false;

    // ── State ─────────────────────────────────────────────
    QTcpSocket *m_socket = nullptr;
    bool        m_connected = false;
    bool        m_destroyed = false;
    QString     m_lastIp;
    int         m_lastPort = DEFAULT_PORT;

    QTimer *m_heartbeatTimer  = nullptr;
    QTimer *m_reconnectTimer  = nullptr;

    QByteArray m_receiveBuffer; // TCP stream fragmentation için

    // Telemetry cache
    float m_imuRoll = 0, m_imuPitch = 0;
    int   m_mastAngle = 0;
    int   m_drivingVoltage = 0, m_drivingCurrent = 0;
    int   m_electronicVoltage = 0, m_electronicCurrent = 0;

    // ── Helpers ───────────────────────────────────────────

    void resetHeartbeat();
    void sendData(quint32 address, const QByteArray &payload);
    void processReceivedData(QByteArray &data);
    void parseCANPayload(const QByteArray &packetData, int payloadLength);

    void parseErrorMsg(quint32 address, QDataStream &ds);
    void parseTelemetryMsg(quint32 address, QDataStream &ds);
    void parseConfigMsg(quint32 address, QDataStream &ds);

    void parseImuData(QDataStream &ds);
    void parseMastData(QDataStream &ds);
    void parseDrivingBattery(QDataStream &ds);
    void parseElectronicBattery(QDataStream &ds);

    void parseImuError(QDataStream &ds);
    void parseBatteryAllError(QDataStream &ds);
    void parseMastError(QDataStream &ds);
    void parseHeadlightError(QDataStream &ds);
    void parseSomaError(QDataStream &ds);
    void parseIrError(QDataStream &ds);
    void parseBrakeError(QDataStream &ds);

    void parseBatteryNode1Config(QDataStream &ds);
    void parseBatteryNode2Config(QDataStream &ds);
    void parseBatteryNode3Config(QDataStream &ds);
    void parseImuConfig(QDataStream &ds);
    void parseMastConfig(QDataStream &ds);

    static QByteArray makePayload8(
        quint8 b0=0,quint8 b1=0,quint8 b2=0,quint8 b3=0,
        quint8 b4=0,quint8 b5=0,quint8 b6=0,quint8 b7=0);
};
