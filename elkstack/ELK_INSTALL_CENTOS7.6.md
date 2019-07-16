## Install the OSS ELKStack 7.x for logging, monitoring,billing on CentOS7.6  

1. Elasticsearch depends on Java so we will need to install the binaries and development files. 

```

$ sudo yum -y install java-openjdk-devel java-openjdk

```
______

2. Add the ELKstack repository which provides all of its OSS packages.

```

$ sudo cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

```

______

3. Clear and update YUM package index.

```

$ sudo yum clean all
$ sudo yum makecache

```

______

4. Import GPG key for Elasticsearch. 

```
$ sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

```

______

5. Install Open Source Version of the ELKStack 7.x

```

$ sudo yum -y install elasticsearch-oss
$ sudo yum -y install logstash-oss
$ sudo yum -y install kibana-oss

```

6. Confirm package install

```

$ rpm -qi elasticsearch-oss 
$ rpm -qi logstash-oss
$ rpm -qi kibana-oss

```


7. Start and enable persistant services for eleasticsearch 

```

$ sudo systemctl daemon-reload
$ sudo systemctl start elasticsearch.service

```

***OPTIONAL:*** ` $ sudo systemctl enable elasticsearch.service `

NOTE: This is a Java service so it takes up lots of memeory and CPU
it may be best to manually start it after Openstack has started if
you're on a single node lab system.     

8. Test REST interface with curl. 

```

$ curl http://127.0.0.1:9200 

```

9. Start and enable persistant services for logstash

```
$ sudo systemctl start logstash.service
$ sudo systemctl status logstash.service

```

***OPTIONAL:*** ` $ sudo systemctl enable logstash.service `  

10. Custom INPUT/FILTER/OUPUT logstash config files go into this directory. 


```

$ cd /etc/logstash/conf.d/

```

#To monitor OPENSTACK networking with OpenVswitch we will need to add a 
#plugin to gather information for the SDN switch.
$ /usr/share/logstash/bin/logstash-plugin install logstash-codec-sflow

#NOTE: These files have to pass a syntax check, if they have any problem it
#will stop entire losgstash system from working so do not put just any file
#in here unless it passes this test.
/usr/share/logstash/bin/logstash -t -f <LOGSTASH CONFIG FILE>

#Logstash has strict block segment parsing for input/filter and out
#You will need an empty line between them. No inital top empty line needed.
#use double parenthese "" on items using them. Strick no empty space inside
#segments, unless its an "if" statement.

#Create conf file for sflow in tmp directory and test it ,then if OK copy it to conf directory.
#NOTE: This file has errors in it! Using it as a test. You will have to change the paratheses 
#to the correct ones from “ to ".
 
sudo cat <<EOF | sudo tee /tmp/sflow.conf
input {
udp {
port => 6343
codec => sflow {}
}
}

output {
elasticsearch {
index => “sflow-%{+YYYY.MM.dd}”
hosts => [“localhost”]
}
stdout {
codec => rubydebug }
}
EOF

#Run test on config file and do not proceed to next step until fixed and says OK
$ /usr/share/logstash/bin/logstash -t -f /tmp/sflow.conf
# copy file to conf directory now that it has passed test. 
$ cp /tmp/sflow.conf /etc/logstash/conf.d/

#If you want to use logstash with local logs within the /var/log directory you will
#have to give permissions to logstash in order to do this. This will be for the Apache
#logs but can be use for any directory in this tree.

#Put logstash in the adm group
$ sudo usermod -a -G adm logstash
#Change logs directory to group readable and executable and files to group readable. 
$ sudo chmod 754 /var/log/httpd/
$ sudo chmod 640 /var/log/httpd/*
#Change group to adm for directory and files. 
$ sudo chgrp adm /var/log/httpd/
$ sudo chgrp adm /var/log/httpd/*


#Helpful but dangerous commands to run on eleasticsearch index to see if they are being worked. 
#or needing to clear out and start again.
curl -X GET "http://localhost:9200/osapache-*/_count"
curl -X DELETE "localhost:9200/osapache-*"


#Edit Kibana YAML config for your system and use local elasticsearch server.  
sudo vim /etc/kibana/kibana.yml

 server.port: 5601
 server.host: "192.168.1.29"
 server.name: "packstack"
 elasticsearch.url: "http://localhost:9200"
 
#Start and enable persistant services for Kibana
sudo systemctl enable --now kibana


#Packstack IPTABLES will block Kibana access, so we need to open this port.
#Check the line numbers for all of the rules that were added by Packstack.
#Look for the the last rule before any DENY or REJECT rules as putting any
#rules after these will make them useless.
$ sudo iptables -L --line-numbers
# Should be ok to insert a rule at line 30 or before. We will put it at the end.
$ sudo iptables -I INPUT 30 -p tcp -m multiport --dports 5601 -j ACCEPT -m comment --comment "Kibana 5601 incoming"
#Save state of IPTABLES
$ service iptables save
# Now you can start your browser and load the URL on your desktop system.
$ elinks http://192.168.1.29:5601    

