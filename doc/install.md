# Installation Instructions

## Dependencies
The following OS packages are required to build and run Genie:
- node (v12/v14)
- a C++ compiler
- GNU make
- gettext
- zip


The following commands can be used to install all the dependencies on common Linux distributions:

```bash
dnf -y install nodejs make gcc-c++ gettext zip # Fedora/RHEL
apt -y install nodejs build-essential make g++ gettext zip # Ubuntu/Debian
```

## Install Genie Toolkit
Genie toolkit is the core of Schema2QA - it generates large, natural synthetic datasets 
given a database schema and example values. To replicate the results in the leader board,
you need to use v0.8.0 of Genie. Install Genie with the following commands: 

```bash
git clone https://github.com/stanford-oval/genie-toolkit
cd genie-toolkit
git checkout tags/v0.8.0
npm install
```


## Install GenieNLP
GenieNLP provides the infrastructure for training as well as AutoQA neural paraphraser. 
Install GenieNLP v0.6.0 as follows:

```bash
git clone git@github.com:stanford-oval/genienlp.git
cd genienlp
git checkout tags/v0.6.0
pip3 install -e .
```

