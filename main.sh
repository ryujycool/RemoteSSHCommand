#----------------------------------------------------------------------
# Set up values, very important put a valid user an password to execute commands on remote host
#----------------------------------------------------------------------
 
# User credentials for the remote server.
USER=root
PASS=Abc123.
 
# The REMOTE server hostname.
SERVER=10.10.10.1
 
# The script to run on the remote server. MUST BE A VALID PATH
SCRIPT_PATH=./comands_to_execute.sh

# Desired location of the script on the remote server.
REMOTE_SCRIPT_PATH=/tmp/remote-script.sh
 
#----------------------------------------------------------------------
# Create a temp script to echo the SSH password, used by SSH_ASKPASS
#----------------------------------------------------------------------
 
SSH_ASKPASS_SCRIPT=/tmp/ssh-askpass-script
cat > ${SSH_ASKPASS_SCRIPT} <<EOL
#!/bin/bash
echo "${PASS}"
EOL
chmod u+x ${SSH_ASKPASS_SCRIPT}
 
#----------------------------------------------------------------------
# Set up other items needed for OpenSSH to work.
#----------------------------------------------------------------------
 
# Set no display, necessary for ssh to play nice with setsid and SSH_ASKPASS.
export DISPLAY=:0
 
# Tell SSH to read in the output of the provided script as the password.
# We still have to use setsid to eliminate access to a terminal and thus avoid
# it ignoring this and asking for a password.
export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
 
# LogLevel error is to suppress the hosts warning. The others are
# necessary if working with development servers with self-signed
# certificates.
SSH_OPTIONS="-oLogLevel=error"
SSH_OPTIONS="${SSH_OPTIONS} -oStrictHostKeyChecking=no"
SSH_OPTIONS="${SSH_OPTIONS} -oUserKnownHostsFile=/dev/null"
 
#----------------------------------------------------------------------
# Run the script commands_to_execute.sh on the remote server.
#----------------------------------------------------------------------
 
# Load in a base 64 encoded version of the script.
B64_SCRIPT=`base64 --wrap=0 ${SCRIPT_PATH}`
 
# The command that will run remotely. This unpacks the
# base64-encoded script, makes it executable, and then
# executes it as a background task.
CMD="base64 -d - > ${REMOTE_SCRIPT_PATH} <<< ${B64_SCRIPT};"
CMD="${CMD} chmod u+x ${REMOTE_SCRIPT_PATH};"
CMD="${CMD} sh -c 'nohup ${REMOTE_SCRIPT_PATH} > /dev/null 2>&1 &'"
 
# Log in to the remote server and run the above command.
# The use of setsid is a part of the machinations to stop ssh
# prompting for a password.
setsid ssh ${SSH_OPTIONS} ${USER}@${SERVER} "${CMD}"
