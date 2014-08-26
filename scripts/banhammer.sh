echo "[$(date "+%Y-%m-%d %H:%M:%S")] banhammer.sh started" >> /var/log/banhammer.log

tail -f -n 1 /var/log/secure | while read line;
do
    now=$(date "+%Y-%m-%d %H:%M:%S")
    ## Invalid username block
    out=$(grep "Failed" <<< $line)
    [[ -n $(grep "invalid" <<< $out) ]] && {
        
        ## Variables are our friends.
        IP=$(grep --line-buffered -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" <<< $line)
        username=$(sed -n 's:.*user\(.*\)from.*:\1:p' <<< $line | sed 's/^[ \t]*//')
        
        ## Ban this bitch.
        [[ -z $(iptables-save | grep $IP) ]] && {
            iptables -A INVALIDUSER -s $IP -m comment --comment "Blocked on $(date +"%F at %R") for attempted login with username $username" -j REJECT --reject-with icmp-host-prohibited
            
            ## Kill their SSH session
            ps aux | grep sshd | grep unknown | awk '{print $2}' | while read p; do kill -9 $p; done;
            
            ## Log this bitch
            echo "[$now] Blocking IP address $IP for attempt to log in with username $username" >> /var/log/banhammer.log
        }
        
    };
    [[ -n $(grep "root" <<< $out) ]] && {
        
        ## Grab the offending IP
        IP=$(grep --line-buffered -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" <<< $line);
        
        ## Make sure the above didn't fuck up
        [[ -n "$IP" ]] && {
            ## Check the fail count
            count=$(grep -oc $IP /var/log/log_ip)
            ## If greater than/equal to 6 failures, ban this bitch ; else log this bitch
            [[ $count -ge 6 ]] && {
                [[ -z $(iptables-save | grep $IP) ]] && {
                    iptables -A BRUTE_DROP -s $IP -m comment --comment "blocked on $(date +"%F at %R") for too many root authentication failures" -j REJECT --reject-with icmp-host-prohibited;
                    echo "[$now] Blocking IP address $IP for too many failed root logins" >> /var/log/banhammer.log
                }
            } || echo $IP >> /var/log/log_ip
        }
    };
                
done;
