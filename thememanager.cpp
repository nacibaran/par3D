#include "thememanager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
{
    // Config dosyasını yükle
    loadConfig("config/theme_config.json");
}

bool ThemeManager::loadConfig(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[ThemeManager] Tema yapılandırma dosyası açılamadı:" << filePath;
        return false;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    file.close();

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "[ThemeManager] Tema JSON parse hatası:" << parseError.errorString();
        return false;
    }

    QJsonObject root = doc.object();

    // Aktif tema adı
    m_currentTheme = root.value("theme").toString("normal");

    // Tüm temalar
    m_allThemes = root.value("themes").toObject();

    if (!m_allThemes.contains(m_currentTheme)) {
        qWarning() << "[ThemeManager] Belirtilen tema bulunamadı:" << m_currentTheme;
        return false;
    }

    applyTheme(m_allThemes.value(m_currentTheme).toObject());
    qDebug() << "[ThemeManager] Tema yüklendi:" << m_currentTheme;
    return true;
}

void ThemeManager::setTheme(const QString &themeName)
{
    if (!m_allThemes.contains(themeName)) {
        qWarning() << "[ThemeManager] Tema bulunamadı:" << themeName;
        return;
    }

    m_currentTheme = themeName;
    applyTheme(m_allThemes.value(themeName).toObject());
    emit themeChanged();
    qDebug() << "[ThemeManager] Tema değiştirildi:" << themeName;

    // JSON dosyasını güncelle
    QFile file("config/theme_config.json");
    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qWarning() << "[ThemeManager] Tema yapılandırma dosyası açılamadı (yazmak için):" << file.fileName();
        return;
    }

    // Mevcut JSON'u oku
    QByteArray data = file.readAll();
    file.seek(0);          // Dosyanın başına dön
    file.resize(0);        // Dosyayı temizle

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "[ThemeManager] Tema JSON parse hatası (yazma için):" << parseError.errorString();
        file.close();
        return;
    }

    QJsonObject root = doc.object();
    // theme anahtarını güncelle
    root["theme"] = themeName;

    // Yeni JSON'u dosyaya yaz
    QJsonDocument newDoc(root);
    file.write(newDoc.toJson(QJsonDocument::Indented));
    file.close();

    qDebug() << "[ThemeManager] Tema yapılandırma dosyası güncellendi.";
}


void ThemeManager::applyTheme(const QJsonObject &themeObj)
{
    m_dividerColor = QColor(themeObj.value("dividerColor").toString("#060606"));
    m_backgroundColor = QColor(themeObj.value("backgroundColor").toString("#060606"));
    m_textColor = QColor(themeObj.value("textColor").toString("#060606"));
    m_borderColor = QColor(themeObj.value("borderColor").toString("#060606"));
    m_lightGrayColor = QColor(themeObj.value("lightGrayColor").toString("#060606"));
    m_whiteColor = QColor(themeObj.value("whiteColor").toString("#060606"));
    m_blackColor = QColor(themeObj.value("blackColor").toString("#060606"));
    m_greenColor =  QColor(themeObj.value("greenColor").toString("#060606"));
    m_redColor =  QColor(themeObj.value("redColor").toString("#060606"));

}
