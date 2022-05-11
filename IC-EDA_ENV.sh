#!/bin/bash

#get the location of shell
cur_dir=`pwd`
echo "your location is: $cur_dir"
printf "\n"
cd $cur_dir

#set script ENV
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
export sourcefile_path=${cur_dir}/sourcefile
export install_path=${cur_dir}/programfile

#functions 
gvimInstall() {
    sudo yum update -y
    sudo yum install git -y
    sudo yum install -y ncurses-devel -y
    sudo yum install vim-X11.x86_64 -y
    cd /home/${USER}
    cat > .vimrc <<- EOF
        {
        syntax on
        set nu
        set fileencoding=utf-8
        set fenc=utf-8
        set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936,big-5                    
        set enc=utf-8
        let &termencoding=&encoding
        set guifont=Monospace\ 13
        set tabstop=4
        set expandtab
        set shiftwidth=4
        set softtabstop=4
        autocmd FileType make set noexpandtab
        set ruler
        set ignorecase 
        set autoindent
        set smartindent
        set showcmd
        colorscheme darkblue
        set nocompatible
        set backspace=indent,eol,start
        }
EOF
    echo -e "********gvim installation done********"
}

synopsysInstall(){
    sudo yum update -y
    sudo yum install libXScrnSaver-1.2.2-6.1.el7 -y
    sudo yum install libpng12 -y
    sudo yum install redhat-lsb.i686 -y
    sudo yum install gcc+ gcc-c++ -y
    # run synopsysinstaller
    if [ ! -d "${install_path}/synopsys" ];then
        echo "********run synopsysinstaller********"
        mkdir ${install_path}/synopsys
        sudo chmod 777 ${install_path}/synopsys
    fi
    cd ${sourcefile_path}/IC_EDA_pack/
    dirsum=`ls -l $inputdir | grep "^d"| wc -l`
    cd ${sourcefile_path}/IC_EDA_pack/synopsysinstaller_v5.0
    if [ ! -f "${sourcefile_path}/IC_EDA_pack/synopsysinstaller_v5.0/setup.sh" ];then
        sudo ./SynopsysInstaller_v5.0.run
    else
        cd ${sourcefile_path}/IC_EDA_pack/synopsysinstaller_v5.0
        for ((i=1;i<=${dirsum};i=i+1))
        do
        echo -e "********installation times: $i/Total ${dirsum}********"
        ./setup.sh
        if [ $? = 0 ];then
            echo "********next one********"
        else
            echo  -e "********the shell is canceling********"	
            exit 1
        fi
        done
    fi
    cd /home/${USER}
    cat > .bashrc <<- EOF
        { 
            # .bashrc

            # Source global definitions
            if [ -f /etc/bashrc ]; then
                    . /etc/bashrc
            fi

            export DVE_HOME=${install_path}/synopsys/vcs/O-2018.09-SP2
            export VCS_HOME=${install_path}/synopsys/vcs/O-2018.09-SP2
            export VCS_MX_HOME=${install_path}/synopsys/vcs-mx/O-2018.09-SP2
            export LD_LIBRARY_PATH=${install_path}/synopsys/verdi/Verdi_O-2018.09-SP2/share/PLI/VCS/LINUX64
            export VERDI_HOME=${install_path}/synopsys/verdi/Verdi_O-2018.09-SP2
            export SCL_HOME=${install_path}/synopsys/scl/2018.06

            PATH=$PATH:$VCS_HOME/gui/dve/bin
            alias dve="dve"

            PATH=$PATH:$VCS_HOME/bin
            alias vcs="vcs"

            PATH=$PATH:$VERDI_HOME/bin
            alias verdi="verdi"

            PATH=$PATH:$SCL_HOME/linux64/bin
            export VCS_ARCH_OVERRIDE=linux

            export LM_LICENSE_FILE=27000@localhost.localdomain
            alias lmg_synopsys="lmgrd -c ${install_path}/synopsys/scl/2018.06/admin/license/Synopsys.dat"
        }
EOF
    source .bashrc
    sudo firewall-cmd --zone=public --add-port=27000/tcp --permanent
    sudo firewall-cmd --reload
    lmg_synopsys
}

showHostAndMac(){
    echo -e "**************************************************"
    hostname
    ifconfig
    read -p "********Press any key to continue！********"
}

rollback(){
	rm -rf sourcefile_path
}

#waiting for instrcution
menu(){
    clear
    while :; do
        echo 
        echo "********IC-EAD Environment script for centos*******"
        echo "##notes: sourcefile for installer           "
        echo "##       programfile for installation folder"
        echo "***************************************************"
        echo
        echo -e "$yellow 1. $none install gvim"
        echo
        echo -e "$yellow 2. $none install synopsys"
        echo
        echo -e "$yellow 3. $none show hostname and mac address"
        echo
        echo -e "$yellow 4. $none exit"      
        echo
        echo -e "Notes: press $yellow Ctrl + C $none to cancel" 
        read -p "$(echo -e "Press Number to continue [${magenta}1-4$none]:")" choose
        if [ -z $choose ]; then
            exit 1
        else
            case $choose in
            1)
                echo -e "********start to install gvim********"
                gvimInstall
                ;;
            2)
                echo -e "********start to install synopsys********"
                synopsysInstall
                ;;
            3)
                echo -e "********show hostname and macaddr********"
                showHostAndMac
                ;;
            4)
                echo -e "********exiting********"
                exit 1
                ;;
            *)
                echo -e "********error********"
                exit 1
                ;;
            esac
        fi
    done
}
menu



