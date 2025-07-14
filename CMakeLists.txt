cmake_minimum_required(VERSION 3.16)
project(par3D VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Quick3D SerialPort Core )

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(apppar3D
    main.cpp
)

qt_add_qml_module(apppar3D
    URI par3D
    VERSION 1.0
    QML_FILES
        Main.qml
        Base3DView.qml
        par3DView.qml

    SOURCES
        serialreceiver.h serialreceiver.cpp
)

# Resource klasöründeki tüm model dosyalarını listele
file(GLOB_RECURSE MODEL_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/resource/*.obj"
)

# Qt Resource sistemi ile model dosyalarını ekle
qt_add_resources(apppar3D "models"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}"
    FILES ${MODEL_FILES}
)

# Properties
set_target_properties(apppar3D PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Bağlantılar
target_link_libraries(apppar3D
    PRIVATE
    Qt6::Quick
    Qt6::Quick3D
    Qt6::Core
    Qt6::SerialPort
)

# Kurulum
include(GNUInstallDirs)
install(TARGETS apppar3D
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
