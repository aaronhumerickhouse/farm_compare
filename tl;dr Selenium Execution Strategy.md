#TL;DR - Selenium: to SaaS or not to SaaS

I looked at using a distributed build via Jenkins, Selenium Grid 2, Sauce Labs, and BrowserStack in order to see what strategy was correct for us in order to run our Selenium tests in parallel.  Unfortunately, BrowserStack didn't work as I had expected and am currently in the midst of customer support.

>I apologize this is taking much longer than expected. We are still actively working on a fix. Rest assured we will keep you posted as things progress. - BrowserStack Support

I set up three small EC2 machines on Amazon AWS, which is the size that BrowserStack uses.  This keeps our results comparable each other.   There was one master machine and two slave machines.  The master machine had Jenkins installed on it and was the hub for Selenium Grid 2, Sauce Labs, and BrowserStack.  The two slave machines executed the tests for the distributed build and for Selenium Grid 2.  There were two groups of five tests each, the tests were identical other than the tag for grouping.  I ran the tests in parallel for all four strategies and the results are below with the exclusion of BrowserStack.


|     | Average Time Per Test | Average Test Time per Suite | Average Overhead Time per Suite | Total Average Suite Time |
|--------------|-----------------------|-----------------------------|---------------------------------|------------|
| Grid         | 00:06.90              | 00:34.50                    | 00:00.65                        | 00:35.15   |
| Jenkins      | 00:03.68              | 00:18.40                    | 00:30.79                        | 00:49.19   |
| Sauce Labs   | 00:32.32              | 02:41.60                    | 00:00.97                        | 02:42.57   |


When it comes to running tests on local infrastructure, they are fast. A distributed build test execution is faster than Selenium Grid 2 however the entire suite performance depends on how many tests are executed compared to any setup due to necessary overhead (copying framework to the slaves in our case).  A distributed build can be more difficult to maintain than Selenium Grid 2. Selenium Grid 2 will maintain it's performance standard because there is no overhead required to run a test.  A distributed build would be a good option if one was already set up or if you aren't afraid of maintenance. 

The benefit of a SaaS service is simple.  Servers do not have to be maintained in order to execute tests; it's very easy to use hundreds of different configurations.  Unfortunately, I wasn't able to compare Sauce Labs and BrowserStack side by side.  The detriment is that testing requires a lot more time which has to be paid for, whether it be monetary, slow throughput, or a bigger disruption in the development cycle.  

The decision between using a SaaS service for running Selenium tests in parallel and creating your own server farm really depends on the organization.  If throughput is your first priority, then Jenkins or Selenium Grid 2 are a great options, but if adding more infrastructure is a nightmare, it's a lot easier to hand off to BrowserStack or Sauce Labs.


To see the results, logs, and source code, view it on [Git Hub](http://github.com/aaronhumerickhouse/farm_compare)