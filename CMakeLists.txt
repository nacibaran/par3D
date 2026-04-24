cmake_minimum_required(VERSION 3.16)
set(APP_NAME Hancer_Seri_Üretim_APP)
project(${APP_NAME} VERSION 0.1 LANGUAGES CXX)

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
        Hancer3DView.qml
        LeftToolbar.qml
        LeftToolbarButton.qml
        MenuView.qml
        VehiclePage.qml
        AudioPage.qml

    SOURCES
        vcucommunication.h vcucommunication.cpp
        thememanager.h thememanager.cpp

)

# Model dosyaları
file(GLOB_RECURSE MODEL_FILES_OBJ
    "${CMAKE_CURRENT_SOURCE_DIR}/resource/models//*.obj"
)

# MTL dosyaları
file(GLOB_RECURSE MODEL_FILES_MTL
    "${CMAKE_CURRENT_SOURCE_DIR}/resource/models//*.mtl"
)


# PNG ikon dosyaları
file(GLOB_RECURSE ICON_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/resource/icons/*.png"
)

# GLB ikon dosyaları
file(GLOB_RECURSE GLB_MODEL_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/resource/models/*.glb"
)
# GLB ikon dosyaları
file(GLOB_RECURSE CONFIG
    "${CMAKE_CURRENT_SOURCE_DIR}/config/*.json"
)




# Resource ekleme
qt_add_resources(apppar3D "resources"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}"
    FILES
        ${MODEL_FILES_OBJ}
        ${MODEL_FILES_MTL}
        ${ICON_FILES}
        ${GLB_MODEL_FILES}
        ${CONFIG}
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
)

# Kurulum
include(GNUInstallDirs)
install(TARGETS apppar3D
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
