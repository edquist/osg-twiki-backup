#!/usr/bin/env bash

# Author: Marco Mambelli - marco@hep.uchicago.edu
# This is derived from the script for ATLAS Tier 3 by Doug Benjamin

#
#  This command file uses the fileip-tables-nfsv4.template to create new entries in /etc/sysconfig/iptables 
#

#------------------------------------------------------------------------------
#  call format: configure-start-nfsv4.sh [-V debug_mode] [-S server_short_name]
#
#  Note : -S switch is needed for Client setup
#
# examples:  NFS Server setup
# ---------
#
#  ./configure-start-nfsv4.sh  
#
#  ./configure-start-nfsv4.sh -V 1 
#
# Note debug mode goes first if you use it

#
# examples:  NFS Client setup
# ---------
#
#  ./configure-start-nfsv4.sh -S myNFSserver
#
#  ./configure-start-nfsv4.sh -V 1 -S myNFSserver
#
# Note debug mode goes first if you use it

#
# global variables
#

FNAME="osgtier3-configure-nfsv4.sh"

config_file_location=http://dukpc23.fnal.gov/~benjamin/atlas/tier3/kickstart/  # where the config files can be found

IFCONFIG=/sbin/ifconfig
AWK=/bin/awk
IPCALC=/bin/ipcalc
GREP=/bin/grep


# Network interface used for NFS
EXTIF="eth0"

function usage {
    cat << --EOF-- 
Usage: ${FNAME} [-v log_file] [-n network_domain] [-s server_short_name]
Options:
 -v logfile     - add the full path of a log file to collect debug output
 -n net/mask    - network where the shared file system can be mounted (network/netmask)
 -s server_name - short name is preferred, FQDN or IP address can be used as well. This option triggers a client configuration
 -d data_dir    - directory on the server where data resides (linked to the exported pseudo file system)
 -h             - print this 
--EOF--
}


#function usage {
#    echo "[configure-start-nfsv4]:  Error !!! "
#    echo "[configure-start-nfsv4]: call format: configure-nfsv4.sh [-V debug_mode] -N network_domain [-S server_short_name]"
#    echo "[configure-start-nfsv4]:  Exiting early "
#    exit 1
#}

#  check for configure-iptables-nfsv4.sh iptables configuration script
function check_for_iptables_configuration_script {
for template_file in configure-iptables-nfsv4.sh
do
  if [ ! -e $template_file ]
  then
      echo "[$FNAME]: WARNING - Could not find iptables confguration file - $template_file  fetching from web"
      wget -nv ${config_file_location}$template_file     
      return_code=$?
      if (( ! return_code==0 ))
      then
	  echo "[$FNAME]: ERROR - Failed in fetching  iptables configuration file - $template_file  from web - Exiting Early"
	  exit 1
      fi
      chmod +x $template_file
  fi
done
}

# fetch what the users passed into the routine if not enough issue error and exit

network_domain=NONE
nis_domain=NONE
DEBUG_SCRIPT=none
server_name=none
DATA_DIR=none

#
# Determine the external IP /Netmask automatically:
# ----------------------------------------
#
#  The following line will determine your external IP address.  This
#  line is somewhat complex and confusing but it will also work for
#  all NON-English Linux distributions:
#
EXTIP="`$IFCONFIG $EXTIF | $AWK  /$EXTIF/'{next}//{split($0,a,":");split(a[2],a," ");print a[1];exit}'`"
EXTNETMASK="`$IFCONFIG $EXTIF | $AWK  /$EXTIF/'{next}//{split($0,a,":");split(a[4],a," ");print a[1];exit}'`"
EXTPREFIX=`$IPCALC -p $EXTIP $EXTNETMASK | $AWK --field-separator "=" '{print $2;exit}'`
network_domain=$EXTIP"/"$EXTNETMASK
sed_network=$EXTIP"\/"$EXTNETMASK
echo "[$FNAME] INFO - IP address and network mask determined automatically - " $network_domain

#network_domain=192.168.192.0  # `ifconfig eth0 | grep "inet addr" | sed 's|:| |g' | awk '{print $3" "$7}' | xargs ipcalc -n | cut -b 9-`

#check_for_iptables_configuration_script  # check to see if we have required iptables configuration script files fetch from web.

#export OPTIND=1
while getopts 'V:S:v:s:d:h' OPT 
do
    case $OPT in
        S|s)                                        # NFS server_name (for client configuration)
            export server_name=${OPTARG}
            if [ $DEBUG_SCRIPT != "none" ] ; then
              echo "[${FNAME}]:server_name=${OPTARG}"
            fi
            ;;
        V|v)                                        # debug script,
                                                    # should go first
            export  DEBUG_SCRIPT=$OPTARG
            ;;
	d|D)					# data directory
	    export DATA_DIR=$OPTARG
	    ;;
 	n|N)					# data directory
	    export network_domain=$OPTARG
	    ;;
	h)
	    usage
            exit 0
	    ;;
       *)
           echo [${FNAME}]: OTHER: $OPT $OPTARG
           echo "[${FNAME}]: ERROR - Wrong parameter! Quitting with no action."
           usage
           exit 1
           ;;
     esac
done

# check for inputs

if [ $network_domain == "NONE" ] ; then 
  echo "[${FNAME}]: ERROR - Unable to determin network domain (subnet and mask). Quitting with no action."
  usage
  exit 1
fi

#  Now make sure that the iptables are properly configured and running

#./configure-iptables-nfsv4.sh


# Create directories needed on both Server and Client machines

