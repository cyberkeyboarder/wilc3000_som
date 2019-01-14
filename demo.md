# ****`Simple WiFi and BlueTooth Demo`****

[comment]: <> (Badges --> https://shields.io/#/)
[comment]: <> (Markdown --> https://github.com/DavidAnson/markdownlint)
[comment]: <> (Table generator: https://www.tablesgenerator.com/markdown_tables#)
[comment]: <> (Markdown --> https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#emphasis)

***

## **DEMO # 1:**  **`[WIFI]`** - *STATION MODE (connect to AP)*

***

* Target (_`SOM Board`_) should be running and connected via "minicom"

[comment]: <> (supplicant is used for authentication, credential submission, etc)

* Network security is configured to use WPA2

### Establish connection UART

```shell
# sudo minicom -wD /dev/ttyACM0
```

### Disable Debug Messages

```bash
// ATWILC driver inherits debug logs (levels) from Linux.
// dmeg - print or control the kernel ring buffer
// "7" is the highest desired log level
// Stop debug messages from streaming on terminal.

// View current status
# cat /proc/sys/kernel/printk
// 7       4       1       7
// ^       ^       ^       ^
// |       |       |       |
// current default minimum boot-time-default

// Set console logging level to lowest level
# dmesg -n 1
```

### Check if the WILC3000-SD card drivers are working

```bash
ifconfig wlan0

wlan0  Link encap:Ethernet  HWaddr 00:00:00:00:00:00
        BROADCAST MULTICAST  MTU:1500  Metric:1
        RX packets:0 errors:0 dropped:0 overruns:0 frame:0
        TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:1000
        RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

> "vi" editor Quick Reference

| COMMAND  |   | DESCRIPTION                 |
|----------|---|-----------------------------|
| i:       |   | Insert Mode                 |
| ESC      |   | Command                     |
| :q!      |   | Quit without saving         |
| :w       |   | Save changes (write buffer) |
| :wq      |   | Save changes and quit vi    |
| ZZ       |   | Save changes and quit vi    |

### Modify `/etc/wpa_supplicant.conf` from the default

```bash
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

network={
  key_mgmt=NONE
}
```

* ... to match your network settings:

```bash
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

network={
    ssid="Guest"
    psk="password"
}
```

* Run supplicant WPA2

```bash
# wpa_supplicant -Dnl80211 -iwlan0 -c /etc/wpa_supplicant.conf &
```

* Negotiate a lease w/ the DHCHP Server w/ the (BusyBox) DHCP Client

```bash
# udhcpc -i wlan0 &
```

* Quick confidence test by pinging the Google DNS Server

```bash
# ping 8.8.8.8

PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=1 ttl=252 time=16.944 ms
64 bytes from 8.8.8.8: seq=2 ttl=252 time=18.039 ms
64 bytes from 8.8.8.8: seq=3 ttl=252 time=16.571 ms
64 bytes from 8.8.8.8: seq=4 ttl=252 time=16.667 ms
```

> Test # 1 concluded ...

## **DEMO # 2:**  **`[WIFI]`** - *AP MODE (Soft AP)*

Silence the Debug messaging

```bash
# dmesg -n 1
```

### Access Point Open Security

* Check kernel module ..

```bash
# lsmod
  Module                  Size  Used by    Not tainted
  atmel_usba_udc         20480  0
```

```bash
# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

Host Access Point Daemon. Turn normal network interface ard into an Access Point (AP). 

```bash
# cat /etc/wilc_hostapd_open.conf
  interface=wlan0  
  driver=nl80211  
  ctrl_interface=/var/run/hostapd  
  ssid=wilc_SoftAP  
  dtim_period=2  
  beacon_int=100  
  channel=7  
  hw_mode=g  
  max_num_sta=8  
```

* Note: **ssid=** `wilc_SoftAP`

### Start hostap daemon

* Host Access Point - enable network card to act as an access point ...

```bash
# hostapd /etc/wilc_hostapd_open.conf -B &
```

```bash
# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr FA:F0:05:C0:2B:FE  
          inet6 addr: fe80::f8f0:5ff:fec0:2bfe/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:586 (586.0 B)
```

* Note: **link is now** `UP`

### Assign IP address

```bash
# ifconfig wlan0 192.168.0.1
```

```bash
wlan0     Link encap:Ethernet  HWaddr FA:F0:05:C0:2B:FE  
          inet addr:192.168.0.1  Bcast: 192.168.0.255 Mask:255.255.255.0  
          inet6 addr: fe80::f8f0:5ff:fec0:2bfe/64 Scope:Link  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1  
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0  
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0  
          collisions:0 txqueuelen:1000  
          RX bytes:0 (0.0 B)  TX bytes:936 (936.0 B)
```

* Note: **Link is `UP` and IP `192.168.0.1` address was assigned**

### Start DHCP Server

```bash
# /etc/init.d/S80dhcp-server start
```

* Look on phone for `wilc_SoftAP` & Connect
* Check phone settings for assigned IP address (ex. 192.168.0.100)
* phone: Router: 192.168.0.1

### From host, ping mobile phone

 ```bash
# ping 192.168.0.1  
PING 192.168.0.1 (192.168.0.1): 56 data bytes  
64 bytes from 192.168.0.1: seq=0 ttl=64 time=0.948 ms  
64 bytes from 192.168.0.1: seq=1 ttl=64 time=0.444 ms  
64 bytes from 192.168.0.1: seq=2 ttl=64 time=0.435 ms  
64 bytes from 192.168.0.1: seq=3 ttl=64 time=0.446 ms  
64 bytes from 192.168.0.1: seq=4 ttl=64 time=0.458 ms  
```

### Check DHCP Server is running

```bash
# ps aux | grep dhcpd  
  210 root     /usr/sbin/dhcpd -q
  216 root     grep dhcpd
```

> Usage: /etc/init.d/S80dhcp-server {start|stop|restart|force-reload}

### Stop DHCP Server

```bash
# /etc/init.d/S80dhcp-server stop
```

### Re-Check DHCP Server (not running)

```bash
# ps aux | grep dhcpd  
  220 root     grep dhcpd
```

> Test # 2 concluded ...

***

## **DEMO # 3:**  **`[BLUETOOTH]`** - *Generic*

***

> USART INFO

| SOM J30 (mikroBUS-2)   |   | PIN |  SIP Datasheet    |
|------------------------|---|-----|-------------------|
| RX PD23  UART Receive  |   | 3   | PD23 (RX_mBUS2)   |
| TX PD24  UART Transmit |   | 4   | PD24 (TX_mBUS2)   |

[comment]: <> (FYI (not needed but...)
[comment]: <> (Get device tree in text from device tree blob:)
[comment]: <> ($ dtc -I dtb -O dts <devicetree.dtb>)

### Initiaize/Run BLE

```bash
# echo BT_POWER_UP > /dev/wilc_bt
# echo BT_DOWNLOAD_FW > /dev/wilc_bt
# echo BT_FW_CHIP_WAKEUP > /dev/wilc_bt
# echo BT_FW_CHIP_ALLOW_SLEEP > /dev/wilc_bt
# hciattach ttyS2 any 115200 noflow
# hciconfig -a
# hciconfig hci0 up
```

### Make a symbolic link for "bluetoothd"

> bluetoothd resides in: `/usr/libexec/bluetooth/bluetoothd`

```bash
# echo $PATH
/bin:/sbin:/usr/bin:/usr/sbin

# ln -svf /usr/libexec/bluetooth/bluetoothd /usr/sbin

// -s: make symbolic link instead of hardlink
// -v: verbose (print name of each linked file)
// -f: remove existing destination files.

// Sanity check the link, method-I:
# cd /usr/bin
# ls -al | grep ^l
---> # lrwxrwxrwx 1 root root 33 Jan  1 07:28 bluetoothd -> /usr/libexec/bluetooth/bluetoothd

// sanity-check menthod-II
# cd /
# find . -name bluetoothd
./usr/sbin/bluetoothd
./usr/libexec/bluetooth/bluetoothd

# which bluetoothd
/usr/sbin/bluetoothd
```

> ### *Regular Expression:*  **`^`** match expression at the start of the line

### Start the Bluetooth daemon (manages all the BT devices)

```text
bluetoogthd --help
Usage:
  bluetoothd [OPTION?]

Help Options:
  -h, --help                  Show help options

Application Options:
  -d, --debug=DEBUG           Specify debug options to enable
  -p, --plugin=NAME,..,       Specify plugins to load
  -P, --noplugin=NAME,...     Specify plugins not to load
  -f, --configfile=FILE       Specify an explicit path to the config file
  -C, --compat                Provide deprecated command line interfaces
  -E, --experimental          Enable experimental interfaces
  -n, --nodetach              Run with logging in foreground
  -v, --version               Show version information and exit
```

```bash
# bluetoothd -n &
```

[comment]: <> (todo: # bluetoothd -p time -n &)

### Execute: Bluetooth control tool, `bluetoothctl` commands

```bash
# bluetoothctl

[bluetooth]# list
Controller F8:F0:05:C0:F9:6F BlueZ 5.48 [default]

[bluetooth]# version
Version 5.48

[bluetooth]# help

[bluetooth]# scan on
Discovery started
[CHG] Controller F8:F0:05:C0:2B:FF Discovering: yes
[NEW] Device 4A:73:27:B1:35:6D 4A-73-27-B1-35-6D
[NEW] Device A0:99:9B:19:92:7E A0-99-9B-19-92-7E
[NEW] Device 70:91:B0:62:7B:97 70-91-B0-62-7B-97
[NEW] Device 7E:23:13:28:5A:96 7E-23-13-28-5A-96
[NEW] Device 9C:20:7B:F0:32:9F 9C-20-7B-F0-32-9F
[NEW] Device 6D:35:C2:45:4F:D9 6D-35-C2-45-4F-D9

[bluetooth]# scan off
[CHG] Device 40:AD:2E:40:5D:67 RSSI is nil
[CHG] Device 44:67:55:50:30:C9 RSSI is nil
[CHG] Device 6D:35:C2:45:4F:D9 RSSI is nil
[CHG] Device 9C:20:7B:F0:32:9F RSSI is nil
[CHG] Device 7E:23:13:28:5A:96 RSSI is nil
[CHG] Device 70:91:B0:62:7B:97 RSSI is nil
[CHG] Device A0:99:9B:19:92:7E RSSI is nil
[CHG] Device 4A:73:27:B1:35:6D RSSI is nil
[CHG] Controller F8:F0:05:C0:2B:FF Discovering: no
Discovery stopped

[bluetooth]# info 70:CA:DB:53:ED:59
Device 70:CA:DB:53:ED:59 (random)
Alias: 70-CA-DB-53-ED-59
Paired: no
Trusted: no
Blocked: no
Connected: no
LegacyPairing: no
ManufacturerData Key: 0x004c
ManufacturerData Value:
10 05 01 18 5f 1a 4b

// [bluetooth]# connect 00:02:3C:3A:95:6F

[bluetooth]# exit
```

## **Documents**

![Microchip](imgs/github.png) [Microchip ATLinux4Wilc Wireless Drivers](https://github.com/linux4wilc)

![Microchip](imgs/logo_microchip.png)[ATWILC3000 Product Page](https://www.microchip.com/wwwproducts/en/ATWILC3000)

![Users Guide](imgs/logo_microchip.png)[ATWILC3000 Wi-Fi Linux User's Guide](http://ww1.microchip.com/downloads/en/DeviceDoc/ATWILC1000-ATWILC3000-Wi-Fi-Link-Controller-Linux-User-Guide-DS70005328B.pdf)

#### **Attribution**

![David Anson](imgs/github.png) `Markdownlint` ([MIT][license-url]) : [David Anson](https://github.com/DavidAnson/markdownlint)

***

## **`Todo`**

* Demo acutal/working Bluetooth connection(s)

***

>  
> ## **END**  
>  

## HISTORY

* 0.0.1 - Initial release.
* 0.0.2 - Improve documentation, tests, and code.

## LICENSE AGREEMENT

[npm-image]: https://img.shields.io/npm/v/markdownlint.svg
[npm-url]: https://www.npmjs.com/package/markdownlint
[travis-image]: https://img.shields.io/travis/DavidAnson/markdownlint/master.svg
[travis-url]: https://travis-ci.org/DavidAnson/markdownlint
[coveralls-image]: https://img.shields.io/coveralls/DavidAnson/markdownlint/master.svg
[coveralls-url]: https://coveralls.io/r/DavidAnson/markdownlint
[license-image]: https://img.shields.io/npm/l/markdownlint.svg
[license-url]: https://opensource.org/licenses/MIT
[mchp-image]: https://img.shields.io/badge/license-microchip-brightgreen.svg
[mchp-url]: #100

[comment]: <> (https://www.microchip.com/mplab/microchip-libraries-for-applications/mla-license)

[comment]: <> (from Leo Zhang's README.md)
[1]: https://buildroot.org/downloads/manual/manual.html#outside-br-custom
[2]: https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
[3]: https://buildroot.org/docs.html
[4]: http://www.at91.com/linux4sam/bin/view/Linux4SAM/SDCardBootNotice
[5]: https://etcher.io/
[6]: https://github.com/linux4wilc

<a id="md100"></a>

## **`Microchip Non-Exclusive Software License Agreement`**

*MICROCHIP IS WILLING TO LICENSE THE ACCOMPANYING SOFTWARE AND DOCUMENTATION TO YOU ONLY ON THE CONDITION THAT YOU ACCEPT ALL OF THE FOLLOWING TERMS.*

*TO ACCEPT THE TERMS OF THIS LICENSE, PROCEED WITH THE DOWNLOAD OR INSTALL.*

***IF YOU DO NOT ACCEPT THESE LICENSE TERMS, DO NOT DOWNLOAD OR INSTALL THIS SOFTWARE.***

MICROCHIP IS WILLING TO LICENSE THE ACCOMPANYING SOFTWARE AND DOCUMENTATION TO YOU ONLY ON THE CONDITION THAT YOU ACCEPT ALL OF THE FOLLOWING TERMS.  TO ACCEPT THE TERMS OF THIS LICENSE, CLICK "I ACCEPT" AND PROCEED WITH THE DOWNLOAD OR INSTALL.  IF YOU DO NOT ACCEPT THESE LICENSE TERMS, CLICK "I DO NOT ACCEPT," AND DO NOT DOWNLOAD OR INSTALL THIS SOFTWARE.

```text
 This Microchip Nonexclusive Software License Agreement ("Agreement") is a contract between you, your heirs, successors and assigns ("Licensee") and Microchip Technology Incorporated, a Delaware corporation, with a principal place of business at 2355 W. Chandler Blvd., Chandler, AZ 85224-6199, and its subsidiaries including, Microchip Technology (Barbados) II Incorporated (collectively, "Microchip") for the accompanying Microchip software, including any PC programs, and any modifications or updates thereto (collectively, the "Software"), and accompanying documentation, including images and any other graphic resources provided by Microchip ("Documentation").

1. Definitions.  As used in this Agreement, the following capitalized terms will have the meanings defined below:

a. "Microchip Products" means Microchip integrated circuit devices.

b. "Licensee Products" means Licensee products that use or incorporate Microchip Products.

c. "Third Party" means Licensee’s agents, distributors, consultants, clients, customers, contract manufacturers, resellers, or representatives.

d. "Third Party Products" means Third Party products that use or incorporate Microchip Products.

2. Software License Grant.  Microchip grants strictly to Licensee a non-exclusive, non-transferable, worldwide license:

a. To use the Software in connection with Licensee Products or Third Party Products;

b. If source code is provided by Microchip to Licensee, to modify the Software for the sole purpose of rendering the Software operable with Licensee Products or Third Party Products, provided that Licensee clearly notifies Third Parties regarding the source of such modifications; and

c. To distribute the Software to Third Parties for use with or incorporation into Licensee Products or Third Party Products, provided that Licensee ensures that: (i) such Third Party agrees to be bound by this Agreement (in writing or by "click to accept"), and (ii) this Agreement accompanies such distribution.  The procedure described in sub-clauses (i) and (ii) is not required when the Software is embedded in machine-readable object code form as firmware in Licensee Products or Third Party Products.  Further, the procedure described in sub-clauses (i) and (ii) is not required when modified versions of PC programs are re-distributed in machine-readable object code form, provided that Licensee notifies end users that: (1) the modified PC program is derived from a Microchip PC program and is governed by the terms of this Agreement including the requirement to use such program with Microchip Products, (2) a copy of this Agreement is available upon request, and (3) the Licensee supports the modified PC program.  

For purposes of clarity, Licensee may NOT embed the Software on a non-Microchip Product, except as expressly described in this Section 2 or the Documentation.  

3. Documentation License Grant.  Microchip grants to Licensee a non-exclusive, non-transferable, worldwide license to use the Documentation in support of the authorized use of the Software as set forth in this Agreement.

4. Third Party Requirements.  Licensee acknowledges that it is Licensee’s responsibility to comply with any third party license terms or requirements applicable to the use of such third party software, specifications, systems, or tools.  This includes, by way of example but not as a limitation, any standards setting organizations requirements and, particularly with respect to Security Package Software, if any, local encryption laws and requirements.  Microchip is not responsible and will not be held responsible in any manner for Licensee’s failure to comply with such applicable third party terms or requirements.

5. Open Source Components.  Notwithstanding the license grant in Section 2 above, Licensee further acknowledges that certain components of the Software may be covered by so-called "open source" software licenses ("Open Source Components").  Open Source Components means any software licenses approved as open source licenses by the Open Source Initiative or any substantially similar licenses, including without limitation any license that, as a condition of distribution of the software licensed under such license, requires that the distributor make the software available in source code format.  To the extent required by the licenses covering Open Source Components, the terms of such license will apply in lieu of the terms of this Agreement.  To the extent the terms of the licenses applicable to Open Source Components prohibit any of the restrictions in this Agreement with respect to such Open Source Components, such restrictions will not apply to such Open Source Component.

6. Licensee Obligations.  Licensee will not: (a) engage in unauthorized use, modification, disclosure or distribution of Software or Documentation, or its modifications or derivatives; (b) use all or any portion of the Software, Documentation, or its modifications or derivatives except in conjunction with Microchip Products, Licensee Products, or Third Party Products as set forth in this Agreement; or (c) reverse engineer (by disassembly, decompilation or otherwise) Software or any portion thereof.  Licensee may not remove or alter any Microchip copyright or other proprietary rights notice posted in any portion of the Software or Documentation.  Licensee will defend, indemnify and hold Microchip and its subsidiaries harmless from and against any and all claims, costs, damages, expenses (including reasonable attorney's fees), liabilities, and losses, including without limitation: (x) any claims directly or indirectly arising from or related to the use, modification, disclosure or distribution of the Software, Documentation, or any intellectual property rights related thereto; (y) the use, sale and distribution of Licensee Products or Third Party Products; and (z) breach of this Agreement.  

7. Confidentiality.  Licensee agrees that the Software (including but not limited to the source code, object code and library files) and its modifications or derivatives, Documentation and underlying inventions, algorithms, know-how and ideas relating to the Software and the Documentation are proprietary information belonging to Microchip and its licensors ("Proprietary Information").  Except as expressly and unambiguously allowed herein, Licensee will hold in confidence and not use or disclose any Proprietary Information and will similarly bind its employees and Third Party(ies) in writing.  Proprietary Information will not include information that: (i) is in or enters the public domain without breach of this Agreement and through no fault of the receiving party; (ii) the receiving party was legally in possession of prior to receiving it; (iii) the receiving party can demonstrate was developed by the receiving party independently and without use of or reference to the disclosing party's Proprietary Information; or (iv) the receiving party receives from a third party without restriction on disclosure.  If Licensee is required to disclose Proprietary Information by law, court order, or government agency, License will give Microchip prompt notice of such requirement in order to allow Microchip to object or limit such disclosure.  Licensee agrees that the provisions of this Agreement regarding unauthorized use and nondisclosure of the Software, Documentation and related Proprietary Rights are necessary to protect the legitimate business interests of Microchip and its licensors and that monetary damage alone cannot adequately compensate Microchip or its licensors if such provisions are violated.  Licensee, therefore, agrees that if Microchip alleges that Licensee or Third Party has breached or violated such provision then Microchip will have the right to injunctive relief, without the requirement for the posting of a bond, in addition to all other remedies at law or in equity.

8. Ownership of Proprietary Rights.  Microchip and its licensors retain all right, title and interest in and to the Software and Documentation including, but not limited to all patent, copyright, trade secret and other intellectual property rights in the Software, Documentation, and underlying technology and all copies and derivative works thereof (by whomever produced).  Licensee and Third Party use of Software modifications and derivatives is limited to the license rights described in this Agreement.

9. Termination of Agreement.  Without prejudice to any other rights, this Agreement terminates immediately, without notice by Microchip, upon a failure by Licensee or Third Party to comply with any provision of this Agreement.  Upon termination, Licensee and Third Party will immediately stop using the Software, Documentation, modifications and derivatives thereof, and immediately destroy all such copies.

10. Warranty Disclaimers.  THE SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.  MICROCHIP AND ITS LICENSORS ASSUME NO RESPONSIBILITY FOR THE ACCURACY, RELIABILITY OR APPLICATION OF THE SOFTWARE OR DOCUMENTATION.  MICROCHIP AND ITS LICENSORS DO NOT WARRANT THAT THE SOFTWARE WILL MEET REQUIREMENTS OF LICENSEE OR THIRD PARTY, BE UNINTERRUPTED OR ERROR-FREE.  MICROCHIP AND ITS LICENSORS HAVE NO OBLIGATION TO CORRECT ANY DEFECTS IN THE SOFTWARE.  

11. Limited Liability.  IN NO EVENT WILL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER ANY LEGAL OR EQUITABLE THEORY FOR ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED TO INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.  The aggregate and cumulative liability of Microchip and its licensors for damages hereunder will in no event exceed $1000 or the amount Licensee paid Microchip for the Software and Documentation, whichever is greater.  Licensee acknowledges that the foregoing limitations are reasonable and an essential part of this Agreement.

12. General.  THIS AGREEMENT WILL BE GOVERNED BY AND CONSTRUED UNDER THE LAWS OF THE STATE OF ARIZONA AND THE UNITED STATES WITHOUT REGARD TO CONFLICTS OF LAWS PROVISIONS.  Licensee agrees that any disputes arising out of or related to this Agreement, Software or Documentation will be brought exclusively in either the U.S. District Court for the District of Arizona, Phoenix Division, or the Superior Court of Arizona located in Maricopa County, Arizona.  This Agreement will constitute the entire agreement between the parties with respect to the subject matter hereof.  It will not be modified except by a written agreement signed by an authorized representative of Microchip.  If any provision of this Agreement will be held by a court of competent jurisdiction to be illegal, invalid or unenforceable, that provision will be limited or eliminated to the minimum extent necessary so that this Agreement will otherwise remain in full force and effect and enforceable.  No waiver of any breach of any provision of this Agreement will constitute a waiver of any prior, concurrent or subsequent breach of the same or any other provisions hereof, and no waiver will be effective unless made in writing and signed by an authorized representative of the waiving party.  Licensee agrees to comply with all import and export laws and restrictions and regulations of the Department of Commerce or other United States or foreign agency or authority. The indemnities, obligations of confidentiality, and limitations on liability described herein, and any right of action for breach of this Agreement prior to termination, will survive any termination of this Agreement. Any prohibited assignment will be null and void.  Use, duplication or disclosure by the United States Government is subject to restrictions set forth in subparagraphs (a) through (d) of the Commercial Computer-Restricted Rights clause of FAR 52.227-19 when applicable, or in subparagraph (c)(1)(ii) of the Rights in Technical Data and Computer Software clause at DFARS 252.227-7013, and in similar clauses in the NASA FAR Supplement.  Contractor/manufacturer is Microchip Technology Inc., 2355 W. Chandler Blvd., Chandler, AZ 85224-6199.

If Licensee has any questions about this Agreement, please write to Microchip Technology Inc., 2355 W. Chandler Blvd., Chandler, AZ 85224-6199 USA. ATTN: Marketing.

License Rev. No. 06-010914
```