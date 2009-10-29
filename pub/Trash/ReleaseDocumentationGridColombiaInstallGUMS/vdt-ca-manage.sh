#!/usr/bin/env perl

=head1 NAME 

vdt-ca-manage - Manage the VDT CA certificate installation

=head1 SYNOPSIS

    vdt-ca-manage [global_options] command 

    global_options =
        [--vdt-location <location>]
        [--verbose]
        [--force]
        [--cert-dir <location>]
        [--help | --usage]
        [--version]
        [--auto-refresh]

    command = [manage_command | status_command] 

    status_command = [
        showCAURL |
        listCA [--pattern <pattern>] |
        verify [--hash <CA hash> | --pattern <pattern>] |
        diffCAPackage |
        show [--certfile <cert_file> | --hash <CA hash>] |
        showChain [--certfile <cert_file> | --hash <CA hash>]
    ]

    manage_command = [
        setupCA [--location <root|local|PATH> --url <osg|vdt|URL>] |
        refreshCA |
        fetchCRL |
        setCAURL [--url <URL>] |
        add [--dir <local_dir>] --hash <CA hash> |
        remove --hash <CA hash>
    ]

=head1 DESCRIPTION

This tool provides a unified interface to manage the VDT CA Certificate installations.
It provides status commands that allows you to list the CAs and the validity of the CAs 
and CRLs included in the installation. The manage commands allow you to fetch CAs and CRLs, 
change the distribution URL, as well as add and remove CAs from your local installation.

=head1 OPTIONS

=over 4

=item B<--vdt-location> <location>

The location the VDT was installed in. This option overrides the $VDT_LOCATION environment
variable if it exists. This option is not needed if $VDT_LOCATION is set to the correct
location. 

=item B<--verbose>

Provides you with more information depending on the command context.

=item B<--force>

Forces the command to run ignoring any checks/warnings.  The actual effect is context
dependent, and this behavior is noted in the command details below.

=item B<--cert-dir> <location>

This location specifies the path CA directory. If this option is not specified then the
command will look for $X509_CERT_DIR, and $VDT_LOCATION/globus/TRUSTED_CA respectively.
If none of these directories can be found, the command will exit with an error.

=item B<--auto-refresh>

This option will indicate if it is permissible to fetch CAs and CRLs as deemed necessary
by this tool. For example at the end of an addCA/removeCA it would be advisable to refresh
the CA list and the corresponding CRLs.  The default is not to refresh.

=item B<--version>

Prints the version of the vdt-ca-certs-manager tool.

=item B<--help>

Print usage information. Show a brief explanatory text for using vdt-ca-certs-manager.

=back 

=head1 STATUS_COMMANDS

=over 4

=item B<showCAURL>

This will print out the distribution location specified in the config file. 
This command will read vdt-update-certs.conf and output cacerts_url.

=item B<listCA> [--pattern <pattern>]

This command will use openssl x509 command on the files in the --dir to provide hash,
 the subject, the issuer and whether a CA is IGTF or TeraGrid accredited and 
distribution package are used to download CAs into the directory. 
--verbose option will provide additional information including all associated dates 
(CA cert issuance date, and CRL issuance date, and expiry dates). The command will look
for CA files in the -cert-dir. The <pattern> specified in the option will be matched,
using perl regex, against the subject/issuer field of the certificate and 
all CAs are listed if no pattern is given.

=item B<verify> [--hash <CA hash> | --pattern <pattern>]

The verify command will check all CAs (or if specified only the <CA hash> or 
CAs that match the <pattern>) in the <cert-dir> directory, to see if any CA/CRL 
have expired or are about to do so. If any expired CA/CRL are found, an error 
is issued along with the hash of the CA. A warning is issued if either the 
CA cert or CRL is about the expire within the next 24 Hrs. The --verbose option 
provides the CA Name, date the CA certs and CRL files are issued, and when they 
will expire.

=item B<diffCAPackage>

It compare the hash of certificates included in the certificate directory against
the latest VDT/OSG distribution (based on your cacerts_url) and  outputs the difference.

=item B<show> [--certfile <cert_file> | --hash <CA hash>]

This command will essentially provide a condensed output of openssl x509 command. It  
takes in a certificate or proxy file or an hash as input. --verbose option will provide 
the full text output of openssl command. If --hash option is used we will look 
for the <CA hash>.0 file in the <cert-dir>.

=item B<showChain> [--certfile <cert_file> | --hash <CA hash>]

This command will output the trust chain of the certificate or proxy. <cert-dir>
will be used as the directory in which search for ancestor certs will be conducted.

=back

=head1 UPDATE_COMMANDS

=over 4

=item B<setupCA>

This command is used for the inital setup of the CA package. The CA package can be 
setup to download CAs from any URL.  Keywords are provided for the 'VDT' and 'OSG'
distributions.  For the location to specify, keywords are provided to install into
'root' (/etc/grid-security) or 'local' (VDT_LOCATION/globus/share).

=item B<refreshCA>

This command run vdt-update-certs to check for a new version of the CA distribution.
If you already have the latest version, but wish to force an update anyways, use the
--force option.

=item B<fetchCRL>

It retrieves CRLs for all CAs within the directory. 
This will involve invoking fetch-crl, with appropriate arguments. 

=item B<setCAURL> [--url <URL>]

This command sets the location from where the CA files. This command will modify 
vdt-update-certs.conf and set the cacerts_url.  Only if --auto-refresh is specified 
both CA and CRLs are refreshed once the URL change has been made. The distribution <URL> 
will be required to conform to the VDT CA distribution format (e.g. similar to 
http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version). If the <URL> 
cannot be reached or if it is invalid syntactically (i.e. does not conform to the format requirements) 
a warning will be issued and no changes will be made. The --force option can be used to force 
a change ignoring the warning (Of course --force will give a warning that update-vdt-certs 
will no longer work and make the change anyway.) If URL is left unspecified the 
<URL> will be set to OSG default. We also define keywords for OSG and VDT as 
shortcuts to indicate well-known CA URLs.
 
=item B<add> [--dir <local_dir>] --hash <CA hash>

The --hash argument is required. If --dir is not specified we will assume that the user 
wants to include a standard CA he has previously excluded (otherwise --dir is required). 
If <CA hash> is not known or it is already included tool will provide appropriate error/warning 
information. In the common case this command will add include lines for <local_dir>/<CA hash>.*, (except .r0) 
into the vdt-update-certs.conf file. Lastly the command will invoke functions refresh 
the CAs and fetch CRLs (if --auto-refresh is specified). This command will also do some preliminary 
error checks, e.g. make sure that “.0”, “.crl_url” files exist and that --dir is different 
than --cert-dir. 
 
=item B<remove> --hash <CA hash>

