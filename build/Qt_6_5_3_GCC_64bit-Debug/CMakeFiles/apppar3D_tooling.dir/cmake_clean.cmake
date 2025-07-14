file(REMOVE_RECURSE
  "par3D/Base3DView.qml"
  "par3D/Main.qml"
  "par3D/par3DView.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/apppar3D_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
