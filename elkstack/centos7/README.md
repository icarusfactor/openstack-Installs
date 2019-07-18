## Install ELKStack 7.x  OSS on CentOS7.6  

PROLOGUE: Reason for using an ELKStack is for billing,monitoring and tracing to subvert problems
when they occur in real world situations and act on them. When your systems start to turn into large
 numbers,the managability aspect reaches a new level and this stackis the answer to this problem. 


## Install Java

Elasticsearch needs binaries and the development files. 

```

$ sudo yum -y install java-openjdk-devel java-openjdk

```
______

## Add ELK Repository

This provides all of the OSS packages.

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

## Clear And Update YUM 

```

$ sudo yum clean all
$ sudo yum makecache

```


## Import GPG Key

Make sure Elasticsearch packages are sourced from correct repository. 

```
$ sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

```

## Install ELKStack 

```

$ sudo yum -y install elasticsearch-oss
$ sudo yum -y install logstash-oss
$ sudo yum -y install kibana-oss

```

## Confirm Packages

```

$ rpm -qi elasticsearch-oss 
$ rpm -qi logstash-oss
$ rpm -qi kibana-oss

```

## Start Eleasticsearch 

```

$ sudo systemctl daemon-reload
$ sudo systemctl start elasticsearch.service

```

***OPTIONAL:*** ```$ sudo systemctl enable elasticsearch.service```

NOTE: This is a Java service so it takes up lots of memeory and CPU
it may be best to manually start it after Openstack has started if
you're on a single node lab system.     



## Test The REST Interface 

```

$ curl http://127.0.0.1:9200 

```

## Start Logstash

```
$ sudo systemctl start logstash.service
$ sudo systemctl status logstash.service

```

***OPTIONAL:***  ``` $ sudo systemctl enable logstash.service ```  


Custom INPUT/FILTER/OUPUT logstash config files go into this directory. 

```

$ cd /etc/logstash/conf.d/

```

## Add OVS Plugin

To monitor OPENSTACK networking with OpenVswitch we will need to add a 
plugin to gather information for the Software Defined Switch.

```

$ /usr/share/logstash/bin/logstash-plugin install logstash-codec-sflow

```

NOTE: These files have to pass a syntax check, if they have any problem it
will stop entire losgstash system from working so do not put just any file
in here unless it passes this test.

```

/usr/share/logstash/bin/logstash -t -f <LOGSTASH CONFIG FILE>

```


NOTE: Logstash has strict block segment parsing for the input, filter and output sections.
You'll need an empty line between each section. No inital top empty line needed.
use double parenthese "" on items. Strick no empty space inside
segments, unless its an "if" statement. Other progmatic limitation that I have not ran into yet.

## Create Logstash Config

Create a conf file for sflow in the /tmp directory and test it, then, if okay copy it to conf directory.

***NOTE: This file has errors in it!*** Using it as a test. You will have to change the paratheses 
to the correct ones from “ to ".

```
 
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

```

## Test Logstash Config

Run test on config file and ***DO NOT PROCEED*** to next step until fixed and says OK

```

$ /usr/share/logstash/bin/logstash -t -f /tmp/sflow.conf

```
## Move Config Into Logstash

Copy file to conf directory now that it has passed test. 

```

$ cp /tmp/sflow.conf /etc/logstash/conf.d/

```

## Logstash Setup For Local Logs

If you want to use logstash with local systems logs within the /var/log directory you will
have to give permissions to logstash in order to do this. This will be for the Apache
logs but can be used for any directory in this tree. Alternatly,recommended is to use collectd service
to gather and ship the logs from local and remote systems to logstash, but more complex to setup. This is for an
 easy test to show its working. 


Put logstash in the adm group

```

$ sudo usermod -a -G adm logstash


```

Change logs directory to group readable and executable and files to group readable. 

```

$ sudo chmod 754 /var/log/httpd/
$ sudo chmod 640 /var/log/httpd/*

```

Change group to adm for directory and files. 

```

$ sudo chgrp adm /var/log/httpd/
$ sudo chgrp adm /var/log/httpd/*

```

## Elasticsearch Debug Commands

Helpful but dangerous commands to run on an Eleasticsearch index to see if they are being worked. 
or needing to clear out and start again.

```

curl -X GET "http://localhost:9200/osapache-*/_count"

curl -X DELETE "localhost:9200/osapache-*"


```
## Setup Kibana

Edit Kibana YAML config for your system and use local Elasticsearch server.  

```

sudo vim /etc/kibana/kibana.yml

 server.port: 5601
 server.host: "192.168.1.29"
 server.name: "packstack"
 elasticsearch.url: "http://localhost:9200"


```

## Enable Web GUI For Kibana
 

```

sudo systemctl enable --now kibana

```

## Configure Kibana Access

