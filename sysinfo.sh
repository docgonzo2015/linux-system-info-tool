#!/bin/bash
#
# date: 27/04/2016
# author: bop
# function: get sysinfos
#
#
# history:
#   23/05/2016 - check system for info files (crontab, hosts, passwd, proxychains)
#   18/05/2016 - add usage and getopts
#   17/05/2016 - add blacklist checker via https://github.com/ST2Labs/SIPI
#   27/04/2016 - start project
#

## GLOBALS
SYSINFOFILE="sysinfo.txt"
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

## HELP/USAGE
usage() {
    cat <<- EOF
             _\|/_
             (o o)
     +----oOO-{_}-OOo---------------+
     |  Linux System Info Tool v2   |
     |  author: bop                 |
     |  date:   27/04/2016          |
     |  last:   23/05/2016          |
     +------------------------------+

    usage: $PROGNAME options

    Check your Linux System!

    OPTIONS:
       -a --all                         check all options
       -O --output                      save infos to file
       -w --whois                       get my ip and whois it
       -s --speedtest                   speed test over DE
       -c --cpu                         display my CPU
       -d --space                       display my space (same as df -h .)
       -u --uptime                      my uptime (same as uptime in your unix)
       -o --os                          my os (same as uname -a)
       -v --versions                    check programm versions (php,bash,python,etc.)
       -b --blacklist                   get my ip and check blacklist
       -p --perm                        search local folders for perm
       -i --infofiles                   cat info files (crontab, hosts, passwd, proxychains)
       -h --help                        show this help


    Examples:

       Run:
       $PROGNAME -a

EOF
}

# <Utils>
get_str_between() {
    string="$1"
    start="$2"
    end="$3"
    tmp=$(echo "$string" |grep -o -E "$start.*$end")
    tmp=${tmp/$start/}
    tmp=${tmp/$end/}
    printf "$tmp"
}

