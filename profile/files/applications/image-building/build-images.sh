#!/usr/bin/bash

#--------------------------------------------------------------------+
#Color picker, usage: printf ${BLD}${CUR}${RED}${BBLU}"Hello!)"${DEF}|
#-------------------------+--------------------------------+---------+
#       Text color        |       Background color         |         |
#-----------+-------------+--------------+-----------------+         |
# Base color|Lighter shade|  Base color  | Lighter shade   |         |
#-----------+-------------+--------------+-----------------+         |
BLK='\e[30m'; blk='\e[90m'; BBLK='\e[40m'; bblk='\e[100m' #| Black   |
RED='\e[31m'; red='\e[91m'; BRED='\e[41m'; bred='\e[101m' #| Red     |
GRN='\e[32m'; grn='\e[92m'; BGRN='\e[42m'; bgrn='\e[102m' #| Green   |
YLW='\e[33m'; ylw='\e[93m'; BYLW='\e[43m'; bylw='\e[103m' #| Yellow  |
BLU='\e[34m'; blu='\e[94m'; BBLU='\e[44m'; bblu='\e[104m' #| Blue    |
MGN='\e[35m'; mgn='\e[95m'; BMGN='\e[45m'; bmgn='\e[105m' #| Magenta |
CYN='\e[36m'; cyn='\e[96m'; BCYN='\e[46m'; bcyn='\e[106m' #| Cyan    |
WHT='\e[37m'; wht='\e[97m'; BWHT='\e[47m'; bwht='\e[107m' #| White   |
#----------------------------------------------------------+---------+
# Effects                                                            |
#--------------------------------------------------------------------+
DEF='\e[0m'   #Default color and effects                             |
BLD='\e[1m'   #Bold\brighter                                         |
DIM='\e[2m'   #Dim\darker                                            |
CUR='\e[3m'   #Italic font                                           |
UND='\e[4m'   #Underline                                             |
INV='\e[7m'   #Inverted                                              |
COF='\e[?25l' #Cursor Off                                            |
CON='\e[?25h' #Cursor On                                             |
#--------------------------------------------------------------------+
# Text positioning, usage: XY 10 10 "Hello World!"                   |
XY   () { printf "\e[${2};${1}H${3}";   } #                          |
#--------------------------------------------------------------------+
# Print line, usage: line - 10 | line -= 20 | line "Hello World!" 20 |
line () { printf -v LINE "%$2s"; printf -- "${LINE// /$1}"; } #      |
# Create sequence like {0..X}                                        |
cnt () { printf -v _N %$1s; _N=(${_N// / 1}); printf "${!_N[*]}"; } #|
#--------------------------------------------------------------------+

# Set path
PATH=/usr/bin:/usr/sbin
export PATH

# Variables
BUILD_PATH=/home/imagebuilder/build_scripts
LOG_PATH=/var/log/imagebuilder

# Option variables
ALL_STD=0
ALL_GPU=0
ALL_WIN=0
LIST=0
DRYRUN=0
TIMEOUT=0

# Images to build
build_std_images=()
build_gpu_images=()
build_win_images=()

# Find images
STD_IMAGES=()  # standard images
GPU_IMAGES=()  # vgpu images
WIN_IMAGES=()  # windows images
for script in $(ls /home/imagebuilder/build_scripts/); do
    if [[ $script =~ _nv_vgpu$ ]]; then
        GPU_IMAGES+=($script)
    elif [[ $script =~ ^winsrv_.*_wrapper ]]; then
	WIN_IMAGES+=($script)
    else
        STD_IMAGES+=($script)
    fi
done

# Function to display usage
usage() {
    echo "Usage: $0 [-h] [-S] [-G] [-W] [-t <sec>] [-l] [-i <image>]..."
    echo
    echo 'Options:'
    echo '  -S  Build all standard images. Negates -i options'
    echo '  -G  Build all vgpu images. Negates -i options'
    echo '  -W  Build all Windows images. Negates -i options'
    echo '  -i  Specify image to build. Can be used multiple times'
    echo '  -t  Terminate build job if still running after this duration. See timeout(1)'
    echo '  -l  List all images and exit'
    echo '  -n  Dry-run: Only show what would be done'
    echo '  -h  Display help'
    echo
}

# Display usage and exit with error if no options given
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Get options
while getopts "SGlnhi:t:" arg; do
    case $arg in
	S)
	    ALL_STD=1
	    ;;
	G)
	    ALL_GPU=1
	    ;;
	W)
	    ALL_WIN=1
	    ;;
	i)
	    if [[ $OPTARG =~ _nv_vgpu$ ]]; then
		build_gpu_images+=(${OPTARG})
	    elif [[ $OPTARG =~ ^winsrv_ ]]; then
		build_win_images+=(${OPTARG})
	    else
		build_std_images+=(${OPTARG})
	    fi
	    ;;
	t)
	    TIMEOUT=$OPTARG
	    ;;
	l)
	    LIST=1
	    ;;
	n)
	    DRYRUN=1
	    ;;
	h|*)
	    usage
	    exit 0
	    ;;
    esac
