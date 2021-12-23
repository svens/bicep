_make_password()
{
    echo ${RANDOM}x${RANDOM}+${RANDOM} | base64
}

_validate()
{
    az deployment sub validate \
        --template-file template/main.bicep \
        --location northeurope \
        --parameters \
            username=$USER \
            password=$(_make_password) \
            login_ip=$(curl --silent ifconfig.me)
}

_deploy()
{
    az deployment sub create \
        --template-file template/main.bicep \
        --location northeurope \
        $1 \
        --parameters \
            username=$USER \
            password=$(_make_password) \
            login_ip=$(curl --silent ifconfig.me)
}

_vm_list()
{
    az vm list --resource-group ${USER}-udp --query "[].id" -o tsv
}

_ssh_config()
{
    az vm list-ip-addresses --output yamlc \
        --ids $(_vm_list) \
        --query "[].{Host:virtualMachine.name, HostName:virtualMachine.network.publicIpAddresses[0].ipAddress}" \
        | sed 's/^- //; s/://'
}

_passwd()
{
    printf "Password: "
    read -s password
    az vm user update \
        --username $USER \
        --password $password \
        --ids $(_vm_list)
}

_start()
{
    az vm start --ids $(_vm_list)
}

_stop()
{
    az vm stop --ids $(_vm_list)
}

_deallocate()
{
    az vm deallocate --ids $(_vm_list)
}