This command will be complementary to add and would either add an exclude or remove an 
include depending on the scenario. This command will also refresh CA and CRLs (when specified). 
vdt-update-certs do the job of actually removing cert files, we will still do the preliminary 
error checks to make sure that the certs that are being removed are included in the first place. 

=back

=cut

use strict;
use warnings;
use Getopt::Long;
use Time::Local;
use File::Basename;
use File::Temp qw/ tempdir /;

use VDTConfigure;
use VDTCerts;

#Constants
my $version='vdt-ca-certs-manager-1.0-Beta';
my $warn = 24*60*60; # Warning threshhold about expiring CA and CRLs
my $vdt_ca_url = "http://vdt.cs.wisc.edu/software/certificates/vdt-igtf-ca-certs-version";
my $osg_ca_url = "http://software.grid.iu.edu/pacman/cadist/ca-certs-version";

#Global Variables
my $vdt_location;
my $verbose = 0;
my $force = 0;
my $cert_dir;
my $dir;
my $url;
my $install_location;
my $auto_refresh = 0;
my $certs_file;
my $update_certs_conf;
my $config;
my $openssl;
my %source;

main();

exit 0;


#---------------------------------------------------------------------
#
# Main subroutine 
#
#---------------------------------------------------------------------

sub main {
    my $pattern;
    my $hash;
    my $is_setup=0;

    if (defined $ENV{VDT_LOCATION}) {
        $vdt_location = $ENV{VDT_LOCATION};
    }

    # Read in command line options
    GetOptions("vdt-install=s" => \$vdt_location,
               "verbose"       => \$verbose,
               "force"         => \$force,
               "cert-dir=s"    => \$cert_dir,
               "auto-refresh"  => \$auto_refresh,
               "pattern=s"     => \$pattern,
               "hash=s"        => \$hash,
               "url=s"         => \$url,
               "location=s"    => \$install_location,
               "dir=s"         => \$dir,
               "certfile=s"    => \$certs_file,
               "version"       => \&version,
               "help|usage"    => \&usage);

    # Ensure vdt_location is defined
    if (!$vdt_location || !-d $vdt_location) {
        print "Please source setup.sh or pass this script a valid VDT_LOCATION using --vdt-install option.\n";
        exit 1;
    }

    VDTCerts::initialize($vdt_location, "CA-Certificates-Manager");

    # Read in the command 
    if ($#ARGV != 0) {
        print "Please specify exactly one command to vdt-ca-manage.\n";
        usage();
    }
    my $command = lc($ARGV[0]);

    # Determine the certificate directory
    if ( (!$cert_dir || !-d $cert_dir) && $command ne "setupca") {
        my $supplied_cert_dir = $cert_dir if ($cert_dir);

        if (defined $ENV{X509_CERT_DIR} && -d $ENV{X509_CERT_DIR}) {
            $cert_dir = $ENV{X509_CERT_DIR};
        }
        elsif(-l "$vdt_location/globus/TRUSTED_CA" && -d readlink("$vdt_location/globus/TRUSTED_CA")) {
            $cert_dir = readlink("$vdt_location/globus/TRUSTED_CA");
        }
        else {
            print "No CA Certificate directory was found. Please specify the certificate directory using --cert-dir option.\n";
            exit 1;
        }

        if ($supplied_cert_dir) {
            print "The supplied certificate directory, '$supplied_cert_dir' does not exist or is not a directory...\n";
            print "...using $cert_dir as CA certificate directory instead.\n";
        }
    }

    # Conf file location
    $update_certs_conf = VDTCerts::get_updater_conf_file_loc();

    if($command eq "showcaurl") {
        # Read in the configuration data.
        check_rpm();
        read_config_file();
        print "$config->{cacerts_url}\n";
    }
    elsif($command eq "listca") {
        check_openssl();
        check_rpm();
        read_config_file();
        search_ca_pattern($pattern,0);
    }
    elsif($command eq "verify") {
        check_openssl();
        my $ret = 0;
        if ($hash) {
            $ret = verify_ca_hash($hash);
        }
        else {
            $ret = verify_ca_pattern($pattern);
        }
        if ($ret eq "0") {
            print "VERIFY - OK\n";
        }
        elsif ($ret eq "2") {
            print "VERIFY - WARNING\n";
        }
        else {
            print "VERIFY - ERROR\n";
        }
        exit $ret;
    }
    elsif($command eq "diffcapackage") {
        check_rpm();
        check_openssl();
        read_config_file();
        my $success = get_distribution_certs_list();
        if (! $success) {
            print "The list of CA certificates in distribution could not be downloaded\n";
            print "Most likely you have a cacerts_url different from the standard VDT/OSG.\n";
            print "We cannot determine the diff. Exiting.\n";
            exit 1;
        }
        my $ret_code = find_diff();
        if($ret_code == 0) {
            print "Your packages were found to be consistent with the standard VDT/OSG distribution.\n"
            }
        exit $ret_code;
    }
    elsif($command eq "show") {
        check_openssl();
        show_single_ca($hash);
    }
    elsif($command eq "showchain") {
        check_openssl();
        show_chain_ca($hash);
    }
    elsif($command eq "refreshca") {
        check_rpm();
        is_writable();
        fetch_ca();
    }
    elsif($command eq "fetchcrl") {
        check_rpm();
        is_writable();
        fetch_crl();
    }
    elsif($command eq "setupca") {
        check_rpm();
        read_config_file();
        setup_ca();
        exit 0;
    }
    elsif($command eq "setcaurl") {
        # Read in the configuration data.
        check_rpm();
        read_config_file();
        is_writable();
        my $ret_code = set_caurl($is_setup);
        
        exit $ret_code;
    }
    elsif($command eq "add") {
        # Read in the configuration data.
        check_rpm();
        read_config_file();
        is_writable();
        if (!defined $hash) {
            print "Please specify the hash of the certificate file to be added.\n";
            exit 1;
        }
        my $added = add_ca($hash);
        my $ret_code = $added;
        if ($added) {
            $ret_code = write_config_file($is_setup);
        }
        exit $ret_code;
    }
    elsif($command eq "remove") {
        check_openssl();
        check_rpm();
        read_config_file();
        is_writable();
        if (!defined $hash) {
            print "Please specify the hash of the certificate file to be removed.\n";
            exit 1;
        }
        my $removed = remove_ca($hash);
        my $ret_code = $removed;
        if ($removed) {
            $ret_code=write_config_file($is_setup);
        }
        exit $ret_code;
    }
    else { 
        print "Unrecognised command\n";
        usage();
        exit 1;
    }
}

#---------------------------------------------------------------------
#
# version: Prints version of the tool
# Input  : None
# Output : None
#
#---------------------------------------------------------------------

sub version {
    print "$version\n";
    exit 0;
}   

