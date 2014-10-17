#/bin/bash


#script to compile mex files...

echo "COMPILING MEX..."
echo

mkdir -p mex
rm mex/*

DCPROGS_DIR=/usr/local/include/dcprogs
EIGEN_INCLUDE_DIR=/usr/local/Cellar/Eigen/3.2.1/include/eigen3
MATLAB_DIR=/Applications/MATLAB_R2014a.app

OS=$( uname )

if [ $OS == "Darwin" ]
then
    echo "Compiling dcpUtils object file - MAC"
    c++ -std=c++11 -stdlib=libc++ -c  -I${DCPROGS_DIR}/likelihood -I${DCPROGS_DIR} -I${EIGEN_INCLUDE_DIR} -I${MATLAB_DIR}/extern/include -I${MATLAB_DIR}/simulink/include -DMATLAB_MEX_FILE -fno-common -no-cpp-precomp -fexceptions -arch x86_64 -isysroot / -mmacosx-version-min=10.9  -DMX_COMPAT_32 -O2 -DNDEBUG  src/dcpUtils.cpp -o mex/dcpUtils.o
elif [ $OS == "Linux"  ]
then
    echo "Compiling dcpUtils object file - LINUX"
    c++ -std=c++11 -c  -I${DCPROGS_DIR}/likelihood -I${DCPROGS_DIR} -I${EIGEN_INCLUDE_DIR} -I${MATLAB_DIR}/extern/include -I${MATLAB_DIR}/simulink/include -DMATLAB_MEX_FILE -D_GNU_SOURCE -fPIC -fno-omit-frame-pointer -pthread  -DMX_COMPAT_32 -O -DNDEBUG src/dcpUtils.cpp -o mex/dcpUtils.o
fi


for MEX_FILE in dcpAsymptoticSurvivorExponentXt dcpAsymptoticSurvivorXs dcpAsymptoticSurvivorXt dcpChsOccupancies dcpDerivAsymptoticSurvivorXs dcpDerivDetWs dcpDetWs dcpExactSurvivorRecursion dcpExactSurvivorXt dcpFindRoots dcpIdealGXYt dcpLikelihood dcpMissedEventsGXYt dcpOccupancies ; do 
    echo "Compiling mex file $MEX_FILE";
    if [ $OS == "Darwin" ] 
    then
        c++ -std=c++11 -stdlib=libc++ -c  -I${DCPROGS_DIR}/likelihood -I${DCPROGS_DIR} -I${EIGEN_INCLUDE_DIR} -I${MATLAB_DIR}/extern/include -I${MATLAB_DIR}/simulink/include -DMATLAB_MEX_FILE -fno-common -no-cpp-precomp -fexceptions -arch x86_64 -isysroot / -mmacosx-version-min=10.9  -DMX_COMPAT_32 -O2 -DNDEBUG  src/${MEX_FILE}.cpp -o mex/${MEX_FILE}.o
        c++ -stdlib=libc++ -O -Wl,-twolevel_namespace -undefined error -arch x86_64 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/ -mmacosx-version-min=10.9 -bundle -Wl,-exported_symbols_list,${MATLAB_DIR}/extern/lib/maci64/mexFunction.map -L/usr/local/lib -o  "mex/${MEX_FILE}.mexmaci64"  mex/${MEX_FILE}.o mex/dcpUtils.o -l likelihood  -L${MATLAB_DIR}/bin/maci64 -lmx -lmex -lmat -lstdc++
    elif [ $OS == "Linux"  ]
    then  
        c++ -std=c++11 -c -I${DCPROGS_DIR} -I${DCPROGS_DIR}/likelihood -I${EIGEN_INCLUDE_DIR} -I${MATLAB_DIR}/extern/include -I${MATLAB_DIR}/simulink/include -DMATLAB_MEX_FILE -D_GNU_SOURCE -fPIC -fno-omit-frame-pointer -pthread  -DMX_COMPAT_32 -O -DNDEBUG src/${MEX_FILE}.cpp -o mex/${MEX_FILE}.o
        g++ -O -pthread -shared -Wl,--version-script,${MATLAB_DIR}/extern/lib/glnxa64/mexFunction.map -Wl,--no-undefined -o  mex/${MEX_FILE}.mexa64  mex/${MEX_FILE}.o mex/dcpUtils.o -Wl,-rpath-link,${MATLAB_DIR}/bin/glnxa64 -L${MATLAB_DIR}/bin/glnxa64 -lmx -lmex -lmat -lm -llikelihood
    else
        "OS not supported yet"
    fi
done

echo "Removing object files"
rm mex/*.o

echo "Mex compilation done following mex files have been generated"
ls mex/*.mex*
