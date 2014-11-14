##Setup
We paid for three EC2 t2.small instances in Amazon AWS in the US East (N. Virginia) region.  Each one was a Windows Server 2012 Base instance.  One was a master and two were slave machines to run the test or drive the browser depending on the task at hand.  The two slaves were only utilized for the Selenium Grid 2 and Jenkins setup.  Here is what I had to do in order for the framework to work for each strategy.  All three instances were put into the same security group in AWS so they were able to communicate to each other.  

###Machine Setup
####Security Group
- Incoming Traffic – 4444, 5555, 5556 TCP for the Security Group Allowed (Not sure this was necessary, but did it anyway)
- Outgoing Traffic – All Traffic Allowed

####Master
				
|                                                | BrowserStack | Sauce Labs | Selenium Grid 2 | Jenkins |
|------------------------------------------------|--------------|------------|-----------------|---------|
| Install Ruby                                   |       x      |      x     |        x        |    x    |
| Install Dependent Gems                         |       x      |      x     |        x        |    x    |
| Install Java JRE                               |              |            |        x        |    x    |
| Open firewall for 4444, 5555, 5556             |              |            |                 |    x    |
| Download selenium-server-standalone-2.43.1.jar |              |            |                 |    x    |

			
####Slaves
	
|                                                | BrowserStack | Sauce Labs | Selenium Grid 2 | Jenkins |
|------------------------------------------------|--------------|------------|-----------------|---------|
| Install Ruby                                   |              |            |        x        |    x    |
| Install Dependent Gems                         |              |            |        x        |    x    |
| Install Java JRE                               |              |            |        x        |    x    |
| Open firewall for 4444, 5555, 5556             |              |            |                 |    x    |
| Download selenium-server-standalone-2.43.1.jar |              |            |                 |    x    |
| Install Firefox 31.0                           |              |            |        x        |    x    |

###Strategy Configuration
####BrowserStack
#####Master
- Setup
    - Have a BrowserStack account
- Environment Variables
    - BS_USERNAME = <-BrowserStack username->
    - BS_AUTHKEY = <-BrowserStack authorization key->
    - DRIVER = BROWSERSTACK
- Commands
    - `$ rspec -t group_1`
    - `$ rspec -t group_2`
    
####Sauce Labs
#####Master
- Setup
    - Have a Sauce Labs account
- Environment Variables
    - SAUCE_USERNAME = <-Sauce Labs username->
    - SAUCE_ACCESS_KEY = <-Sauce Labs access key->
    - DRIVER = SAUCELABS
- Commands
    - `$ rspec -t group_1`
    - `$ rspec -t group_2`
    
####Selenium Grid 2
#####Master
- Setup
    - `$ java -jar selenium-server-standalone-2.43.1.jar -role hub`
- Environment Variables
    - DRIVER = GRID
- Commands
    - `$ rspec -t group_1`
    - `$ rspec -t group_2`
    
#####Slave 1
- Setup
    - `$ java -jar selenium-server-standalone-2.43.1.jar -role node -hub http://<master_ip>:4444/grid/register -port 5555`
- Environment Variables
- Commands 

#####Slave 2
- Setup
    - `$ java -jar selenium-server-standalone-2.43.1.jar -role node -hub http://<master_ip>:4444/grid/register -port 5556`
- Environment Variables
- Commands 

####Jenkins
#####Master
- Setup
    - Install Jenkins
    - Run Jenkins
    - Download needed plugins
        - Git plugin
        - Copy To Slave Plugin
        - Node Label Parameter Plugin
    - Add Slave Nodes
    - Configure Git
    - Configure Jobs
        - pull – Pulled latest from git and triggered group_1 and group_2 jobs
        - group_1 – Copies project files from master.  Executes regression tests with tag => group_1
        	- `rspec -t group_1`
        - group_2 – Copies project files from master.  Executes regression tests with tag => group_2
        	- `rspec -t group_2`
- Environment Variables
    - DRIVER = JENKINS
- Commands
    - Trigger pull job (top most, aggregates down)
    
#####Slave 1
- Setup
    - `$ java -jar slave.jar -jnlpUrl http://<master_ip>:8080/computer/<slave-name>/slave-agent.jnlp`

- Environment Variables
- Commands
- 
#####Slave 2
- Setup
    - Navigate to Jenkins and start slave-agent via command line
- Environment Variables
- Commands