done

# Display all images and exit
if [ $LIST -eq 1 ]; then
    echo "Standard images:"
    for image in "${STD_IMAGES[@]}"; do
	echo "  $image"
    done
    echo "vGPU images:"
    for image in "${GPU_IMAGES[@]}"; do
	echo "  $image"
    done
    echo "Windows images:"
    for image in "${WIN_IMAGES[@]}"; do
	echo "  $image"
    done
    exit 0
fi

# If we want to build all images
if [ $ALL_STD -eq 1 ]; then
    build_std_images=(${STD_IMAGES[@]})
fi
if [ $ALL_GPU -eq 1 ]; then
    build_gpu_images=(${GPU_IMAGES[@]})
fi
if [ $ALL_WIN -eq 1 ]; then
    build_win_images=(${WIN_IMAGES[@]})
fi

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------

function build_image() {
    image=$1
    printf "${BMGN}${BLD}${wth}>>>>>>>>>>>>>>>> BUILDING IMAGE >>${DEF} $cyn$BLD$image ${DEF}${DIM}[timeout: $TIMEOUT]\n"$DEF
    if [ $DRYRUN -eq 0 ]; then
	timeout $TIMEOUT ${BUILD_PATH}/${image}
	exitval=$?
	if [ $exitval -eq 0 ]; then
	    printf "[${grn}${BLD}SUCCESS${DEF}] Build completed: $BLD$image$DEF"
        elif [ $exitval -eq 124 ]; then
	    printf "[${RED}${BLD}ERROR${DEF}] TIMEOUT: Build timed out after $TIMEOUT: $BLD$image$DEF" >&2
	    jq -nc '{"result": "failed"}' >> ${LOG_PATH}/${image}-report.jsonl
	else
	    printf "[${RED}${BLD}ERROR${DEF}] Build failed: $BLD$image$DEF" >&2
	    jq -nc '{"result": "failed"}' >> ${LOG_PATH}/${image}-report.jsonl
	fi
    else
	printf $GRN"(DRY-RUN)$DEF ${DIM}timeout $TIMEOUT ${BUILD_PATH}/${image}\n"$DEF
    fi
    echo
}

#---------------------------------------------------------------------
# MAIN
#---------------------------------------------------------------------

# Build standard images
export IMAGEBUILDER_REPORT=true
export IB_TEMPLATE_DIR=/etc/imagebuilder/default
for img in "${build_std_images[@]}"; do
    build_image $img
done

# Build vGPU images
export IMAGEBUILDER_REPORT=true
export IB_TEMPLATE_DIR=/etc/imagebuilder/nv_vgpu
for img in "${build_gpu_images[@]}"; do
    build_image $img
done

# Build Windows images
export PLACEHOLDER=true
export IMAGEBUILDER_REPORT=true
export IB_TEMPLATE_DIR=/etc/imagebuilder/default
# Do NOT build these if cron failed.
for img in "${build_win_images[@]}"; do
#    build_image $img
    echo "Do NOT build $img! Poke Tor if cron job failed"
done
