# systool
get a lot of infos from your linux system

## usage
```
             _\|/_
             (o o)
     +----oOO-{_}-OOo---------------+
     |  Linux System Info Tool v2   |
     |  author: bop                 |
     |  date:   27/04/2016          |
     |  last:   18/01/2017          |
     +------------------------------+

    usage: sysinfo.sh options

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
       -P --portscan                    scan localhost for open ports
       -f --historyfiles                cat the historyfiles (php, bash, sql, etc...)
       -h --help                        show this help


    Examples:

       Run:
       sysinfo.sh -a
       
       After the run look in sysinfo.txt!

```

## info
* date: 27/04/2016
* author: bop
* function: get sysinfos

## history
  - 18/01/2017 - add "--no-check-certificate" option to wget downloads (thx to MrDoob from MLC)
  - 24/05/2016 - add local port scan and cat history-files
  - 23/05/2016 - check system for info files (crontab, hosts, passwd, proxychains)
  - 18/05/2016 - add usage and getopts
  - 17/05/2016 - add blacklist checker via https://github.com/ST2Labs/SIPI
  - 27/04/2016 - start project
