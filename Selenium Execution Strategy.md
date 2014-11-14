#Time Analysis of Running Selenium Tests in Parallel

##Introduction
Having recently joined Sport Ngin as an Automation Engineer, I needed to choose a strategy to execute an Automation Regression Suite.  With the vastness that is our web applicationw, we need to be able to perform Automated Regression Tests in a way that avoids disrupting development workflow without sacrificing the value it provides.  Thankfully there are tools that aim to balance usefulness and unobtrusiveness.  I'm going to talk specifically about tools based around Selenium WebDriver.  Selenium Grid 2 easily allows for testing multiple browsers on multiple computers.  There's BrowserStack and Sauce Labs which are SaaS services that run on top of Selenium Grid 2 utilizing Amazon's AWS EC2 instances.  There are also other tools that help create distributive systems, such as Jenkins.  I've created a handful of Automation Frameworks in the past and have run them on a local server farm as well as in Sauce Labs and in BrowserStack. Comparing these four strategies, I need to find a balance that is right for Sport Ngin. 

##The Framework
The goal was to keep everything as simple as possible.  We are a Ruby house so I wrote my framework and tests in Ruby.  It's intentionally a very simple framework including Selenium and RSpec (a testing tool for the Ruby programming language with BDD as a core ideal).  There was no need for a Rakefile, just a spec_helper and the specs (tests).  The spec_helper starts the drivers, depending on the strategy, and creates a logger before each test, it also quits the driver after each test.  This is done utilizing RSpec's `before :all` and `after :all` configurations.  In JUnit, the equivalent would be `@Before` and `@After`.  I wrote one test and copied it for 10 identical tests in the regression suite.  The 10 tests were split into 2 groups of 5 using RSpec tags.  This was done in order to see how to truly take advantage of running tests in parallel.

##Setup
We paid for three EC2 t2.small instances in Amazon AWS in the US East (N. Virginia) region.  Each one was a Windows Server 2012 Base instance. This comprised one master and two slave machines to run the test or drive the browser depending on the task at hand.  The two slaves were only utilized for the Selenium Grid 2 and Jenkins setup.  All three instances were put into the same security group in AWS so they were able to communicate to each other.  Here is what I had to do in order for the framework to work for each strategy.

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

#####Slave 2
- Setup
    - Navigate to Jenkins and start slave-agent via command line
- Environment Variables
- Commands

		
##The Tests