Packstack IPTABLES will block Kibana access, so we need to open this port.
Check the line numbers for all of the rules that were added by Packstack.
Look for the the last rule before any DENY or REJECT rules as putting any
rules after these will make them useless.

```

$ sudo iptables -L --line-numbers


```

Should be okay to insert a rule at line 30 or before. We will put it at the end.


```

$ sudo iptables -I INPUT 30 -p tcp -m multiport --dports 5601 -j ACCEPT -m comment --comment "Kibana 5601 incoming"

```

Save state of IPTABLES

```

$ service iptables save

```

## Test Kibana Acess

Now you can start your browser and load the URL on your desktop system.

```

$ elinks http://192.168.1.29:5601    

```

## Configure Kibana Index 

Now that we have KIBANA setup we will configure a basic Index, Visulaize items and a Dashboard setup.

Go to the URL 

```
URL: http://192.168.1.29:5601/

```

Click on "Connect to your Elasticsearch index" under the title: Use Elasticsearch data.

Click on "Index Patterns"

Click on "Create Index Patterns"


Fill in the Index Pattern entry "osapache=*"

Once Logstash starts collecting logs and sends its data to Elasticsearch archive, Kibana
should auto detect that it found information and you should see ***Success!*** and "> Next step" will be enabled.

After clicking the enabled button, click on the drop down box and select "@timestamp".


## Test Kibana Index

Now the trick is to ***"prime the pump"*** to get the data generated to Elasticsearch we want to monitor.
Having now setup Openstack, log into the Horizon interface. This will generatee Keystone Access data.

Wait a short time.Should be less than 5mins.

Click on left menu item "Discovery" tooltip will show up on mouse hover.

Above title "Selected fields" Make sure "osapache-*" is selected in the dropdown. 

In Avaialable fields column, click fileds "type".

You should see "keystone-access" with a spyglass + on it. Click it.

After Kibana processes the log ***"Keystone-access"*** should be highlighted within the log view. 


## Filter Index Output

Next to further refine data is to select "add" on Available field "messages".
You should now have a list of date timestamps and what IP accessed the Openstack login in log view.

## Save Index With Filter

We're wanting to createing useful data to monitor. So we'll save this as a saved Index with + filter
by clicking on the "Save" option in the upper menu and calling it "Keystone Access".

## Add Visual For Index

Now we are going to click on left icon "Visualize".

Click on "+ Create new visualization".

This will bring up the type of display we want to conifgure the data for. 

We will use "Metric".
Then click our configured index pattern+filter we called Keystone Access.
 
Leave default as count and fill Custom Label with "Keystone Access".

Click the play icon to process configuration. You should see the label change. 

Next click split group. Then Aggregation, select Date Range field leave as @timestamp.

In the "From" change to "now-1w/w" and "to" to now.
  
The -1 means only look in the logs back 1 week and /w means round to closest week. 

Next turn off the split group data by moving the slider to off, so we only see the number and label.

Now we will save this visualization as Access Vis.

## Add Another Visual 

Now to make another visual. Pick "Vertical Bar" and "Keystone Access"

Y axis we want to know amount of access during this time frame so leave as count and fill in label as Accesses.

X axis aggregation. Pick Date histogram. @timestamp minimal interval as Auto. Click the play. 

Save this vis as Access Time Vis.


## Generate Logstash Data

Since we have installed and can access the Openstack Horizon dashboard lets see if it picks up our access.
You will have to wait an interval and click on some areas while in the dashboard. 


## Create Dashboard With Visuals

Now that we have a few active widgets showing Openstack data,lets make a dashbaord.

Click on Dahsboard icon. +Create new dashboard.

Add Keystone Access. 

Add Access Time Vis.

Access vis.

Then click X to get out of the Add Menu.

You should see your visuals in one page now.

This dashboard is not static so you can move the items aruond and strech them to your liking. 

After you do this. You can "Save" your dashboard as "Keystone Access Dashboard".


## Full Screen Mode

Now to set it as a desktop Dashboard you can click "Full Screen" an monitor your data and add refresh plugin
to your browser so you can get the latest data. Hope this gives you insight into how to make a dashboard in
Kibana to now create your own. 


## Basic Collectd Overview

While this installtion shows you how to monitor local
logs, you can install the Open Source edge computing monitor
collectd. This is a default Logstash plugin to collect
metrics from VMs and other systems. I will move this
section to its own page when I get it worked out with more details. 


## Install Collectd From EPEL Repo


```
$ yum install epel-release
$ yum install collectd
$ vi /etc/collectd.conf
```

## Add Hostname To Config File

```

$ vi /etc/collectd.conf


```

## Enable And Start Collectd

```

$ systemctl enable collectd
$ systemctl start collectd

```


## Example Collectd Config 


```
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

```

## Example Logstash Input for Collectd

```

input {
  udp {
    port => 25826
    buffer_size => 1452
    codec => collectd { }
  }
}

```
