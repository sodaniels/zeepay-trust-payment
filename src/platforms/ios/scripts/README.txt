Setting up the dev box

What you need:
    - devboxEnvs file containing all the credentials
    - euEnvs file containing credentials for eu development
    - certificate for allowing to actually connect to the dev box host
    - vpn access to TP network

1: 
Copy those files into project directory /scripts
(gitignore file excludes all files in the scripts directory except setup/remove scripts and the readme file)

2: 
to setup the dev box, run './setupDevbox' in your terminal
in the case of missing permissions for execution, run 'chmod 700 setupDevbox' and rerun the script again

3:
Open the simulator that you will be using, so that the home screen is visible

4:
Drag and drop the certificate file on the simulator's home screen

5:
Make sure it is enabled by going to: Settings->General->About->Certificate Trust Settings 
The name of the cert should be visible with switch next to it should enabled

6:
Connect to the TP network and re run the project

7:
After all the testing, make sure to revoke all changes, especially in the /etc/hosts file
To do so, run './removeDevbox' script and you are done.
It will also set credentials for cocoapods-keys poiting to the eu gateway environment
