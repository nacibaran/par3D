# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.30

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /home/nacibaran/.local/lib/python3.10/site-packages/cmake/data/bin/cmake

# The command to remove a file.
RM = /home/nacibaran/.local/lib/python3.10/site-packages/cmake/data/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/nacibaran/par3D

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug

# Utility rule file for apppar3D_qmllint.

# Include any custom commands dependencies for this target.
include CMakeFiles/apppar3D_qmllint.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/apppar3D_qmllint.dir/progress.make

CMakeFiles/apppar3D_qmllint: /home/nacibaran/Qt/6.5.3/gcc_64/bin/qmllint
CMakeFiles/apppar3D_qmllint: /home/nacibaran/par3D/Main.qml
CMakeFiles/apppar3D_qmllint: /home/nacibaran/par3D/Base3DView.qml
CMakeFiles/apppar3D_qmllint: /home/nacibaran/par3D/par3DView.qml
	cd /home/nacibaran/par3D && /home/nacibaran/Qt/6.5.3/gcc_64/bin/qmllint --bare -I /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug -I /home/nacibaran/Qt/6.5.3/gcc_64/./qml --resource /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug/.rcc/qmake_par3D.qrc --resource /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug/.rcc/apppar3D_raw_qml_0.qrc --resource /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug/.rcc/models.qrc /home/nacibaran/par3D/Main.qml /home/nacibaran/par3D/Base3DView.qml /home/nacibaran/par3D/par3DView.qml

apppar3D_qmllint: CMakeFiles/apppar3D_qmllint
apppar3D_qmllint: CMakeFiles/apppar3D_qmllint.dir/build.make
.PHONY : apppar3D_qmllint

# Rule to build all files generated by this target.
CMakeFiles/apppar3D_qmllint.dir/build: apppar3D_qmllint
.PHONY : CMakeFiles/apppar3D_qmllint.dir/build

CMakeFiles/apppar3D_qmllint.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/apppar3D_qmllint.dir/cmake_clean.cmake
.PHONY : CMakeFiles/apppar3D_qmllint.dir/clean

CMakeFiles/apppar3D_qmllint.dir/depend:
	cd /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/nacibaran/par3D /home/nacibaran/par3D /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug /home/nacibaran/par3D/build/Qt_6_5_3_GCC_64bit-Debug/CMakeFiles/apppar3D_qmllint.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : CMakeFiles/apppar3D_qmllint.dir/depend

