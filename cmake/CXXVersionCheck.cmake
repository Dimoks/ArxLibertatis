
include(CheckCXXSourceCompiles)
include(CompileCheck)

set(CXX_VERSION 2003)
set(CXX_CHECK_DIR "${CMAKE_CURRENT_LIST_DIR}/check")

function(enable_cxx_version version)
	
	set(versions 20 17 14 11)
	
	if(MSVC)
		if(NOT version LESS 2011 AND NOT MSVC_VERSION LESS 1600)
			set(CXX_VERSION 2011)
			if(NOT version LESS 2020 AND NOT MSVC_VERSION LESS 1930)
				set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++20")
				set(CXX_VERSION 2020)
			elseif(NOT version LESS 2017 AND NOT MSVC_VERSION LESS 1911)
				set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
				set(CXX_VERSION 2017)
			elseif(NOT version LESS 2014 AND NOT MSVC_VERSION LESS 1910)
				set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
				set(CXX_VERSION 2014)
			elseif(NOT version LESS 2014 AND NOT MSVC_VERSION LESS 1900)
				# Only introduced with update 3 of MSVC 2015
				add_cxxflag("/std:c++14")
				if(FLAG_FOUND)
					set(CXX_VERSION 2014)
				endif()
			endif()
		endif()
	else()
		set(FLAG_FOUND 0)
		foreach(ver IN LISTS versions)
			if(NOT version LESS 20${ver} AND NOT FLAG_FOUND)
				add_cxxflag("-std=c++${ver}")
				if(FLAG_FOUND)
					set(CXX_VERSION 20${ver})
					break()
				endif()
			endif()
		endforeach()
		if(NOT FLAG_FOUND)
			# Check if the compiler supports the -std flag at all
			# Don't actually use the flag to allow for compiler extensions a la -sdt=gnu++03
			check_compiler_flag(FLAG_FOUND "-std=c++03")
			if(NOT FLAG_FOUND)
				check_compiler_flag(FLAG_FOUND "-std=c++98")
			endif()
		endif()
		if(NOT FLAG_FOUND)
			# Compiler does not support he -std flag, assume the highest supported C++ version is available
			# by default or can be enabled by CMake and rely on tests for individual features.
			foreach(ver IN LISTS versions)
				if(NOT version LESS 20${ver})
					set(CXX_VERSION 20${ver})
					break()
				endif()
			endforeach()
		endif()
		if(SET_WARNING_FLAGS AND NOT CXX_VERSION LESS 2011)
			add_cxxflag("-pedantic")
		endif()
	endif()
	
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" PARENT_SCOPE)
	set(CXX_VERSION ${CXX_VERSION} PARENT_SCOPE)
	
	# Tell CMake about our desired C++ version so that it doesn't override our value with a lower version.
	# We check -std ourselves first because
	# - This feature is new in CMake 3.1
	# - Not all CMake versions know how to check for all C++ versions
	# - CMake doesn't tell us what versions are available
	if(NOT CMAKE_VERSION VERSION_LESS 3.25)
		set(max_cxx_standard 26)
	elseif(NOT CMAKE_VERSION VERSION_LESS 3.20)
		set(max_cxx_standard 23)
	else()
		set(max_cxx_standard 20)
	endif()
	foreach(ver IN LISTS versions)
		if(NOT CXX_VERSION LESS 20${ver} AND NOT max_cxx_standard LESS ver)
			set(CMAKE_CXX_STANDARD ${ver} PARENT_SCOPE)
			set(CMAKE_CXX_STANDARD_REQUIRED OFF PARENT_SCOPE)
			set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)
			break()
		endif()
	endforeach()
	
endfunction(enable_cxx_version)

function(check_cxx version feature resultvar)
	set(result)
	if(MSVC AND ARGC GREATER 3)
		if(NOT MSVC_VERSION LESS ARGV3)
			set(result 1)
		endif()
	else()
		string(REGEX REPLACE "[^a-zA-Z0-9_][^a-zA-Z0-9_]*" "-" check "${feature}")
		string(REGEX REPLACE "^--*" "" check "${check}")
		string(REGEX REPLACE "--*$" "" check "${check}")
		set(file "${CXX_CHECK_DIR}/cxx${version}-${check}.cpp")
		set(old_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
		set(old_CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
		strip_warning_flags(CMAKE_CXX_FLAGS)
		strip_warning_flags(CMAKE_EXE_LINKER_FLAGS)
		check_compile(result "${file}" "${feature}" "C++${version} feature")
		set(CMAKE_CXX_FLAGS "${old_CMAKE_CXX_FLAGS}")
		set(CMAKE_EXE_LINKER_FLAGS "${old_CMAKE_EXE_LINKER_FLAGS}")
	endif()
	if(NOT DEFINED result OR result STREQUAL "")
		set(${resultvar} OFF PARENT_SCOPE)
	else()
		set(${resultvar} ON PARENT_SCOPE)
	endif()
endfunction()
