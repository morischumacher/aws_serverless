# Get IP of localstack_main and append to /etc/hosts
ip_address=$(getent hosts localstack_main | awk '{ print $1 }')
echo "$ip_address localhost" >> /etc/hosts

# Bootstrap and deploy using cdklocal
cdklocal bootstrap
cdklocal deploy --all --require-approval never
