echo '!!!!! Before running this script make sure to look at README.md in this folder !!!!!

'

echo 'enter node number'
read number
echo 'enter node db_pass'
read db_pass
echo 'enter node aws_access_key_id'
read aws_access_key_id
echo 'enter node aws_secret_access_key'
read aws_secret_access_key
echo 'enter node db_host'
read db_host
echo 'enter node seed'
read seed

echo "imap jk <esc>" > ~/.vimrc
# edit core config file with right ip addresses
echo "edit core config file with right ip addresses in KNOWN_PEERS"
echo "press enter"
read
vim factury/core/etc/factury$number.cfg

# write banner
case "$number" in
    1)
        banner='
_________________________   _____   __    _____                       ______  
___  ____/___  _/_  ____/   ___  | / /______  /___      _________________  /__
__  /_    __  / _  /        __   |/ /_  _ \  __/_ | /| / /  __ \_  ___/_  //_/
_  __/   __/ /  / /___      _  /|  / /  __/ /_ __ |/ |/ // /_/ /  /   _  ,<   
/_/      /___/  \____/      /_/ |_/  \___/\__/ ____/|__/ \____//_/    /_/|_|  
                                                                              
             _________          ______
___________________  /____      __<  /
__  __ \  __ \  __  /_  _ \     __  / 
_  / / / /_/ / /_/ / /  __/     _  /  
/_/ /_/\____/\__,_/  \___/      /_/   
        '
        ;;
    2)
        banner='
_________________________   _____   __    _____                       ______  
___  ____/___  _/_  ____/   ___  | / /______  /___      _________________  /__
__  /_    __  / _  /        __   |/ /_  _ \  __/_ | /| / /  __ \_  ___/_  //_/
_  __/   __/ /  / /___      _  /|  / /  __/ /_ __ |/ |/ // /_/ /  /   _  ,<   
/_/      /___/  \____/      /_/ |_/  \___/\__/ ____/|__/ \____//_/    /_/|_|  
                                                                              
             _________          ______ 
___________________  /____      __|__ \
__  __ \  __ \  __  /_  _ \     ____/ /
_  / / / /_/ / /_/ / /  __/     _  __/ 
/_/ /_/\____/\__,_/  \___/      /____/ 
        '
        ;;
    3)
        banner='
_________________________   _____   __    _____                       ______  
___  ____/___  _/_  ____/   ___  | / /______  /___      _________________  /__
__  /_    __  / _  /        __   |/ /_  _ \  __/_ | /| / /  __ \_  ___/_  //_/
_  __/   __/ /  / /___      _  /|  / /  __/ /_ __ |/ |/ // /_/ /  /   _  ,<   
/_/      /___/  \____/      /_/ |_/  \___/\__/ ____/|__/ \____//_/    /_/|_|  
                                                                              
             _________          ________
___________________  /____      __|__  /
__  __ \  __ \  __  /_  _ \     ___/_ < 
_  / / / /_/ / /_/ / /  __/     ____/ / 
/_/ /_/\____/\__,_/  \___/      /____/  
        '
        ;;
    *)
        banner="
_________________________   _____   __    _____                       ______  
___  ____/___  _/_  ____/   ___  | / /______  /___      _________________  /__
__  /_    __  / _  /        __   |/ /_  _ \  __/_ | /| / /  __ \_  ___/_  //_/
_  __/   __/ /  / /___      _  /|  / /  __/ /_ __ |/ |/ // /_/ /  /   _  ,<   
/_/      /___/  \____/      /_/ |_/  \___/\__/ ____/|__/ \____//_/    /_/|_|  
                                                                              
             _________          
___________________  /____      
__  __ \  __ \  __  /_  _ \     
_  / / / /_/ / /_/ / /  __/    $number  
/_/ /_/\____/\__,_/  \___/     
        "
        ;;
esac
echo "$banner

********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the  *
* evidence from such monitoring to law enforcement officials.      *
*                                                                  *
********************************************************************

Unauthorized use of FIC Network computer and networking resources is prohibited. If you log on to this computer system, you acknowledge your awareness of and concurrence with the FIC Network Use Policy. FIC Network will prosecute violators to the full extent of the law.
" | sudo tee -a /etc/motd

#
# INSTALLATION PART (run at most once this is not repeatable)
#

# install postgres
sudo apt-get install -y postgresql awscli

# install docker
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce

# clone the repo
git clone https://github.com/Ratniex/docker-stellar-core-horizon
cd ~/docker-stellar-core-horizon/
git checkout factury

# build docker
cd ~/docker-stellar-core-horizon/
sudo docker build -t factury-core-horizon .

# run ficnet node.
# make sure to run it with a space at the begining so that this command is not saved in bash_history
echo "should this instance be started with --forcescp? [y/N]"
read answer
if [ $answer = 'y' ]; then
 sudo docker run -d \
    -p "8000:8000" \
    -p "11625:11625" \
    -p "10050:10050" \
    --name node$number \
    factury-core-horizon \
    --network factury \
    --core-config factury$number.cfg \
    --seed $seed \
    --database-host $db_host \
    --database-pass $db_pass \
    --aws-secret-access-key $aws_secret_access_key \
    --aws-access-key-id $aws_access_key_id \
    --aws-region "us-east-1" \
    --newhist h$number \
    --zabbix-server 34.207.178.141 \
    --forcescp
else
 sudo docker run -d \
    -p "8000:8000" \
    -p "11625:11625" \
    -p "10050:10050" \
    --name node$number \
    factury-core-horizon \
    --network factury \
    --core-config factury$number.cfg \
    --seed $seed \
    --database-host $db_host \
    --database-pass $db_pass \
    --aws-secret-access-key $aws_secret_access_key \
    --aws-access-key-id $aws_access_key_id \
    --aws-region "us-east-1" \
    --newhist h$number \
    --zabbix-server 34.207.178.141
fi

#
# IMPROVE SECURITY
#

# set root password
echo "set root password"
sudo passwd root
# remove ubuntu user from sudo group
sudo gpasswd -d ubuntu sudo