get_server_ip() {
    local ipecho=$(wget -O - http://ipecho.net/plain; echo)
    echo ipecho
}

# </Utils>

# <Core>

whois() {
    # get remote ip
    local ipecho=$(wget -O - http://ipecho.net/plain; echo)
    echo "ip: $ipecho" >> $SYSINFOFILE
    # whois
    local utrace=$(wget -O - http://xml.utrace.de/?query=$ipecho; echo)
    local isp=$(get_str_between "$utrace" "<isp>" "<\/isp>")
    local org=$(get_str_between "$utrace" "<org>" "<\/org>")
    local countrycode=$(get_str_between "$utrace" "<countrycode>" "<\/countrycode>")
    echo "whois: $isp - $org - $countrycode" >> $SYSINFOFILE
}

speedtest() {
    wget ftp://speedtest.tele2.net/100MB.zip 2>&1 \
        | grep '\([0-9.]\+ [KM]B/s\)' \
        >> $SYSINFOFILE
    rm 100MB.zip
}

cpu() {
    model=$(grep "model name" /proc/cpuinfo -m 1)
    count=$(grep -c processor /proc/cpuinfo)
    model=${model/model name/}
    model=${model/:/}
    echo "${count}x ${model/model name  : /}" >> $SYSINFOFILE
}

space() {
    df -h . >> $SYSINFOFILE
}

upstart() {
    uptime >> $SYSINFOFILE
}

os() {
    uname -a >> $SYSINFOFILE
}

versions() {
    tmp=$(bash --version | grep ersion -m 1)
    echo "bash: $tmp" >> $SYSINFOFILE
    tmp=$(python -V 2>&1)
    echo "python: $tmp" >> $SYSINFOFILE
    tmp=$(perl --version |grep -E "\(.*\)" -m 1)
    echo "perl: $tmp" >> $SYSINFOFILE
    tmp=$(php --version |grep built)
    echo "php: $tmp" >> $SYSINFOFILE
    tmp=$(java -version 2>&1 |grep version)
    echo "java: $tmp" >> $SYSINFOFILE
    tmp=$(gcc --version 2>&1 |grep gcc)
    echo "gcc: $tmp" >> $SYSINFOFILE
    tmp=$(ruby --version)
    echo "ruby: $tmp" >> $SYSINFOFILE
}

infofiles() {
    echo "" >> $SYSINFOFILE
    # hosts
    echo "/etc/hosts:=====================================================================" >> $SYSINFOFILE
    local hosts=$(
        cat /etc/hosts \
            |grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" \
            |grep -v localhost
    )
    echo "router ips:" >> $SYSINFOFILE
    echo $hosts >> $SYSINFOFILE
    # crontab
    echo "/etc/crontab:===================================================================" >> $SYSINFOFILE
    echo "crontab:" >> $SYSINFOFILE
    cat /etc/crontab >> $SYSINFOFILE
    # /etc/passwd
    echo "/etc/passwd:====================================================================" >> $SYSINFOFILE
    echo "passwd:" >> $SYSINFOFILE
    cat /etc/passwd >> $SYSINFOFILE
    # /etc/proxychains.conf
    echo "/etc/proxychains.conf:==========================================================" >> $SYSINFOFILE
    echo "proxychains.conf:" >> $SYSINFOFILE
    cat /etc/proxychains.conf >> $SYSINFOFILE
}

blacklist() {
    echo "" >> $SYSINFOFILE
    echo "Check Blacklists:===============================================================" >> $SYSINFOFILE
    # install SIPI
    wget -O SIPI.tar.gz https://github.com/ST2Labs/SIPI/archive/master.tar.gz
    tar xfvz SIPI.tar.gz
    rm SIPI.tar.gz
    # config SIPI
    local config='{
        "cymon": {
            "token": "dd86e7a99bd5b7fb5e5bc451b050d46a447caef8"
        },
        "shodan": {
            "token": "IMXY0sNo11RIHk5s9jMWA25t1yZ826sa"
        }
    }'
    echo "$config" > "./config.json"
    # install shodan
    wget -O shodan.tar.gz https://github.com/achillean/shodan-python/archive/master.tar.gz
    tar xfvz shodan.tar.gz
    rm shodan.tar.gz
    mv "./shodan-python-master/shodan" "SIPI-master"
    rm -R ./shodan-python-master
    # install simplejson
    wget -O json.tar.gz https://github.com/simplejson/simplejson/archive/master.tar.gz
    tar xfvz json.tar.gz
    rm json.tar.gz
    mv "./simplejson-master/simplejson" "SIPI-master"
    rm -R simplejson-master
    # install requests
    wget -O requests.tar.gz https://github.com/kennethreitz/requests/archive/master.tar.gz
    tar xfvz requests.tar.gz
    rm requests.tar.gz
    mv ./requests-master/requests ./SIPI-master
    rm -R requests-master
    # check the ip
    local ip=$(wget -O - http://ipecho.net/plain; echo)
    python ./SIPI-master/sipi.py -o ip_check_blacklist.txt -i -s -A -d 4 $ip
    cat ./SIPI-master/ip_check_blacklist.txt >> $SYSINFOFILE
    rm -R SIPI-master
    rm config.json
}

perm() {
    echo "" >> $SYSINFOFILE
    echo "" >> $SYSINFOFILE
    echo "Foundet folders with perm:" >> $SYSINFOFILE
    find / -type d -perm -2 -ls |grep -v denied >> $SYSINFOFILE
}

# </Core>


# <allMain>
all() {
    echo "" > $SYSINFOFILE
    os
    space
    cpu
    whois
    speedtest
    upstart
    versions
    blacklist
    infofiles
    perm
    cat $SYSINFOFILE
}
# </allMain>


## <OPTION maker>
cmdline() {
    for arg
    do
        delim=""
        case "$arg" in
        #translate --gnu-long-options to -g (short options)
           --help) args="${args}-h ";;
           --output) args="${args}-O ";;
           --all) args="${args}-a ";;
           --whois) args="${args}-w ";;
           --speedtest) args="${args}-s ";;
           --cpu) args="${args}-c ";;
           --space) args="${args}-d ";;
           --uptime) args="${args}-u ";;
           --os) args="${args}-o ";;
           --versions) args="${args}-v ";;
           --blacklist) args="${args}-b ";;
           --infofiles) args="${args}-i ";;
           --perm) args="${args}-p ";;
           #pass through anything else
           *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts ":O:hawscduovbip" option
    do
        case $option in
            h) usage;;
            O) SYSINFOFILE="$OPTARG";;
            a) all;;
            w) whois;;
            s) speedtest;;
            c) cpu;;
            d) space;;
            u) upstart;;
            o) os;;
            v) versions;;
            b) blacklist;;
            i) infofiles;;
            p) perm;;
            *) echo $OPTARG is an unrecognized option;;
        esac
    done
}

main() {
    cmdline $ARGS
}
main

#EOF