#KIBANA Index , Visulaize , Dashboard setup.

#Go to the URL 
URL: http://192.168.1.29:5601/

#This will bring you to the main page 
#click on "Connect to your Elasticsearch index" under the title: Use Elasticsearch data.

#Click on "Index Patterns"
#Click on "Create Index Patterns"

#Fill in the Index Pattern entry "osapache=*"

#Once Logstash starts collecting logs and sends it to Elasticsearch archive ,Kibana
#should auto detect that it found information and you should see
Success! and "> Next step" will be enabled.

#After clicking the enabled button, click on the drop down box and select "@timestamp".

#Now the trick is to "prime the pump" to get the data generated to Elasticsearch we want to monitor.
#Having now setup Openstack,log into the Horizon interface. This will generatee Keystone Access data.

#Wait a short time.Should be less than 5mins.

#Click on left menu item "Discovery" tooltip will show up on mouse hover.

#Above title "Selected fields" Make sure "osapache-*" is selected in the dropdown. 

#In Avaialable fields column, click fileds "type".

#You should see "keystone-access" with a spyglass + on it. Click it.

#After Kibana processes the log "Keystone-access" should be highlighted within the log view. 

#Next to further refine data is to select "add" on Available field "messages".
#You should now have a list of date timestamps and what ip accessed the Openstack login in log view.

#We're wanting to createing useful data to monitor. So we will save this as a saved Index with + filter
#by clicking on the "Save" option in the upper menu and calling it "Keystone Access".

#Now we are going to click on left icon "Visualize".

#Click on "+ Create new visualization".

#This will bring up the type of display we want to conifgure the data for. 

#We will use "Metric".
#Then click our configured index pattern+filter we called Keystone Access.
 
#Leave default as count and fill Custom Label with "Keystone Access".

#Click the play icon to process configuration. You should see the label change. 

#Next click split group. Then Aggregation, select Date Range field leave as @timestamp.

#In the "From" change to "now-1w/w" and "to" to now.
  
#The -1 means only look in the logs back 1 week and /w means round to closest week. 

#Next turn off the split group data by moving the slider to off, so we only see the number and label.

#Now we will save this visualization as Access Vis.

#Now to make another visual. Pick "Vertical Bar" and "Keystone Access"

#Y axis we want to know amount of access during this time frame so leave as count and fill in label as Accesses.
#X axis aggregation. Pick Date histogram. @timestamp minimal interval as Auto. Click the play. 
#Save this vis as Access Time Vis.

#Since we have installed and can access the Openstack Horizon dashboard lets see if it picks up our access.
#You will have to wait an interval and click on some areas while in the dashboard. 

#Now that we have a few active widgets showing Openstack data,lets make a dashbaord.

#Click on Dahsboard icon. +Create new dashboard.
#Add Keystone Access. 
#Add Access Time Vis.
#Access vis.

#Then click X to get out of the Add Menu.
You should see your visuals in one page now.

#This dashboard is not static so you can move the items aruond and strech them to your liking. 
#After you do this. You can "Save" your dashboard as "Keystone Access Dashboard".

#Now to set it as a desktop Dashboard you can click "Full Screen" an monitor your data and add refresh plugin
#to your browser so you can get the latest data. Hope this gives you insight into how to make a dashboard in
#Kibana to now create your own. 

#While this installtion shows you how to monitor local
#logs, you can install Open Source edge computing monitor
#collectd. This is a default Logstash plugin to collect
#metrics from VMs and other systems. I will move this
#section to its own page when I get it worked out. 

#Make sure you have the epel repo 
$ yum install epel-release
$ yum install collectd
$ vi /etc/collectd.conf
#Edit to add your hostanme
$ systemctl enable collectd
$ systemctl start collectd

#Example collectd configuration. 
Hostname    "host.example.com"
LoadPlugin interface
LoadPlugin load
LoadPlugin memory
LoadPlugin network
<Plugin interface>
    Interface "eth0"
    IgnoreSelected false
</Plugin>
<Plugin network>
    <Server "10.0.0.1" "25826">
    </Server>
</Plugin>

#Example input for collectd Logstash
input {
  udp {
    port => 25826
    buffer_size => 1452
    codec => collectd { }
  }
}

#Reasons for using an ELKSTACK is for billing,monitoring and tracing to subvert problems
#when they occur in real world situations. So next I will setup monitors for  
#OpenVswitch,Apache and basic bare metal systems health checks on controller/compute
#node that the ELKSTACK and OPENSTACK are hosted on so you shoudl see other conf files 
for logstash in this directory. 

