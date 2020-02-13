Bootstrap: docker
From: ubuntu:bionic

%runscript
echo "Starting the MN RNAseq Research container..."


%post


apt-get -y update

apt-get install -y apt-transport-https software-properties-common apt-utils wget curl rsync
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

apt-get -y update
apt-get -y upgrade

# Installing LaTeX stuff (if needed)
#apt-get -y install texlive-latex-base texlive-fonts-recommended texlive-latex-extra lmodern

# Installing extra software
apt-get -y install libssl-dev libcurl4-openssl-dev git git-lfs automake autoconf libxml2 libxml2-dev libcurl4-openssl-dev libfontconfig1-dev libcairo2-dev 
#libnode-dev

apt-get -y install r-base-core
#apt-get -y install tk-dev mesa-common-dev libglu1-mesa-dev #Satisfying dependencies for rgl that seems to be required below for RColorBrewer


## Install required R packages
R --slave -e 'install.packages("BiocManager", dependencies=TRUE, repos = "http://cran.us.r-project.org")'
R --slave -e 'BiocManager::install("tximport")'
R --slave -e 'BiocManager::install("rhdf5")'

#R --slave -e 'BiocManager::install("DESeq2")' #FAIL
#R --slave -e 'BiocManager::install("biomaRt")' #FAIL

R --slave -e 'BiocManager::install("reshape")'
R --slave -e 'BiocManager::install("dplyr")'


cd /usr/bin
wget "https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz"
tar xvf kallisto_linux-v0.46.1.tar.gz
rm -rf kallisto_linux-v0.46.1.tar.gz
rm -rf kallisto/test/

cd /

git clone https://github.com/afonsoguerra/tutorial.git



%environment
export LC_ALL=C
export PATH=$PATH:$PWD
export PATH="$PATH:/usr/bin/kallisto"

 
