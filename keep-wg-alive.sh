#!/bin/sh

check_alive() {
	local ifname=$1
	local server_ip=$2
	ip link show $ifname > /dev/null 2>&1
	if [ $? != 0 ]; then
		# this wg interface is not up
		return 0
	fi
	ping -n -c 1 $server_ip > /dev/null 2>&1
	return $?
}

check_alive_wg_conf() {
	local path=$1
	local ifname=$(basename -s .conf $path)
	local address_line=$(grep -E "Address\s?=" $path)
	if [ $? != 0 ];then
		# the file should be skipped
		return 2
	fi
	local server_ip=$(echo $address_line | grep -E "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])" -o)
	if [ $? != 0 ];then
		local server_ip=$(echo $address_line | grep -E "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))" -o)
	fi
	check_alive $ifname $server_ip
	return $?
}

keep_alive_wg_conf() {
	local wg_conf_path=$1
	local ifname=$(basename -s .conf $wg_conf_path)
	check_alive_wg_conf $wg_conf_path
	if [ $? -gt 1 ];then
		return $?
	fi
	if [ $? == 1 ];then
		echo "restart $ifname"
		wg-quick down $ifname > /dev/null 2>&1
		wg-quick up $ifname > /dev/null 2>&1
	fi
	return 0
}

wg_conf_dir=${1:-/etc/wireguard}
for conf in $(ls $wg_conf_dir);do
	keep_alive_wg_conf $wg_conf_dir/$conf
done

