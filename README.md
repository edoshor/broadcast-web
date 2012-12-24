broadcast-web
=============

BB web broadcast management system.

Transcoder Tests
----------------

The system executes commands on a transcoder under test.

Documentation of available commands, their syntax and options can be found [here](https://docs.google.com/document/d/1x0hHctqYnT6EKKEcpBDgx4fnJd2g-QLy9T6FpbJTu48/edit).


### Changing a transcoder under test:
The transcoder under test is called **master**. Extra load commands targets a **slave** transcoder.

Master and slave can be the same actual transcoder.

To change the master or slave transcoder issue a GET request to  `/transcoder_test/host` with the following params

+ ip - transcoder host ip address
+ slave - Optional. Set to true if you wish to change the slave

For example, if the system is available at `http://localhost:3000/`.

To change master transcoder,

[http://localhost:3000/transcoder_test/host?ip=10.65.6.103](http://localhost:3000//transcoder_test/host?ip=10.65.6.103)


To change slave transcoder,

[http://localhost:3000/transcoder_test/host?ip=10.65.6.103&slave=true](http://localhost:3000//transcoder_test/host?ip=10.65.6.103&slave=true)

**Important:** the system will not function correctly without both master and slave transcoders.