#if [ ! -e /nfs ] ; then mkdir -pv /local/home; fi
#if [ ! -e /nfs/home ] ; then mkdir -pv /nfs/home; fi
mkdir -pv /nfs/certificates
mkdir -pv /nfs/condor
mkdir -pv /nfs/home
mkdir -pv /nfs/osg
mv /home /home.old
ln -s /nfs/home /home

if [ $server_name == "none" ] ; 
then 
    #  We are on the NFS server machine 
    # Create the directories that will contain the mount points

    if [ $DATA_DIR == "none" ] ; then
      echo "[$FNAME] WARNING - no DATA_DIR has been specified. Make sure that it exists and it is correctly linked to the exported pseudo file system"
    else  
      mkdir -pv $DATA_DIR
      mkdir -pv $DATA_DIR/osg
      mkdir -pv $DATA_DIR/home
      mkdir -pv $DATA_DIR/condor
      mkdir -pv $DATA_DIR/certificates

      # Create a modified /etc/fstab file
      if [ -e fstab.new ] ; then rm fstab.new; fi
      if [ -e /etc/fstab ] ; then cp -fv /etc/fstab fstab.new ; else touch fstab.new; fi
      cat << --EOF-- >> fstab.new
# OSG Tier 3 exported directories
$DATA_DIR/osg               /exports/osg            none    bind            0 0
$DATA_DIR/home              /exports/home           none    bind            0 0
$DATA_DIR/condor            /exports/condor         none    bind            0 0
$DATA_DIR/certificates      /exports/certificates   none    bind            0 0
# OSG Tier 3 exported directories - end
--EOF--

      # put new file in place and save old one if it exists
      if [ -e /etc/fstab ] ; then cp -v /etc/fstab /etc/fstab.save; fi
      cp -vf fstab.new /etc/fstab

      #mount all of the bind mount files
      mount -va -t none

    fi

    # Create new /etc/exports file
    # Possible options:
# insecure - allows ports > 1024 (IPPORT_RESERVED)
# rw - ro is default
# async - avoid (min performance increase not worth data loss) - recheck for NFS server on VMs?
# nohide - do not hide mounted directories
# no_subtree_check - do not check that file belongs to proper tree (only fs)
# refer - possible to refer some other server
# mp mountpoint - mountpoint secified of from file

    cat << --EOF-- > exports.new
# OSG exports
/exports    ${network_domain}(fsid=0,no_subtree_check,sync,ro) 
/exports/osg    ${network_domain}(sync,no_root_squash,rw,mp,nohide,no_subtree_check)
/exports/home   ${network_domain}(sync,no_root_squash,rw,mp,nohide,no_subtree_check)
/exports/condor ${network_domain}(sync,no_root_squash,rw,mp,nohide,no_subtree_check)
/exports/certificates   ${network_domain}(sync,no_root_squash,rw,mp,nohide,no_subtree_check)
# OSG exports - end
--EOF--
#/exports    ${network_domain}(fsid=0,no_subtree_check,async,ro) 
#/exports/osg    ${network_domain}(async,no_root_squash,rw,mp,nohide,no_subtree_check)
#/exports/home   ${network_domain}(async,no_root_squash,rw,mp,nohide,no_subtree_check)
#/exports/condor ${network_domain}(async,no_root_squash,rw,mp,nohide,no_subtree_check)
#/exports/certificates   ${network_domain}(async,no_root_squash,rw,mp,nohide,no_subtree_check)

    # put new file in place and save old one if it exists
    if [ -e /etc/exports ] ; then cp -v /etc/exports /etc/exports.save ; fi 
    cp -vf exports.new /etc/exports
  
    # restart nfs
    # restart other services

   /sbin/service rpcidmapd restart
   /sbin/service portmap restart
   /sbin/service nfs restart

else
# we are on a client machine
   # Create a modified /etc/fstab file

    if [ -e fstab.new ] ; then rm fstab.new; fi
    if [ -e /etc/fstab ] ; then cp -fv /etc/fstab fstab.new ; else touch fstab.new; fi

    # Possible option for NFS mount
    # bg,intr,noatime
    # rw
    # nodev,nosuid - no special device or setuid bits, allows user mounts, safer 
    # used for atlas dir: rw,nodev,sync,_netdev,nosuid 
    cat << --EOF-- >> fstab.new
# OSG Tier 3 shared directories
${server_name}:/osg            /nfs/osg        nfs4     bg,intr,noatime,nodev,nosuid 
${server_name}:/home           /nfs/home       nfs4     bg,intr,noatime,nodev,nosuid 
${server_name}:/condor         /nfs/condor     nfs4     bg,intr,noatime,nodev,nosuid 
${server_name}:/certificates   /nfs/certificates nfs4   ro,bg,intr,noatime,nodev,nosuid 
# OSG Tier 3 shared directories - end
--EOF--

#${server_name}:/home /export/home nfs4 rw,nodev,nosuid 0 0" >> fstab.new 
#    echo "${server_name}:/share/osg /export/share/osg nfs4 rw,nodev,nosuid 0 0" >> fstab.new 
#    echo "${server_name}:/share/atlas /export/share/atlas nfs4 rw,nodev,sync,_netdev,nosuid 0 0" >> fstab.new 
#    echo "${server_name}:/share/condor-etc /export/share/condor-etc nfs4 rw,nodev,nosuid 0 0" >> fstab.new 

    # put new file in place and save old one if it exists
    if [ -e /etc/fstab ] ; then cp -v /etc/fstab /etc/fstab.save; fi
    cp -vf fstab.new /etc/fstab

    # restart nfs
    #
    #  restart services

   /sbin/service rpcidmapd restart
   /sbin/service portmap restart
   /sbin/service nfs restart

    mount -va -t nfs4


fi
/sbin/chkconfig nfs on

