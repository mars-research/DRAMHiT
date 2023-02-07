# Get the tools from here https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit

wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
SRA_HOME=/local/devel2/kmerhash/sratoolkit

mkdir ${SRA_HOME}
tar xvf sratoolkit.current-ubuntu64.tar.gz -C ${SRA_HOME} --strip-components=1
rm sratoolkit.current-ubuntu64.tar.gz

# configure the toolkit
${SRA_HOME}/bin/vdb-config -i
