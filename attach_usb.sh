#!/bin/bash
# This script will map USB devices to VMs
# Written by Artur Neumann with the concepts, ideas & code
# taken from Ez-Aton, http://run.tournament.org.il 
# and http://jamesscanlonitkb.wordpress.com/2012/03/11/xenserver-mount-usb-from-host/
# and http://support.citrix.com/article/CTX118198

# Variables
# Need to change them to match your own!
# for details about the configuration check the Readme on GitHub: 
# https://github.com/International-Nepal-Fellowship/Attach-USB-disks-to-XenServer-VMs

#the UUID of your Removable storage SR
REMOVABLE_SR_UUID=e0f6f5bd-ffc3-0e32-0920-267dfaa2dbf6

#List of VMs,USB IDs & device names inside the VM
#Format: "VM_ID:USB_ID:Device_Name"
VMS="a67efae7-9f36-8f10-b97d-42db26eceb4a:44B177D6601C:1 
     a67efae7-9f36-8f10-b97d-42db26eceb4a:8D35DAGF:2 
     fced1b73-d8db-a900-1f1c-a7f6e077327b:AA011222140422474326:sdb"

#Full path to the "xe" tool
XE=/opt/xensource/bin/xe

function attach() {
        # Here we attach the disks
        for VM in $VMS
        do
                #get VM ID, USB ID & device name
                VM_UUID=`echo $VM|cut -d":" -f1`
                USB_ID=`echo $VM|cut -d":" -f2`
                DEVICE_NAME=`echo $VM|cut -d":" -f3`
 
                #get linux device name (sdb, sdc, sdd, etc) of this USB device
                LINUX_DEVICE_NAME=`ls /dev/disk/by-id/usb*$USB_ID-0:0 -l | awk -F"/" '{ print  $NF }'`

                #get the VDI uuid of this Linux device  
                VDI=`$XE vdi-list sr-uuid=${REMOVABLE_SR_UUID} location=/dev/xapi/block/$LINUX_DEVICE_NAME --minimal`
                #check if storage is attached to VDB
                VBD=`$XE vdi-list uuid=$VDI params=vbd-uuids --minimal`
                if [ `echo $VBD | wc -w` -ne 0 ]
                then 
                        echo "Disk is allready attached. Check VBD $VBD for details"
                else
                        echo "attaching disk"
                        VBD=`$XE vbd-create vm-uuid=${VM_UUID} device=${DEVICE_NAME} vdi-uuid=${VDI}`
                        if [ $? -ne 0 ]
                        then
                                echo "Failed to connect $VDI to ${DEVICE_NAME}"
                                exit 2
                        fi
                        $XE vbd-plug uuid=$VBD
                        if [ $? -ne 0 ]
                        then
                                echo "Failed to plug $VBD"
                                exit 3
                        fi
                fi
        done
exit

}

function detach() {
        # Here we detach the disks
        for VM in $VMS
        do
                #get VM ID, USB ID & device name
                VM_UUID=`echo $VM|cut -d":" -f1`
                USB_ID=`echo $VM|cut -d":" -f2`
                DEVICE_NAME=`echo $VM|cut -d":" -f3`

                #get linux device name (sdb, sdc, sdd, etc) of this USB device
                LINUX_DEVICE_NAME=`ls /dev/disk/by-id/usb*$USB_ID -l | awk -F"/" '{ print  $NF }'`

                #get the VDI uuid of this Linux device
                VDI=`$XE vdi-list sr-uuid=${REMOVABLE_SR_UUID} location=/dev/xapi/block/$LINUX_DEVICE_NAME --minimal`
                
                VBD=`$XE vdi-list uuid=$VDI params=vbd-uuids --minimal`
                $XE vbd-unplug uuid=${VBD}
                $XE vbd-destroy uuid=${VBD}
                echo "Storage Detached from VM"
        done



}
case "$1" in
        attach) attach
                ;;
        detach) detach
                ;;
        *)      echo "Usage: $0 [attach|detach]"
                exit 1
esac
