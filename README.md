# exfat-synology

## Description
Upstream exFAT driver compiled from [namjaejeon/linux-exfat-oot](https://github.com/namjaejeon/linux-exfat-oot) for amd64 Synology NASes such as DS918+. Tested on my DS918+.

## Requirements
- 64-bit Synology NAS with an Intel/AMD processor running Linux 4.4 kernel
- Access to a bash terminal on the NAS(e.g. via SSH)

## Installation
1. Clone/Download this git repository onto your NAS
2. From the folder containing this git repository's files, run `sudo ./install.sh` in a terminal(e.g. SSH into your NAS)
3. Profit. Try connecting an exFAT drive to your Synology NAS

## Uninstallation
1. From the folder containing this git repository's files, run `sudo ./uninstall.sh` in a terminal(e.g. SSH into your NAS)

## How to compile exFAT driver from source for other devices
(to do)

