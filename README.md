Dell Venue 8 Pro WiFi Issue Fix
===================
----------

Big thanks to Drahnier for testing and coming up with solution #2.

## Problem
It seems like many Dell Venue 8 Pro (dv8p) Windows 8.1 systems are affected by an issue where wireless adapter does not wake up after being suspended. In my case, whenever the device was put to sleep, whether by screen timeout or by pressing the power button, and then woken up the wireless adapter would not reconnect to the wireless router or the access point.

The wireless adapter needed to be **reset** (disabled and then enabled) in order to reconnect to the wireless network.
Until Dell comes up with a fix, either one of the two solution below can be used.


##*Condensed Solution #1*

*If you would like to understand all the steps please read the* **Explained Solution**. *For quick solution you will need 2 files:*

1. *https://github.com/vstarostenko/dv8p_wifi_issue_fix/blob/master/script/reset_network_adapter.ps1*
2. *https://github.com/vstarostenko/dv8p_wifi_issue_fix/blob/master/task/ResetWiFi_1.xml*



- *Save the script in `C:\`*
- *Import the task ResetWiFi_1.xml in Task Scheduler*

## Explained Solution #1
Write a script that resets the wireless network adapter right after the tablet wakes up after sleep. 

Because dv8p has a full version of Windows 8.1 we are able to utilize all of the advanced features of the operating system. For this fix, we will be using Windows Task Scheduler, Even Viewer, and Windows PowerShell.

### Step 1: Script

The script that resets the network adapter can be found in this repo inside the "script" folder. The script is: `reset_network_adapter.ps1`
https://github.com/vstarostenko/dv8p_wifi_issue_fix/blob/master/script/reset_network_adapter.ps1

Before the script can be executed we need to enable Windows PowerShell to run scripts. By default this feature is disabled.

***Commands:***

Open PowerShell as Administrator and run this command:

*`Set-ExecutionPolicy RemoteSigned`*

This enables PowerShell to run scripts.
Next, we run a command to see the list of installed network adapters:

*`Get-wmiobject win32_NetworkAdapter`*

This gives us a list of network adapters installed on our dv8p, and the output should look something like this:

    ServiceName  : ar6knwf
    MACAddress   : XX:XX:XX:XX:XX:XX
    AdapterType  : Ethernet 802.3
    DeviceID : 0
    Name : Dell Wireless 1538 802.11 a/g/n Adapter
    NetworkAddresses :
    Speed: 300000000

What we are interested in is the line that has the DeviceID because this is the ID that will go into our script.

***Script:***

The script itself has 3 lines:

    $adapter = Get-WmiObject win32_networkadapter | where {$_.DeviceId -eq 0}
    $adapter.Disable()
    $adapter.Enable()

The 1st line gets the correct adapter and sets that adapter object to a temporary variable called "adapter". IMPORTANT: `{$_.DeviceId -eq 0}` should be changed to reflect the DeiceID should be set to the same ID as we got when we ran the *`Get-wmiobject win32_NetworkAdapter`* command. In my case the ID was 0. (I believe this will be the case for many dv8p's, the only exception might be if you are running an external USB network adapter).

In lines 2 and 3 we apply the Disable() and Enable() methods to our adapter variable. This in turn disables and right away enables the network adapter.

Download the script and save it in your root directory: `C:\`
Alternatively, you can copy the 3 lines of the code, paste them in any text editor (Notepad), and save the file with `.ps1` extension.
Our script is ready.

### Step 2: Event
Now that we have our script, in order to know at what point we should execute it, we need to understand what event is recorded by the system as soon as the tablet wakes up (power button is pressed). For this, we turn to the Event Viewer.

To open event viewer swipe from right and click on the "search" charm. Type `view event logs` into the search bar. Right below you will see "View event logs" control panel item. Click on it.

![](/screen_shots/Screenshot2.png)

Inside the Event Viewer window expand "Windows Logs" folder and select "System". Now, in the middle section we see the list of log entries and their corresponding information.
In order to see what event gets triggered when the tablet wakes up we put it to sleep by pressing the power button, and then wake it up by pressing the power button. In the even viewer click on "Action" and then select "Refresh". Now we see the latest events, and one of them is an event with event ID **507**. If we select the event by clicking on it we see that in the description we are told that "The system is exiting connected standby."  **This is the event we need.**

![](/screen_shots/Screenshot1.png)

### Step 3: Scheduled Task

The last step is to schedule a task to run the script every time the tablet wakes up.
1. In the Search charm type in `Schedule Tasks`
2. Select the "Schedule Tasks" control panel item
3. Once the Scheduled Task window opens click on Create Task
4. In the General tab give your task a name i.e. `Reset WiFi`
Select "Run whether user is logged in or not"
Select "Run with highest privileges"
![](/screen_shots/Screenshot5.png)
5. In the Triggers tab click New
Select Begin the task: On an event
Log: System
Source: Kernel-Power
Event ID: 507
![](/screen_shots/Screenshot4.png)
6. Click OK, you should now have a new trigger
7. In Actions tab click New
Action: Start a program
Under "Program/Script" type in `PowerShell`
In the "add arguments" box type in the location of your script, including script name i.e. `C:\reset_network_adapter.ps1`
In the "Start in" box type in the location of the script i.e. `C:\`
8. Click OK, you should now have a new action
![](/screen_shots/Screenshot7.png)
9. Click OK again to close and save the new task.
10. You should now see your task in the task list
11. Make sure the Status of the task is set to "Ready".

To test whether the task is running turn your tablet off by pressing the power button and then back on. Keep an eye out on your network connection icon - it should briefly turn off and then turn on.

The Task Scheduler keeps track of whether the task ran successfully. Look for the attributes for your task that say "Last Run Time" and "Last Run Result". The result should say - "Operation completed successfully . (0x0)"

Just in case the script doesn't run, reboot your machine. Then try again.

##*Condensed Solution #2*

This solution is courtesy of Drahnier.
*If you would like to understand all the steps please read the* **Explained Solution #2**. *For quick solution you will need 2 files:*

1. *https://github.com/vstarostenko/dv8p_wifi_issue_fix/blob/master/devcon/devcon.exe*
2. *https://github.com/vstarostenko/dv8p_wifi_issue_fix/blob/master/task/ResetWiFi_2.xml*



- *Download and save the devcon.exe file in `C:\Windows\System32`*
- *Import the task ResetWiFi_2.xml in Task Scheduler*

## Explained Solution #2

This solution is courtesy of Drahnier.
This method is very similar to the method above, except instead of PowerShell we will use DevCon.


### Step 1: Devcon

> The DevCon utility is a command-line utility that acts as an alternative to Device Manager. Using DevCon, you can enable, disable, restart, update, remove, and query individual devices or groups of devices. DevCon also provides information that is relevant to the driver developer and is not available in Device Manager.
> -Microsoft

For more information on DevCon see this link:
http://support.microsoft.com/kb/311272

Download devcon.exe from either the repository or the Microsoft link above. Once the file is downloaded save it in `C:\Windows\System32` directory.

### Step 2: Scheduled Task

The scheduled task steps are very similar to the Solution #1 Step 3, except for the "Action" part. 

1. In the Search charm type in `Schedule Tasks`
2. Select the "Schedule Tasks" control panel item
3. Once the Scheduled Task window opens click on Create Task
4. In the General tab give your task a name i.e. `Reset WiFi`
Select "Run whether user is logged in or not"
Select "Run with highest privileges"
![](/screen_shots/Screenshot5.png)
5. In the Triggers tab click New
Select Begin the task: On an event
Log: System
Source: Kernel-Power
Event ID: 507
![](/screen_shots/Screenshot4.png)
6. Click OK, you should now have a new trigger
7. In Actions tab click New
Action: Start a program
Under "Program/Script" type in `C:\Windows\System32\devcon.exe`
In the "add arguments" box type in `restart =net "sd\vid_0271&amp;pid_0418"`
Leave the "Start in" box blank
8. Click OK, you should now have a new action
![](/screen_shots/Screenshot10.png)
9. Click OK again to close and save the new task.
10. You should now see your task in the task list
11. Make sure the Status of the task is set to "Ready".
