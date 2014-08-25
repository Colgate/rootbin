SENDTO="email@provider.tld"

today=$(date +"%F")

cat << END > /tmp/mailbody_$today.txt

The following report was generated on $today:

Total IP addresses blocked: $(grep -c $today /var/log/banhammer.log)

Log entries for $today:
$(grep $today /var/log/banhammer.log)

END

mail -s "s5.colgateminuette.org banhammer.sh log for $today" $SENDTO < /tmp/mailbody_$today.txt

rm -f /tmp/mailbody_$today.txt
