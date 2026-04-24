#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QColor>
#include <QJsonObject>

class ThemeManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QColor dividerColor READ dividerColor NOTIFY themeChanged)
    Q_PROPERTY(QColor orangeColor READ orangeColor NOTIFY themeChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY themeChanged)
    Q_PROPERTY(QColor borderColor READ borderColor NOTIFY themeChanged)
    Q_PROPERTY(QColor lightGrayColor READ lightGrayColor NOTIFY themeChanged)
    Q_PROPERTY(QColor whiteColor READ whiteColor NOTIFY themeChanged)
    Q_PROPERTY(QColor textColor READ textColor NOTIFY themeChanged)
    Q_PROPERTY(QColor blackColor READ blackColor NOTIFY themeChanged)
    Q_PROPERTY(QColor greenColor READ greenColor NOTIFY themeChanged)
    Q_PROPERTY(QColor redColor READ redColor NOTIFY themeChanged)

    Q_PROPERTY(QString currentTheme READ currentTheme NOTIFY themeChanged)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    bool loadConfig(const QString &filePath);
    Q_INVOKABLE void setTheme(const QString &themeName);

    QColor dividerColor() const { return m_dividerColor; }
    QColor borderColor() const { return m_borderColor; }
    QColor lightGrayColor()const { return m_lightGrayColor; }
    QColor orangeColor() const { return m_orangeColor; }
    QColor whiteColor() const { return m_whiteColor; }
    QColor blackColor() const { return m_blackColor; }
    QColor greenColor() const { return m_greenColor; }
    QColor redColor() const { return m_redColor; }

    QColor backgroundColor() const { return m_backgroundColor; }
    QColor textColor() const { return m_textColor; }

    QString currentTheme() const { return m_currentTheme; }

signals:
    void themeChanged();

private:
    void applyTheme(const QJsonObject &themeObj);

    QColor m_dividerColor = "#555555";
    QColor m_backgroundColor = "#ffffff";
    QColor m_textColor = "#000000";
    QColor m_borderColor = "#E98C0E";
    QColor m_lightGrayColor = "#D9D9D9";
    QColor m_orangeColor = "#FFA800";
    QColor m_whiteColor = "#FFFFFF";
    QColor m_blackColor = "#000000";
    QColor m_greenColor = "#008000";
    QColor m_redColor = "#FF0000";

    QString m_currentTheme = "normal";
    QJsonObject m_allThemes;
};

#endif // THEMEMANAGER_H