#---------------------------------------------------------------------
#
# usage: Print usage information. 
# Input  : None
# Output : None
#
#---------------------------------------------------------------------

sub usage {
    setupca_usage() if($ARGV[0] and lc($ARGV[0]) eq "setupca");

    print "    vdt-ca-manage [global_options] command \n";
    print "    global_options =
        [--vdt-location <location>]
        [--verbose]
        [--force]
        [--cert-dir <location>]
        [--help | --usage]
        [--version]
        [--auto-refresh]

    command = [manage_command | status_command] 

    status_command = [
        showCAURL |
        listCA [--pattern <pattern>] |
        verify [--hash <CA hash>  | --pattern <pattern>] |
        diffCAPackage |
        show [--certfile <cert_file> | --hash <CA hash>] |
        showChain [--certfile <cert_file> | --hash <CA hash>]
    ]

    manage_command = [
        setupCA [--location <root|local|PATH> --url <vdt|osg|URL>] |
        refreshCA |
        fetchCRL |
        setCAURL [--url <URL>] |
        add [--dir <local_dir>] --hash <CA hash> |
        remove --hash <CA hash>
    ]\n";
    exit 1;
}


sub setupca_usage {

    print "vdt-ca-manage setupca --location [root|local|<PATH>] --url [vdt|osg|<URL>]
  Location:
    root  - install into /etc/grid-security
    local - install into \$VDT_LOCATION/globus/share
    PATH  - install into PATH (e.g. /nfs/certificates)

  URL:
    vdt - use the VDT convenience distribution
    osg - use the OSG GOC distribution
    URL - use the distribution at URL (e.g. http://your.site.edu/ca-certificates-manifest-file)
\n";
    exit 1;
}
   

#---------------------------------------------------------------------
#
# read_config_file: Read in the vdt-update-certs.conf file and
# populate $config variable.
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub read_config_file {
    $config = VDTCerts::read_updater_config_file();

    if(!$config) {
        print "Error reading vdt-update-certs configuration.\n";
        exit 1;
    }
}

#---------------------------------------------------------------------
#
# read_url: Read in the command line url passed and
# set $url variable correctly
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub read_url {
    if (!defined $url) {
        print "URL not specified. Please specify the URL you want to use.\nYou could also specify keywords osg/vdt as values for --url option and the correct osg/vdt URL will be used.\n\n";
        exit 1;
    }
    if ( $url =~ /^vdt$/i ) {
        $url = $vdt_ca_url;
    }
    elsif ( $url =~ /^osg$/i ) {
        $url = $osg_ca_url;
    }
}
#---------------------------------------------------------------------
#
# write_config_file: Write the vdt-update-certs.conf file using
# the values in $config. Runs fetch_ca and fetch_crl when config
# file is updated and auto-refresh option is enabled.
# Input  : $is_setup: 1 - if called from setup; 0 - otherwise
# Output : 1 - file successfully written; 0 - file not written
#
#---------------------------------------------------------------------

sub write_config_file {
    my ($is_setup) = @_;
    my $content = "# Configuration file for vdt-update-certs

# This file has been regenerated by vdt-ca-manage, which removes most
# comments.  You can still manually modify it, any manual change will
# be preserved if vdt-ca-manage is used again.

## cacerts_url is the URL of your certificate distribution
cacerts_url = " . $config->{cacerts_url} . "\n";
    
    $content .= "
## log specifies where logging output will go
";
    if (!$config->{log}) {
        $content .= "log = $vdt_location/vdt/logs/vdt-update-certs.log\n";
    }
    else {
        $content .= "log = " . $config->{log} . "\n";
    }


    $content .= "
## include specifies files (full pathnames) that should be copied
## into the certificates installation after an update has occured.
";
    my $includes = $config->{includes};
    foreach my $inc (@$includes) {
        $content .= "include=$inc\n";
    }
    $content .= "
## exclude_ca specifies a CA (not full pathnames, but just the hash
## of the CA you want to exclude) that should be removed from the
## certificates installation after an update has occured.
";

    my $excludes = $config->{excludes};
    foreach my $ex (@$excludes) {
        $content .= "exclude = $ex\n";
    }
    $content .= "\n";

    my $exclude_cas = $config->{exclude_cas};
    foreach my $ex (@$exclude_cas) {
        $content .= "exclude_ca = $ex\n";
    }
    $content .= "\n";

    if (!defined $config->{debug} || $config->{debug} eq "") {
        $content .= "debug = 0\n";
    }
    else {
        $content .= "debug = $config->{debug}\n";
    }

    my $return_code = safe_write($update_certs_conf,$content);
    if(!$is_setup) { #Do not fetchca and crls during setup
        if ($auto_refresh) {
            fetch_ca();
            fetch_crl();
        }
        else {
            print "NOTE:\n";
            print "\tYou did not specify the --auto-refresh flag.\n";
            print "\tSo the changes made to the configuration will not be reflected till the next time\n";
            print "\twhen CAs and CRLs are updated respectively by vdt-update-certs and fetch-crl running from cron.\n";
            print "\tRun \`vdt-ca-manage refreshCA\` and \`vdt-ca-manage fetchCRL\` to commit your changes immediately.\n";
        }
    }
    return $return_code;
}

#---------------------------------------------------------------------
#
# search_ca_pattern: Searches the certificate directory ($dir or 
# $cert_dir) and lists information of CA that matches the pattern
# (It is used by listca and showchain commands)
# Input  : pattern (in perl regular expression),
#          int : 0- for list all CA, 1 - for show chain
# Output : Issuer (for show chain), "" for list ca
#
#---------------------------------------------------------------------

sub search_ca_pattern {
    my ($local_pattern, $show_chain) = @_;

    $dir = $cert_dir if (! defined $dir || ! -d $dir);
    $local_pattern = "\\w*" if (! defined $local_pattern);
    my $success = 0;
    $success = get_distribution_certs_list() if (!$show_chain);

    foreach my $local_certs_file (`ls -1 $dir/*.0 2> /dev/null`) {
        chomp($local_certs_file);
        my $cert_values = `$openssl x509 -in $local_certs_file -subject -issuer -hash -noout 2>/dev/null`;
        my @values = split /\n/, $cert_values;
        my $subject = (split /subject=/, $values[0])[1];
        my $issuer = (split /issuer=/, $values[1])[1];
        chomp(my $local_hash = $values[2]);
        if (! $show_chain) {
            if ($subject =~ /$local_pattern/i || $issuer =~ /$local_pattern/i ) {
                my $accreditation = "";
                if ($success) {
                    if ($source{$local_hash} =~ /I/i) {
                        $accreditation .= "IGTF;";
                    }
                    if ($source{$local_hash} =~ /T/i) {
                        $accreditation .= "TeraGrid;";
                    }
                }
                $accreditation = "Unknown;" if ($accreditation eq "");

                my $status_info = VDTCerts::parse_certs_updater_status_file();
                my $cacerts_url = $status_info->{cacerts_url} || "Unknown";

                print "Hash=$local_hash; Subject=$subject; Issuer=$issuer; Accreditation=$accreditation Status=$cacerts_url\n";
                if ($verbose) {
                    $cert_values = `$openssl x509 -in $local_certs_file -dates -noout 2>/dev/null`;
                    @values = split /\n/, $cert_values;
                    print "\tCA Dates : $values[0]; $values[1]\n";
                    my $local_crl_file =  "$dir/$local_hash.r0";
                    if (-e $local_crl_file) {
                        my $crl_values = `openssl crl -in $local_crl_file -lastupdate -nextupdate -noout 2>/dev/null`;
                        @values = split /\n/, $crl_values;
                        print "\tCRL Dates: $values[0]; $values[1]\n\n";
                    }
                    else {
                        print "\tCRL file for $local_hash not found.\n\n";
                    }
                
                }
            }
        }
        else {
            # Subject and issuer have been transformed here to remove the ( and ) that occurs 
            # in one certificate and causes problem with pattern matching during showchain.
            # For listca command since the pattern is coming from the user they will, if needed 
            # put in the correct escape character.
            my $local_subject = $subject;
            my $local_issuer = $issuer;
            $subject =~ s/\)/_/g;
            $subject =~ s/\(/_/g;
            $issuer =~ s/\)/_/g;
            $issuer =~ s/\(/_/g;
            # For show chain the pattern passed requires an exact match, mon exact match can cause endless loop e.g. Hash: 34a509c3
            if ($subject =~ /^$local_pattern$/i) {
               print "=> Hash=$local_hash \n\tSubject=$local_subject \n\tIssuer=$local_issuer\n";
                if ($verbose) {
                    my $out = `$openssl x509 -text -noout -in $local_certs_file 2>/dev/null`;
                    print "$out\n";
                }
                # Return up chain issuer of the current certificate
                # If subject = issuer  you have reached the end of chain 
                return $issuer if ($show_chain && $subject ne $issuer);
                return "" if ($show_chain && $subject eq $issuer);
            }
        }
    }
#    print "Self Signed root-CA not found $local_pattern \n" if $show_chain;
    return "";
}

#---------------------------------------------------------------------
#
# show_ca_file: Show details of a particular CA file
# Input  : File (Path to the certificate file to be viewed)
# Output : Issuer of the cerifificate
#
#---------------------------------------------------------------------
sub show_ca_file {
    my ($local_certs_file) = @_;   

    # If no parameter is passed try to use the $certs_file passed in command line
    # If neither can be found quit.
    $local_certs_file = $certs_file if (! defined $local_certs_file || ! -e $local_certs_file && defined $certs_file);    

    if (!defined $local_certs_file || ! -e $local_certs_file ) {
        print "Certificate file '$local_certs_file' not found.\n";
        exit 1;
    }
    # If the file passed in is a proxy, then list the details of proxy and its issuer
    $local_certs_file = handle_proxy($local_certs_file);

    my $cert_values = `$openssl x509 -in $local_certs_file -subject -issuer -hash -noout 2>/dev/null`;
    my @values = split /\n/, $cert_values;
    my $subject =  (split /subject=/, $values[0])[1];
    my $issuer =  (split /issuer=/, $values[1])[1];
    chomp(my $local_hash =   $values[2]);

    print "Hash=$local_hash\n\tSubject=$subject\n\tIssuer=$issuer\n";
    if ($verbose) {
        my $out = `$openssl x509 -text -noout -in $local_certs_file 2>/dev/null`;
        print "$out\n";
    }
    if ($subject eq $issuer) {
        return "";
    }
    return $issuer;
}

#---------------------------------------------------------------------
#
# handle_proxy: Show details of a particular CA file
# Input  : File (Path to the certificate file to be checked for proxy)
# Output : File (Path to the rest of the certificate)
#
#---------------------------------------------------------------------
sub handle_proxy {
    my ($local_certs_file) = @_;
    my @contents = slurp($local_certs_file);
    my $count = 0;
    my $location = 0;
    my $i = 0;
    foreach my $line (@contents) {
        if ($line =~ /^-----BEGIN CERTIFICATE-----$/) {
            $count++;
            $location = $i;
        }
        $i++;
    }
    return $local_certs_file if $count<=1;

    #This file is a proxy
    my $cert_values = `$openssl x509 -in $local_certs_file -subject -issuer -hash -noout 2>/dev/null`;
    my @values = split /\n/, $cert_values;
    my $subject =  (split /subject=/, $values[0])[1];
    my $issuer =  (split /issuer=/, $values[1])[1];
    chomp(my $local_hash =   $values[2]);
    
    print "Hash=$local_hash\n\tSubject=$subject\n\tIssuer=$issuer\n";
    if ($verbose) {
        my $out = `$openssl x509 -text -noout -in $local_certs_file 2>/dev/null`;
        print "$out\n";
    }
    print "=> ";

    #Delete the proxy portion and create a new file
    my $working_dir = tempdir("vdtcert-XXXXXX", TMPDIR => 1, CLEANUP => 1);
    my $new_local_file = "$working_dir/" . basename($local_certs_file);

    open FILE, ">$new_local_file" || die $!;
    for($i = $location; $i <= $#contents; $i++) {
        print FILE $contents[$i]; 
    }
    close FILE;
    return $new_local_file;
}

#---------------------------------------------------------------------
#
# show_ca_hash: Show information of CA in $dir or $cert_dir that
# matches the hash
# Input  : Hash (of the certificate file to be viewed)
# Output : Issuer of the cerifificate 
#
#---------------------------------------------------------------------
sub show_ca_hash {
    my ($local_hash) = @_;    
    # $local_hash = $hash if (! defined $local_hash || $local_hash eq 0);
    $dir = $cert_dir if (! defined $dir || -d $dir);

    return show_ca_file("$dir/$local_hash.0");
}

#---------------------------------------------------------------------
#
# show_single_ca: Provides information about a particular CA.
# It takes in an hash as an argument. If hash is not provided
# it looks for the certfile argument. It returns the $issuer of
# certificate. It is used by show and showchain commands. In the 
# later it is used to bootstrap the first link in the chain
# Input  : Hash (of the certificate file to be viewed)
# Output : Issuer of the cerifificate
#
#---------------------------------------------------------------------
sub show_single_ca {
    my ($local_hash) = @_;    
    # $local_hash = $hash if (! defined $local_hash || $local_hash eq 0);
    if (defined $local_hash) {
        return show_ca_hash($local_hash);
    }
    elsif (defined $certs_file) {
        return show_ca_file($certs_file);
    }
    else {
        print "Please specify either --hash or --certfile\n";
        exit 1;
    }
}

#---------------------------------------------------------------------
#
# show_chain_ca: Show information the chaining information of the CA
# Input  : Hash (of the certificate file to be viewed)
# Output : None
#
#---------------------------------------------------------------------
sub show_chain_ca {
    my ($local_hash) = @_;    
    my $issuer = show_single_ca($local_hash);
    while ($issuer ne "") {
        $issuer = search_ca_pattern($issuer,1);
    }
}

#---------------------------------------------------------------------
#
# verify_ca_hash: Verify the CA and CRL file using a given hash
# Input  : Hash (of the certificate file to be verified)
# Output : 0 - Verify succeded, 1 - Errors, 2 - Warnings
#
#---------------------------------------------------------------------
sub verify_ca_hash {
    my ($local_hash) = @_;  
    my $ret = 0; #0-OK, 1-ERROR, 2-WARN
    $dir = $cert_dir if (! defined $dir || ! -d $dir);

    # Verifying CAs
    my $local_certs_file = "$dir/$local_hash.0";
    if (!defined $local_certs_file || ! -e $local_certs_file ) {
        print "Certificate file for $local_hash ('$local_certs_file') missing. VERIFY FAILED\n";
        return 1;
    }
    chomp(my $cert_values = `$openssl x509 -in $local_certs_file -subject -noout 2>/dev/null`);
    my $subject =  (split /subject=/, $cert_values)[1];

    my $verify_ca = `$openssl verify -CApath $dir $local_certs_file 2>/dev/null`;
    chomp($verify_ca = (split /:/, $verify_ca)[1]);
    if ($verify_ca !~ /OK/) {
        print "Subject: $subject\n";
        print "\tVERIFYING CA for $local_hash - FAILED ('$verify_ca')\n";
        return 1;
    }

    # Now checking for warning
    $cert_values = `$openssl x509 -in $local_certs_file -dates -noout 2>/dev/null`;
    my @values = split /\n/, $cert_values;
    my $start_time =  (split /notBefore=/, $values[0])[1];
    my $end_time =  (split /notAfter=/, $values[1])[1];
    # Parsing string of form: Oct  5 08:00:00 2008 GMT
    my @tmp_end_date = split /\s+/, $end_time;
    my @tmp_end_time = split /:/, $tmp_end_date[2];
    my $unix_end_time = gmt_to_unix_time($tmp_end_date[0],$tmp_end_date[1],$tmp_end_date[3], $tmp_end_time[0],  $tmp_end_time[1],  $tmp_end_time[2]);
    my $now = time();
    if($now + $warn >= $unix_end_time) {
        print "Subject: $subject\n";
        print "\tVERIFYING CA for $local_hash - WARNING (Certificate expires at $end_time)\n";
        $ret = 2;
    }
    else {
        if ($verbose) {
            print "Subject: $subject\n";
            print "\tVERIFYING CA for $local_hash - $verify_ca\n";
        }
    }

    #Verifying CRLs
    my $local_crl_file = "$dir/$local_hash.r0";
    if (!defined $local_crl_file || ! -e $local_crl_file ) {
        #print "Subject: $subject\n";
        print "CRL file for $local_hash missing. Skipping.\n" if ($verbose);
        return 0;
    }
    # Apprently the output "verify OK" is directed to stderr.
    my $verify_crl = `$openssl crl -CApath $dir -in $local_crl_file -noout 2>&1`;
    chomp($verify_crl);
    if ($verify_crl !~ /verify OK/) {
        print "Subject: $subject\n";
        print "\tVERIFYING CRL for $local_hash - FAILED ('$verify_crl')\n";
        return 1;
    }
    
    chomp(my $crl_values = `openssl crl -in $local_crl_file -nextupdate -noout 2>/dev/null`);
    my $crl_end_time =  (split /nextUpdate=/, $crl_values)[1];
    @tmp_end_date = split /\s+/, $crl_end_time;
    @tmp_end_time = split /:/, $tmp_end_date[2];
    $unix_end_time = gmt_to_unix_time($tmp_end_date[0],$tmp_end_date[1],$tmp_end_date[3], $tmp_end_time[0],  $tmp_end_time[1],  $tmp_end_time[2]);
    if($now >= $unix_end_time) {
        print "Subject: $subject\n";
        print "\tVERIFYING CRL for $local_hash - ERROR (CRL expired at $crl_end_time)\n";
        $ret=1 ;
    }
    elsif($now + $warn >= $unix_end_time) {
        print "Subject: $subject\n";
        print "\tVERIFYING CRL for $local_hash - WARNING (CRL expires at $crl_end_time)\n";
        $ret=2 ;
    }
    else {
        print "\tVERIFYING CRL for $local_hash - $verify_crl\n" if $verbose;
    }

    return $ret;
}

#---------------------------------------------------------------------
#
# verify_ca_pattern: Verify the CA and CRL file using a given pattern
# Input  : pattern to search (in perl regular expression)
# Output : 0 - Verify succeded, 1 - Errors, 2 - Warnings
#
#---------------------------------------------------------------------
sub verify_ca_pattern {
    my ($local_pattern) = @_;
    my $ret = 0;
    $dir = $cert_dir if (! defined $dir || ! -d $dir);
    $local_pattern = "\\w*" if (! defined $local_pattern); 
    foreach my $local_certs_file (`ls -1 $dir/*.0 2> /dev/null`) {
        chomp($local_certs_file);
        my $cert_values = `$openssl x509 -in $local_certs_file -subject -issuer -hash -noout 2>/dev/null`;
        my @values = split /\n/, $cert_values;
        my $subject =  (split /subject=/, $values[0])[1];
        my $issuer =  (split /issuer=/, $values[1])[1];
        chomp(my $local_hash =   $values[2]);
        if ($subject =~ /$local_pattern/i || $issuer =~ /$local_pattern/i ) {
            my $current_return = verify_ca_hash($local_hash);
            if($current_return ne 0) {
                if ($current_return eq 1) {
                    $ret = 1;
                }
                elsif ($ret eq 0) {
                    $ret = 2
                }
            }
        }
    }
    return $ret;
}

#---------------------------------------------------------------------
#
# get_distribution_list : Get a list of CA included in the distribution
# either from GOC or VDT. It populates the %source hash and tell it if
# that has was included in IGTF or TeraGrid distribution
# Input  : None
# Output : 0 - Unsuccessful; 1 - Success
#
#---------------------------------------------------------------------
sub get_distribution_certs_list {
    my $local_url;
    if($config->{cacerts_url} eq $osg_ca_url) { 
        $local_url="http://software.grid.iu.edu/pacman/cadist/INDEX.txt";
    }
    elsif ($config->{cacerts_url} eq $vdt_ca_url) {
        $local_url="http://vdt.cs.wisc.edu/releases/certs/ca_index-latest.txt";
    }
    else {
        #Don't know the url of discription file, for a non VDT/OSG certs distribution
        return 0;
    }
    my $working_dir = tempdir("vdtcert-XXXXXX", TMPDIR => 1, CLEANUP => 1);
    my $ca_index_file = "$working_dir/" . basename($local_url);

    VDTCerts::wget($local_url, $working_dir);
    if (!-e $ca_index_file) {
        #Download unsuccessful.
        return 0;
    }

    my @contents = slurp($ca_index_file);
    foreach my $line (@contents) {
        next if($line =~ /^Hash/i);
        next if($line =~ /^--/i);
        next if($line =~ /^\s*$/i); #Empty lines
        next if($line =~ /^\s*\#/i); #allow comments in future
        last if($line =~ /^Sources/i); #Reached end of file
        my @line_content = split /\s+/, $line;
        my $hash = $line_content[0];
        my $hash_name="";
        for (my $i=1; $i<=($#line_content-2);$i++) {
            $hash_name.=" ".$line_content[$i];
        }
        $source{"${hash}_name"} = $hash_name;
        my $local_source = $line_content[$#line_content];
        $source{$hash} = $local_source;
    }
    return 1;
}

#---------------------------------------------------------------------
#
# find_diff : Prints the difference between CAs present in the 
# certificate directory and the latest distribution from VDT/OSG
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub find_diff {
    # This diff list just checks the CA hashes 
    # If the hash has been excluded and then included from a local source. We will not put it in the diff list.
    my $return_code = 0;
    $dir = $cert_dir if (! defined $dir || ! -d $dir);
    # Find certs that were added
    foreach my $local_certs_file (`ls -1 $dir/*.0 2> /dev/null`) {
        my $current_hash =   fileparse($local_certs_file, qr/\.[^.]*/);
        next if exists $source{$current_hash}; # Included in the standard CA distribution.
        # A local certificate has been found
        my $cert_values = `$openssl x509 -in $local_certs_file -subject -noout 2>/dev/null`;
        my @values = split /\n/, $cert_values;
        my $subject =  (split /subject=/, $values[0])[1];
        print "> $current_hash. [Certificate with subject ($subject) has been included locally in your installation]\n";
        $return_code = 1;
    }
    # Find certs that were removed
    for my $current_hash ( keys %source ) {
        next if ($current_hash =~ /_name$/); #Ignore the hashes that end in _name, since these are just the identify names of the hashes
        next if (-e "$dir/$current_hash.0");

        # A certificate has been removeda
        my $accreditation = "";
        if ($source{$current_hash} =~ /I/i) {
            $accreditation.=" IGTF";
        }
        if ($source{$current_hash} =~ /T/i) {
            $accreditation.=" TeraGrid";
        }
        $accreditation = "Unknown" if($accreditation eq "");
        my $hashname = $source{$current_hash."_name"};
        $hashname = "Unknown" if (! $hashname);
        print "< $current_hash. [Certificate from $hashname with $accreditation Accreditation has been excluded from your local installation]\n";
        $return_code = 1;
    }
    return $return_code;
}

#---------------------------------------------------------------------
#
# set_caurl : Change the CAcerts_url
# Input  : $is_setup: 1 - if called from setup; 0 - otherwise
# Output : 1 - Change made and config file was written successfully.
#          0 - No change made  and config file was not written.
#
#---------------------------------------------------------------------
sub set_caurl {
    my ($is_setup) = @_;
    read_url();
    my $description = VDTCerts::fetch_ca_description($url);
    my $valid = $description->{valid};
    my $ret_code = $valid;
    if ($valid) {
        $config->{cacerts_url} = $url;
        $ret_code = write_config_file($is_setup);
    }
    elsif ($force && !$is_setup) {
        # We don't want to allow force during setup 
        print "The CA certificate URL you provided does not point to a valid description file.\n";
        print "Since --force was specified, this URL will be written into the config file anyways.\n";
        print "Please note that vdt-update-certs might not work correctly.\n";
        $config->{cacerts_url} = $url;
        $ret_code = write_config_file($is_setup);
    }
    else {
        print "The CA certificate URL you provided was deemed not correct\n";
        print "NO change were made \n";
    }
    return $ret_code;
}


#---------------------------------------------------------------------
#
# setup_ca : Calls vdt-setup-ca-certificates
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub setup_ca {
    my $ret_code = set_caurl(1);
    if($ret_code != 1) {
        print "CA Certificates has not been set up. Exiting.\n";
        exit 1;
    }
    print "Setting CA Certificates for VDT installation at '$vdt_location'\n";
    
    # Determine the installation location.  Allow for 'root' and 'local' keywords
    if(!$install_location) {
        print "ERROR: You must pass --location with the setupCA option\n";
        print "       The location can be a path, or one of the following options:\n";
        print "       root - Installs certificates into /etc/grid-security\n";
        print "       local - Installs certificates into \$VDT_LOCATION/globus/share\n";
        exit 1;
    }
    elsif($install_location =~ /root/i) {
        $install_location = "/etc/grid-security";
    }
    elsif($install_location =~ /local/i) {
        $install_location = "$vdt_location/globus/share";
    }
    
    $ret_code = failsafe_system("$vdt_location/vdt/sbin/vdt-setup-ca-certificates --certs-dir $install_location");
    if($ret_code != 0) {
        print "\nSetup did not complete successfully.\nPlease check the logs ($vdt_location/logs) for more information.\n";
        exit 1;
    }
    else {
        print "\nSetup completed successfully.\n";
    }
    
}

#---------------------------------------------------------------------
#
# fetch_ca : Executes vdt-update-certs
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub fetch_ca {
    my $vdt_update_wrapper = "$vdt_location/vdt/sbin/vdt-update-certs-wrapper";
    if (! -e $vdt_update_wrapper ) {
        print "VDT update wrapper not found at ('$vdt_update_wrapper').\n";
        exit 1;
    }
    my $ret;
    print "Fetching CAs....\n";
    if (!$force) {
        $ret = `$vdt_update_wrapper --vdt-install $vdt_location 2>&1`;
    }
    else {
        $ret = `$vdt_update_wrapper --vdt-install $vdt_location --force 2>&1`;
    }
    print "$ret\n";
}

#---------------------------------------------------------------------
#
# fetch_crl : Executes fetch-crl
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub fetch_crl {
    my $fetch_crl_exec = "$vdt_location/fetch-crl/sbin/fetch-crl";
    print "Fetching CRLs....\n";
    if (! -e $fetch_crl_exec ) {
        print "Fetch CRL not found at ('$fetch_crl_exec').\n";
        exit 1;
    }
    # Check that fetch-crl is running from cron
    my @crontab = `crontab -l`;
    my $done=0;
    foreach my $line (@crontab) {
        next if $line =~ /^\s*#/;
        if($line =~ /$vdt_location\/fetch-crl\/share\/doc\/fetch-crl-\d*.\d*.\d*\/fetch-crl.cron/) {
            $done=1;
        }
    }
    if (!$done) {
        # We are even not allowing force here. We could, but this is bound to lead to problems.
        print "WARNING: Fetch CRL is not running via crontab (of uid: $>).\n";
        print "         Fetching the CRLs using this tool without enabling cron could cause them to expire without being refreshed.\n";
        print "         This will cause authentication failures.\n";
        print "         We will not be fetching CRLs. If you want to use the fetchCRL functionality please install fetch-crl cron.\n";
        print "...done\n";
        exit 1;
    }
    

    my $ret;
    if ($verbose) {
        $ret = `$fetch_crl_exec  --loc $cert_dir --out $cert_dir`;
    }
    else {
        $ret = `$fetch_crl_exec  --loc $cert_dir --out $cert_dir --quiet`;
    }
    
    print "$ret\n";
    print "...done\n";
    open FILE, ">$vdt_location/vdt/var/fetch-crl.lastrun" || die $!; 
    print FILE time; # Should we do this?; 
    close FILE;
}

#---------------------------------------------------------------------
#
# add_ca : Adds a new local CA
# Input  : hash to be added (dir is a global variable)
# Output : 0 - No change made, 1 - Certificate added
#
#
#---------------------------------------------------------------------
sub add_ca {
    my ($local_hash) = @_;

    # First check in excludes. If present remove it and return success
    my $current_excludes = $config->{excludes};
    my @new_excludes = ();
    my $remove=0;
    foreach my $ex (@$current_excludes) {
        my $current_hash =   fileparse($ex, qr/\.[^.]*/);
        if ( $current_hash =~ $local_hash ) {
            #Remove certificate from excludes list
            $remove=1;
        }
        else {
            push (@new_excludes, $ex);
        }
    }
    if ($remove) {
        #change made to excludes list. Copy over and we are done.
        $config->{excludes} = \@new_excludes;
        return 1;
    }
    # Here we are checking the excludes_ca list
    my $current_exclude_cas = $config->{exclude_cas};
    my @new_exclude_cas = ();
    $remove=0;
    foreach my $ex (@$current_exclude_cas) {
        if ( $ex =~ $local_hash ) {
            #Remove certificate from excludes list
            $remove=1;
        }
        else {
            push (@new_exclude_cas, $ex);
        }
    }
    if ($remove) {
        #change made to excludes_ca list. Copy over and we are done.
        $config->{exclude_cas} = \@new_exclude_cas;
        return 1;
    }
    # We have determined that excluded file is not the target of the add command
    # Perform checks for existance of certfile and directory
    if (!defined $dir || !-d $dir ) {
        print "Directory where the CA file to be added is located is not specified or does not exist.\n";
        print "Please check the --dir parameter\n";
        exit 1;
    }
    if ( $dir =~ $cert_dir ) {
        print "Directory where files to be added are located ('$dir') should be different from certificate directory ('$cert_dir').\n";
        exit 1;
    }
    # checking for .0 and .crl_url file. Do we need to check for anything else?
    if (!-e "$dir/$local_hash.0") {
        print "Certificate file '$dir/$local_hash.0' could not be found \n";
        print "No changes were made to configuration.\n";
        exit 1;
    }
    if (!-e "$dir/$local_hash.signing_policy") {
        print "Signing policy file '$dir/$local_hash.signing_policy' could not be found \n";
        print "No changes were made to configuration.\n";
        exit 1;
    }
    # Next we will check CA directory and includes list to make sure the hash is not already included.


    #Check in certificate directory
    if (-e "$cert_dir/$local_hash.0") {
        print "A certificate file with a same hash ($local_hash) is already present in the $cert_dir.\n";
        print "No changes were made.\n";
        return 0;
    }
    # check in includes
    my $current_includes = $config->{includes};
    my @new_includes = ();
    foreach my $in (@$current_includes) {
        my $current_hash =   fileparse($in, qr/\.[^.]*/);
        if ( $current_hash =~ $local_hash ) {
            # Hash already included
            print "A certificate file with a same hash ($local_hash) is already present in the includes list.\n";
            print "No changes were made.\n";
            return 0;
            
        }
        else {
            push (@new_includes, $in);
        }
    }
    # Hash can now be included. 
    foreach my $in (`ls -1 $dir/$local_hash.* 2>/dev/null`) {
        chomp($in);
        if ($in !~ m/.r0$/) {
            push (@new_includes, $in);
        }
    }
    $config->{includes} = \@new_includes;
    return 1;
}

#---------------------------------------------------------------------
#
# remove_ca : Removes a CA from the trusted list
# Input  : hash of CA to be removed
# Output : 0 - No change made, 1 - Certificate removed
#
#---------------------------------------------------------------------
sub remove_ca {
    my ($local_hash) = @_;

    # check in includes list
    my $current_includes = $config->{includes};
    my @new_includes = ();
    my $remove = 0;
    foreach my $in (@$current_includes) {
        my $current_hash =   fileparse($in, qr/\.[^.]*/);
        if ( $current_hash =~ $local_hash) {
            # We go through the entire list since there can be multiple include files with same hash e.g. hash.0, hash.crl_url
            next if ($remove); # Already checked and decided to remove no need to recheck.
            
            # Hash is included. Remove it from the includes list.
            my $child_certs = has_child_certificates($local_hash);
            if ($child_certs) {
                print "The hash ('$local_hash') you wish to remove has childeren certificate.\n" ;
                if($force) {
                    $remove = 1;
                }
                else {
                    # We have found the cert and decided not to remove. 
                    # We can quit this function
                    print "You may use the --force option to remove the certificate anyway regardless the dependencies.\n";
                    print "No changes were made to the configuration.\n";
                    return 0;
                }
            }
            else {
                $remove = 1;
            }
        }
        else {
            push (@new_includes, $in);
        }
    }
    if ($remove) {
        $config->{includes} = \@new_includes;
        return 1;
    }
    # Check the excludes_ca list
    my $current_exclude_cas = $config->{exclude_cas};
    foreach my $ex (@$current_exclude_cas) {
        if ( $ex =~ $local_hash ) {
            # Hash is already included in the exclude_calist. So no changes made
            print "The same hash ('$local_hash') is already present in the exclude_ca list.\n";
            print "No changes were made to the configuration.\n";
            return 0;
        }
    }
    # Check the excludes list
    my $current_excludes = $config->{excludes};
    foreach my $ex (@$current_excludes) {
        my $current_hash =   fileparse($ex, qr/\.[^.]*/);
        if ( $current_hash =~ $local_hash ) {
            # Hash is already included in the excludes list. So no changes made
            print "The same hash ('$local_hash') is already present in the excludes list.\n";
            print "No changes were made to the configuration.\n";
            return 0;
        }
    }
    #Check in certificate directory
    $remove=0;
    $current_exclude_cas = $config->{exclude_cas};
    #my @new_exclude_cas = ();
    #foreach my $ex (@$current_exclude_cas) {
    #   push(@new_exclude_cas, $ex);
    #}
    my $child_certs;
    if ( -e "$cert_dir/$local_hash.0" ) {
        $child_certs = has_child_certificates($local_hash);
        if ($child_certs) {
            print "The hash ('$local_hash') you wish to remove has childeren certificate.\n" ;
            if($force) {
                push (@$current_exclude_cas, $local_hash);
                $remove = 1;
            }
            else {
                print "You may use the --force option to remove the certificate anyway regardless the dependencies.\n";
                print "No changes were made to the configuration.\n";
            }
        }
        else {
            push (@$current_exclude_cas, $local_hash);
            $remove = 1;
        }
    }

    if ($remove) {
        $config->{exclude_cas} = \@$current_exclude_cas;
        return 1;
    }
    else {
        if(!defined $child_certs || $child_certs == 0) {
            # If we decided not to remove due to child certificate then don't print this message
            print "No certificate with ('$local_hash') was found that could be removed.\n";
            print "No changes were made to the configuration.\n";
        }
        return 0;
    }
}

#---------------------------------------------------------------------
#
# has_child_certificates : Checks if a CA has issued other certificate.
# This fuction is used before deciding if a certificate can be removed.
# Input  : hash of CA
# Output : 0 - No childern/force option is used, 
#          1 - Child certificates found.
#
#---------------------------------------------------------------------
sub has_child_certificates {
    my ($local_hash) = @_;
    if ($force) {
         # No checks on force 
        print "You are forcing a certificate file ('$local_hash') to be removed. Be WARNED, it would cause any certificates issued by that CA or its children to be rejected.\n";
        return 0;
    }

    $dir = $cert_dir if (! defined $dir || ! -d $dir);
    if(!-e "$dir/$local_hash.0" ) {
        print "The certificate for the $local_hash, you specified was found in the includes list, but the corresponding CA files were not found\n";
        print "We are unable to determine if there might be any child certificates that depend on this CA.\n";
        print "You may use the --force option to remove the certificate, if you are confident about the dependencies.\n";
        print "No changes were made to the configuration.\n";
        exit 1; #return 1;
    }
    # get subject of current hash
    chomp(my $cert_values = `$openssl x509 -in $dir/$local_hash.0 -subject -noout 2>/dev/null`);
    my $subject =  (split /subject=/, $cert_values)[1];
    # Replace () by _. Interferes with pattern matching. (needed for a particular certificate)
    $subject =~ s/\)/_/g;
    $subject =~ s/\(/_/g;

    #check if the suject of current hash is the issuer of a different certificate
    foreach my $local_certs_file (`ls -1 $dir/*.0 2> /dev/null`) {
        my $current_hash =   fileparse($local_certs_file, qr/\.[^.]*/);
        # Dont check the certificate itself. This allows self signed certificate to be removed
        # without --force as long as it does not have any other childeren
        next if($current_hash eq $local_hash); 
        chomp($local_certs_file);
        chomp($cert_values = `$openssl x509 -in $local_certs_file -issuer -noout 2>/dev/null`);
        my $issuer =  (split /issuer=/, $cert_values)[1];
        $issuer =~ s/\)/_/g;
        $issuer =~ s/\(/_/g;
        if ($issuer =~ /^$subject$/i ) {
            return 1;
        }
    }
    return 0;
}

########################## Helper Functions ##########################
#---------------------------------------------------------------------
#
# check_openssl: Find the appropriate openssl binaries.
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub check_openssl {
    if ( -e "$vdt_location/globus/bin/openssl") {
        $openssl = "$vdt_location/globus/bin/openssl";
    }
    elsif(which("openssl")) {
        $openssl = `which openssl 2>/dev/null`;
        chomp($openssl);
    }
    else {
        print "Could not find openssl command. Please make sure openssl is installed and in your path.";
        exit 1;
    }
}

#---------------------------------------------------------------------
#
# is_writable: Check the ownership of the conf file and certificate
# directory to see if it is writable by the user.
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub is_writable {
    return if not defined $cert_dir;

    my $cert_dir_uid = (stat($cert_dir))[4];
    if (($< != 0) && ($cert_dir_uid != $<)) {
        print "You are neither running as root or have ownership of $cert_dir directory.\n";
        print "Please specify appropriate CA certificate directory using --cert-dir option.\n";
        exit 1;
    }

    my $update_certs_conf_uid = (stat($update_certs_conf))[4];
    if (($< != 0) && ($update_certs_conf_uid != $<)) {
        print "You are neither running as root or have ownership of the configuration file $update_certs_conf.\n";
        print "Please specify appropriate CA certificate directory using --cert-dir option.\n";
        exit 1;
    }
}

#---------------------------------------------------------------------
#
# gmt_to_unix_time: Convert time from GMT to unix
# Input  : (short month name, date, year, hour, min, sec)
# Output : Unix time
#
#---------------------------------------------------------------------
sub gmt_to_unix_time {
    my ($month_s, $date, $year, $hour, $min, $sec) = @_;
    my %months = (
        'Jan' => '0',
        'Feb' => '1',
        'Mar' => '2',
        'Apr' => '3',
        'May' => '4',
        'Jun' => '5',
        'Jul' => '6',
        'Aug' => '7',
        'Sep' => '8',
        'Oct' => '9',
        'Nov' => '10',
        'Dec' => '11'
    );
    my $month = $months{$month_s};
    $year -= 1900;
    return timegm($sec, $min, $hour, $date, $month, $year);
}

#---------------------------------------------------------------------
#
# check_rpm: Check if Certificate update is being managed by RPM
# Input  : None
# Output : None
#
#---------------------------------------------------------------------
sub check_rpm {
    if (which("rpm")) {
        # Need to check if this command is correct. Is the package I am testing with --whatprovides option correct?
        my $rpm_out = `rpm -q --whatprovides vdt-update-certs 2>/dev/null`;
        if ($rpm_out && $rpm_out !~ /^no package provides/i) {
            print "You seem to have used RPM to install certificates ($rpm_out). Continuing anyway.\n";
        }
    }
}
