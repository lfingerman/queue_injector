### DataFaker - repo of tools intended to help simulate test data 
***
#### queue_injector app
The need for queue_injector came from multiple teams who wanted a simple way to post test messages to the message queue services i.e. for integration testing.
What makes queue_injector simple and valuable: 
```
1. Simple Sinatra-based RestFul web service. 
2. It figures a way to post your test message to either TIBCO or 
ActiveMQ message queue services. You don't need to worry how to connect with TIBCO or ActiveMQ
3. You will need to know the server's endpoint (URL), username, password, 
queue name and the message itself. queue_injector will do the magic of posting your message for you.
```
#### Deploying and running
```
Requirements: 
1. latest version of jruby (tested with jruby 1.7.18)
2. Install Bundler ('gem install bundler')

To deploy/host this as service run:
'jruby -S bundle exec jruby lib/queue_injector.rb'
(This is based on WEBrick 1.3.1 which comes with sinatra)

General usage:
Point the REST client at one of these endpoints 
for TIBCO:
<hostname><port>/qinjector/tibco

for ActiveMQ:
<hostname><port>/qinjector/activemq

http://<hostname>:7654
and 
http://<hostname>:7654
for redundancy

So for example to post a message to activemq this would be the full endpoint
http://<hostname>:7654/qinjector/activemq
```
#### Examples of using deployed qinjector API
http://screencast.com/t/QwAQhCgN4

#### Format of the Headers:

##### Required Headers :
---
* `Content-Type` (ex: application/xml or application/json)
* `SERVER_URL` (ex: tcp://<hostname>:8222)
* `USERNAME` (ex: <username> if set on the queue)
* `PASSWORD` (ex: <password> if set on the queue)
* `QUEUE_NAME` (ex: blah.tibco.0101.outbound.queue)

##### Optional Headers:
---
custom headers will be converted and posted to the queue as part of test message header
use a common hash notation key-value pair separated by semi-column to send multiple header values
* `CUSTOM_HEADER` (ex: key1=>value1;key2=>value2)


#### Format of the Message Body:
---
* Example of XML message (set Content-Type to application/xml in the header):
```
<foo>testtestest</foo>
```
* Example of JSON message (set Content-Type to application/json in the header):
```
{
  "foo": "testtestest"
}
```

#### Limitations:
---
1. It currently does not support retrieval of your messages off the queue i.e. HTTP GET 

