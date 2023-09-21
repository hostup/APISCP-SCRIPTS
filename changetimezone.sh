for i in ` /usr/bin/apnscp_php /usr/local/apnscp/bin/cmd admin:get-domains| sed 's/\:./site-domain-seperator/'| sed 's/.*site-domain-seperator//'` ;
do
sitedomainname=`echo $i| sed 's/.*site-domain-seperator//'`
cpcmd -d $sitedomainname common:set-timezone Europe/Stockholm
done
