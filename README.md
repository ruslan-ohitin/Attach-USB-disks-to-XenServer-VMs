# Attach-USB-disks-to-XenServer-VMs
Script to attach USB disks to XenServer VM Guests

This script will map USB devices to VMs

Written by Artur Neumann with the concepts, ideas & code taken from Ez-Aton, http://run.tournament.org.il
and http://jamesscanlonitkb.wordpress.com/2012/03/11/xenserver-mount-usb-from-host/
and http://support.citrix.com/article/CTX118198

## Variables
### REMOVABLE_SR_UUID

```` REMOVABLE_SR_UUID=e0f6f5bd-ffc3-0e32-0920-267dfaa2dbf6 ````

the UUID of your Removable storage SR
to get this id run: ````xe sr-list name-label="Removable storage"````
or open the "Removable storage node" of your Xen Server in XenCenter

### VMS

    VMS="a67efae7-9f36-8f10-b97d-42db26eceb4a:44B177D6601C:1 
         a67efae7-9f36-8f10-b97d-42db26eceb4a:8D35DAGF:2
         fced1b73-d8db-a900-1f1c-a7f6e077327b:AA011222140422474326:sdb"

List of VMs,USB IDs & device names inside the VM

multiple VMs are separated by space or space+new line

*Format:* "VM_ID:USB_ID:Device_Name"

To get the *VM_ID* run ```` xe vm-list ````

To get the *USB_ID* run ```` lsusb -v ```` and watch out for "iSerial"

      Bus 006 Device 004: ID 0781:5580 SanDisk Corp.
      ...
       iSerial                 3 AA011222140422474326
       
or plug in the device into a Windows Computer, start the Device Manager
under "Universal Serial Bus controllers" find the correct "USB Mass Storage Device"
open its Properties and select the "Details" tab. Here you have to select the "Device Instance Path" Property
you will see a Value like: "USB\VID_8403&PID_1000\AA011222140422474326"
the USB_ID is the bit after the last "\" in this case "AA011222140422474326"

*Device Names* are numbers in case of Windows VMs (1=Disk 1,2=Disk 2, etc) or the UNIX like device names in case of a UNIX VM (hdb, hdc, sdb, sdc, etc)

### XE

```` XE=/opt/xensource/bin/xe ```` 

Full path to the "xe" tool
