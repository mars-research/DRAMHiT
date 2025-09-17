

declare -A DATASETS

SRA_HOME=/opt/sra
DATASET_DIR=/opt/datasets
DATASETS["dmela"]=${DATASET_DIR}/ERR4846928.fastq
DATASETS["fvesca"]=${DATASET_DIR}/SRR1513870.fastq

download_datasets() {
  mkdir -p ${DATASET_DIR}
  pushd ${DATASET_DIR}

  for file in ${DATASETS[@]}; do
    RAW_FILE=$(echo ${file} | cut -d'.' -f1)
    LOC=$(echo ${RAW_FILE} | awk -F'/' '{ print $NF }')

    if [ ! -f ${RAW_FILE} ]; then
      record_log "Downloading ${LOC} dataset"
      wget https://sra-pub-run-odp.s3.amazonaws.com/sra/${LOC}/${LOC}
    fi
  done

  if [ ! -f "SHA256SUMS" ]; then
    echo "4b358e9879d9dd76899bf0da3b271e2d7250908863cf5096baeaea6587f3e31e ERR4846928" > SHA256SUMS
    echo "5656e982ec7cad80348b1fcd9ab64c5cab0f0a0563f69749a9f7c448569685c1 SRR1513870" >> SHA256SUMS
  fi

  sha256sum -c SHA256SUMS

  if [ $? -ne 0 ]; then
    echo "Downloaded files likely corrupted!"
  fi
  popd
}

process_fastq() {
  pushd ${DATASET_DIR}
  for file in ${DATASETS[@]}; do
    if [[ ! -f ${file} ]]; then
      RAW_FILE=$(echo ${file} | cut -d'.' -f1)
      ${SRA_HOME}/bin/fastq-dump ${RAW_FILE}
    fi
  done
  popd
}


download_sratoolkit() {
  if [ ! -d ${SRA_HOME} ]; then
    mkdir -p ${SRA_HOME}
    pushd ${SRA_HOME}

    wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz

    tar xvf sratoolkit.current-ubuntu64.tar.gz -C ${SRA_HOME} --strip-components=1
    rm sratoolkit.current-ubuntu64.tar.gz
    popd
  fi
}

download_datasets
download_sratoolkit
process_fastq