Every test is identical each other, other than the tag. A sample can be found as a [gist](https://gist.github.com/aaronhumerickhouse/a38f3337cf60fc9952dc) or all the tests can be found in the [Github repository](https://github.com/aaronhumerickhouse/farm_compare/tree/master/spec).  Five of them were group_1 and the others were group_2.  The tests were manipulating a static form found at: [watir-example](http://bit.ly/watir-example).  As the site is designed for testing Watir WebDriver, it was just as appropriate to test Selenium WebDriver.  The suites were executed in parallel.  Jenkins manages it by it's nature of distribution.  BrowserStack, Sauce Labs, and Selenium Grid 2 required me to use two terminals (command prompts).  On one terminal I ran `rspec -t group_1`, the other I ran `rspec -t group_2`.  Both set of tests were executed at roughly the same time to ensure parallel testing.   To get some consistency in my results, I ran each set 5 times for a total of 50 test executions for each strategy.


##Results
|     | Average Time Per Test | Average Test Time per Suite | Average Overhead Time per Suite | Total Average Suite Time |
|--------------|-----------------------|-----------------------------|---------------------------------|----------|
| Grid         | 00:06.90              | 00:34.50                    | 00:00.65                        | 00:35.15 |
| Jenkins      | 00:03.68              | 00:18.40                    | 00:30.79                        | 00:49.19 |
| Sauce Labs   | 00:32.32              | 02:41.60                    | 00:00.97                        | 02:42.57 |
| BrowserStack | 02:31.44              | 12:37.20                    | 00:23.80                        | 13:01.00 |

![Average Test Time](file:///Users/aaronhumerickhouse/farm_compare/results/images/Average%20Test%20Time.png)

![Average Suite Time](file:///Users/aaronhumerickhouse/farm_compare/results/images/Average%20Suite%20Time.png)

|              | Average Time per Test | % Difference |
|--------------|-----------------------|--------------|
| Grid         | 00:06.90              | -87.54%      |
| Jenkins      | 00:03.68              | 0.00%        |
| Sauce Labs   | 00:32.32              | -778.45%     |
| Browserstack | 02:31.44              | -4016.09%    |

![Percentage Difference](file:///Users/aaronhumerickhouse/farm_compare/results/images/Percentage%20Difference.png)



###JENKINS
Jenkins behaved as expected.  There was some overhead involved due to copying files from Master to each slave.  This is necessary so each slave is testing with the same version of code.  The more tests that are included, the less the overhead becomes detrimental, as Copying files only has to happen once for each slave node per regression test cycle.  The overhead consisted of 30.79 seconds on average.  If our test suite consists of 100 tests that take a minute each then 31 seconds becomes irrelevant.  Each test took, on average, 3.68 seconds.  This is by far the fastest.  This is due to no network traffic needed to execute the test, and is by far the fastest although there is quite a bit more setup involved.

###SELENIUM GRID 2
Selenium Grid 2 behaved as expected.  There was negligible overhead and all tests passed.  The Average Suite time was 35.15 seconds, meaning each test took roughly 7 seconds.  This is about 87% slower than Jenkins's test time numbers.  It's overal suite time is still faster due to Jenkins copying files to each node.  If the test set was larger, a distributed build driven by Jenkins would eventually be faster than the Selenium Grid 2.  This is much faster than Sauce Labs and BrowserStack (if we could have reliable executions), due to everything communicating through an intranet as opposed to communicating via internet (or, put more simply, network latency).

###SAUCE LABS
Sauce Labs behaved as expected.  There was negligible overhead and all tests passed.  The Average Suite time was 2 minutes 42 seconds, meaning each test took roughly 32 seconds.  This is almost 8 times slower than Jenkins's test time numbers.  Personally, I don't know what takes Sauce Labs 4-5 times longer to execute a test.  I know some of the time is based on their debugging tools such as: screenshots, test analyzer, and video playback.  More time is required to extra network latency.  However I don't believe that should account for 4-5 times more time.


###BrowserStack
Unfortunately at the time of performing this analysis, BrowserStack failed to work as I had hoped.  Only 5 of our 50 test executions passed, whereas they past 100% on every other strategy I tested. There were two common errors:  `CLIENT_STOPPED_SESSION`, which immediately killed the BrowserStack session due to an error that WebDriver reported, and `SO_TIMEOUT` which took 4 minutes to kill the BrowserStack session.  This is why the results show time per test is much longer in BrowserStack.  The extra overhead in BrowserStack is due to the WebDriver timing trying to find an element that does exist.  I've emailed BrowserStack support about why the tests are failing without explanation on November 4, 2014.  As of November 14, 2014 I have only received an email (after inquiring about it) saying “I apologize this is taking much longer than expected. We are still actively working on a fix. Rest assured we will keep you posted as things progress.”  I do plan on executing this again if BrowserStack ever gets to me.  It's worth noting that the 5 tests that did pass average to 22.60 second test execution time.  Also, I am able to execute other tests on BrowserStack with better results.
	

##Conclusion
Unfortunately, I wasn't able to compare Sauce Labs and BrowserStack side by side.  Jenkins test execution is faster than Selenium Grid 2 however the entire suite performance depends on how many tests are executed compared to any setup.  Jenkins takes more maintenance than Selenium Grid 2 will take. Selenium Grid 2 will maintain it's performance standard because there is no overhead required to run a test. Jenkins would be a good option if a Jenkins instance was already set up or if you aren't afraid of maintenance.  Jenkins is very customizable, it has almost any plugin you could ever need.  The benefit of a SaaS service is simple.  Servers do not have to be maintained in order to execute tests; it's very simple to use hundreds of different configurations.  The detriment is that testing requires a lot more time, which has to be paid for.  The decision between using a SaaS service for running Selenium tests in parallel and creating your own server farm really depends on the organization.  If throughput is your first priority, then Jenkins or Selenium Grid 2 are a great option, but if infrastructure is a nightmare, it's a lot easier to hand off to BrowserStack or Sauce Labs

To see the results, logs, and source code, view it on [Git Hub](http://github.com/aaronhumerickhouse/farm_compare)