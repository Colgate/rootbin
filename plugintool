#! /bin/bash

automatic() {
if [ -d /servers/ ]
    then
        for server in $(ls /servers/); do
                if [ -d /servers/$server/plugins ]
                    then
                        echo -e '\nChecking plugins for '$server
                        if [ ! -d /servers/$server/plugin_backups ]
                            then
                                mkdir /servers/$server/plugin_backups/
                        fi;
                        cd /servers/$server/plugins/
                        for plugin in *.jar; do 
                            curplugin=`curl --silent http://api.bukget.org/3/search/versions.filename/=/$plugin | python -mjson.tool | grep \"slug\": | awk '{print $2}' | sed 's/"//g'`
                            curplugin=`echo $curplugin | awk '{print $1}'`
                            pdata=`curl --silent http://api.bukget.org/3/plugins/bukkit/$curplugin/latest?fields=versions.date,slug,versions.download`
                            if [[ ! "$pdata" =~ "404 Not Found" ]]
                                then
                                    printf '%-30s%s\n' "Checking:" $curplugin
                                    pdate=`echo $pdata | python -mjson.tool | grep \"date\": | awk '{print $2}' | sed 's/"//g;s/,//g'`
                                    mdate=`stat -c %Y /servers/$server/plugins/$plugin`
                                    if [[ "$mdate" < "$pdate" ]]
                                        then
                                            echo -e "\t"$curplugin" is out of date....Updating";
                                            mv -f /servers/$server/plugins/$plugin /servers/$server/plugin_backups/
                                            iszip=`echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'`
                                            if [ "$iszip" =~ ".zip" ]
                                                then
                                                    mkdir temporary
                                                    cd temporary
                                                    wget `echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'` -O plugin.zip
                                                    unzip plugin.zip
                                                    rm -fv plugin.zip
                                                    mv * /servers/$server/plugins/
                                                    cd /servers/$server/plugins/
                                                    rm -rfv temporary
                                                else
                                                    wget `echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'` -O /servers/$server/plugins/$plugin
                                            fi;
                                    fi;
                            fi;
                        done;
                        echo -e '\n'
                        screen -x `cat /etc/$server.pid` -X stuff 'broadcast Automatic Restart'$'\012';
                        /sbin/server $server restart
                fi;
        done;
fi;
}
fullupdate() {
if [ -d /servers/ ]
    then
        for server in $(ls /servers/); do
                if [ -d /servers/$server/plugins ]
                    then
                        echo -e '\nUpdating plugins for '$server
                        if [ ! -d /servers/$server/plugin_backups ]
                            then
                                mkdir /servers/$server/plugin_backups/
                        fi;
                        cd /servers/$server/plugins/
                        for plugin in *.jar; do 
                            curplugin=`curl --silent http://api.bukget.org/3/search/versions.filename/=/$plugin | python -mjson.tool | grep \"slug\": | awk '{print $2}' | sed 's/"//g'`
                            curplugin=`echo $curplugin | awk '{print $1}'`
                            pdata=`curl --silent http://api.bukget.org/3/plugins/bukkit/$curplugin/latest?fields=versions.date,slug,versions.download`
                            if [[ ! "$pdata" =~ "404 Not Found" ]]
                                then
                                    printf '%-30s%s\n' "Updating:" $curplugin
                                    mv -f /servers/$server/plugins/$plugin /servers/$server/plugin_backups/
                                    iszip=`echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'`
                                    if [[ "$iszip" =~ ".zip" ]]
                                        then
                                            mkdir temporary
                                            cd temporary
                                            wget `echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'` -O plugin.zip
                                            unzip plugin.zip
                                            rm -fv plugin.zip
                                            mv * /servers/$server/plugins/
                                            cd /servers/$server/plugins/
                                            rm -rfv temporary
                                        else
                                            wget `echo $pdata | python -mjson.tool | grep \"download\": | awk '{print $2}' | sed 's/"//g'` -O /servers/$server/plugins/$plugin
                                    fi;
                            fi;
                        done;
                        echo -e '\n'
                fi;
        done;
fi;
}

case $1 in 
    --auto)
        automatic
        ;;
    --full)
        fullupdate
        ;;
    --help)
        echo $"Usage $0"
        echo -e "\t--auto: Automatically update out of date plugins"
        echo -e "\t--full: Update all plugins found on all servers"
        ;;
    *)
        automatic
        ;;
esac;