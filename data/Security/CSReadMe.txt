%META:TOPICINFO{author="KyleGross" date="1225985965" format="1.1" version="1.13"}%
%META:TOPICPARENT{name="CertScriptsPackage"}%
%TOC%

---++ Certificate Scripts Man Pages
---+++ README
<verbatim>
Cert-Scripts package is a (incomplete) set of scripts contributed
by the PPDG RA to help with various functions related to the
DOEGrids PKI. Now maintained by the OSG RA.
For questions, comments, info contact ra@ppdg.net, or Doug Olson,
dlolson@lbl.gov, osg-ra@opensciencegrid.org.

Contents:
cert-scripts/
 README -                 this file
 example-service-request.txt -  example wrapper script to cert-gridadmin
                                to generate certificate and key files
                                named <hostname-service>{cert|key}.pem
 bin/
  cert-check-time -       checks lifetime of certificates and revocation lists
  cert-gridadmin -        submit/get certificate via GridAdmin interface
  cert-lookup -           queries directory based on DN of certificates
  cert-request -          generates and submits a certificate signing request
  cert-retrieve -         retrieves signed certificate previously requested
  cert-renew -            renews existing certificate for OU=People
  multi-cert-gridadmin -  get multiple certificates via GridAdmin interface
 lib/
  cert-time-expires.awk - used by cert-check-time.sh
  cert-time-sort.awk -    used by cert-check-time.sh
  CertLib.pm -            perl utilities
  CertLib.py -            python utilities

 test/                    various files used for testing a release,
  ...                     not necesarily needed for an installation

 dev/                     part of a complete source distribution
  ...                     for extra code under development or temporarily
                          needed modifications to external packages
  M2Crypto                the external package with mods needed for
                          multi-cert-gridadmin

Install instructions:
  For all scripts except for multi-cert-gridadmin you can just
  untar to directory location where you want them installed.
  multi-cert-gridadmin has some additional installation requirements.
  See InstallationNotes.txt for more description of the current status
  of installing multi-cert-gridadmin and its dependencies.

Release notes:
Version: V2-6  13 Feb. 2008
       Bug fix in cert-gridadmin about SSL Server in nscerttype
       Other minor repairs and cleanup.

Version: V2-5  24 Aug. 2007
       Bug fixes in multi-cert-gridadmin.
       Add PKCS12 export option to cert-retrieve and cert-renew.

Version: V2-4  6 July 2007
       Updates for new CA software deployed 5 July 2007, RHCS 7.1
       Includes updated email notifications for script requested certificates.

Version: V2-3  1 June 2007
       Added multi-cert-gridadmin to support multiple certificates with
       a single GridAdmin request.

Version: V2-2  19 Mar. 2007
       Added http_proxy support to cert-request, cert-retrieve, cert-gridadmin,
       CertLib.pm.  Before it was only in cert-renew (go figure???).

Version: V2-1  20 Nov. 2006
       Add SSL_Server attribute to cert-gridadmin requests.
       Remove SSL_Server from OU=People requests in cert-request.
       Update list of VOs in default volist in CertLib.pm.

Version: V2-0  5 Oct. 2006
       Change to pull allowed RA and VO information from live (remote)
       sites instead of being wired into the scripts. A default is
       included in the script in case of communications errors while the
       script executes.  This affects cert-request, cert-retrieve,
       cert-gridadmin, cert-renew.

Version: V1-9  6 Sept. 2006
       Update list of RAs and VOs. PPDG, iVDGL, 'Other' RAs are out.
       Update cert-request/cert-retrieve with -label option to match
            permit matching multiple request/retrieve sessions.
       Add -e flag (query by  email address) to cert-lookup.
       Cert-renew requires new keys to be generated.

Version: V1-8a 20 July 2006
       Change to cert-request to require -name for service certificates.
       Add package version number into UserAgent string in all scripts that
          POST to a web submission interface.

Version: V1-8  30 June 2006
       Update scripts to work with http_proxy gateways. (Thanks to J. Smith)
       Update for OSG RA, including list of OSG VOs.
       Added example-service-request.txt (Thanks to M. Ballantijn)
       Bug fix to correct HTTP_PARAMS.subject which caused incorrect CN in email
           notice to agents.

Version: V1-7  13 Dec 2005
       Add cert-gridadmin script.
       cert-lookup changed because the temporary binary certificate files
       produced by ldapsearch became mixed case rather than lower case.
       It is unknown what caused this change butit may be that previous
       versions of cert-lookup will not work.

Version: V1-6  14 Mar 2005
       Change -comment option in cert-request to mandatory -reason flag.
       Subscriber must give a reason they qualify for a DOEGrids certificate.

Version: V1-5 22 Feb 2005
       Change package layout according to VDT suggestion to
       include cert-scripts home directory as well as
       bin and lib sub directories.

Version: V1-4  26 Jan 2005
       restrict possible affiliations in cert-request to a specified list
       reduce amount of /dev/urandom to 255 chars in cert-request

Version:  V1-3  25 Jan 2005
       clarified that cert-renew is only for OU=People

Version:  V1-2  19 Jan 2005

For additional information use -help flag with each script, or see
http://twiki.grid.iu.edu/twiki/bin/view/Security/CertScriptsPackage.

</verbatim>

---+++ cert-check-time
<verbatim>
$ cert-check-time -h
usage: cert-check-time [-c][-l][-n][-r][-k][-v][-h][-d <workdir>] \
                [-e <address>][-L <filename>][-s <scriptdir>]
  Version: V2-6
  Checks the remaining lifetime of CRL's and certificates and
  makes an output listing and/or notification by email,
  sorted by remaining lifetime.
  Requires a writable working directory and creates some temporary files.
  Options
   -c  check lifetime of CA certificates
   -R    verify that each CA certificate has an accompanying CRL, print
         warning notice if not, applies to -c option
   -d  <working directory>  sets the working directory, CWD by default
   -e  <email address> sets email address and notification by email
   -h  this usage description
   -k  leave temporary files (noclean)
   -l  check lifetime of local certificates
   -L  <filename> file with list of local certificates, default = local-certs.txt
         This is useful for checking the lifetime of user or host certificates.
   -n  do not print results to stdout. useful for cron job & email notification
   -r  check lifetime of CRL's
   -s  <script directory>
         specifies location of awk helper scripts
         if not set it defaults to the location of this executing script, or
         if CERT_SCRIPTS_HOME environment variable is set it will use
             CERT_SCRIPTS_HOME/lib as the helper script location, or
         uses the value of CERT_SCRIPT_DIR environment variable.
         Command line value overrides environment variable.

 Uses environment variable X509_CERT_DIR to locate the trusted CA certificates
 and revocation lists.
 If not set then it uses /etc/grid-security/certificates, the Globus default.
</verbatim>

---+++ cert-gridadmin
<verbatim>
$ cert-gridadmin -help
usage is :  cert-gridadmin  <arguments>
    version V2-6
       -host <FQDN>              required
       -service <service name>   optional
       -email <your email, as the owner of the requested certificate>
       -affiliation <user's affiliation>
          (name of your RA to process this request)
       -vo <virtual organization>
          (name of primary virtual organization, only for the OSG RA)
       -list  display list of available RA affiliations and exit
       -prefix <prefix>  prefix for <prefix>{cert|key}.pem file names
            typically used to match service/host to file names
       -password <optional file containing passphrase for private key>
       -request  <optional certificate request>
       -pdir  <optional directory to find user credential for authentication>
                    defaults to ~/.globus
       -sdir  <optional directory to put services credential being generated>
                   defaults to .
       -ca <optional name of CA> to use, default is doegrids,
                 or test2 for worthless certs for testing
       -show  list several parameters of the issued certificate upon successful completion
       -debug spews lots of output to the terminal
       -dryrun  executes script but does not actually post request to CA
       -noclean  do not delete temporary files
       -timeout <seconds> timeout for http transactions
       -help  prints this message
       -V    prints package version and exits
       any required omitted argruments will be prompted for


  When successful, a certificate (and key) file is generated with
  a name like NNNNNcert.pem (NNNNNkey.pem).  These files should be
  moved to the proper location and the key file protected carefully
  since, as a service certificate key, it is not encrypted or
  password protected.

 Side effects:
      Generates some temporary files that are removed automatically
      under normal circumstances.

  To use the gridadmin interface you must have your personal certificate
  pre-authorized with the CA.  If you are unsure if this was done you
  should check with your Registration Authority.  A list of RAs are shown at
  www.doegrids.org.
  It is recommended that you verify that the certificate subject names you
  are requesting are not already issued to someone else. You can do this
  with the cert-lookup script, or via a search for certificates at the
  www.doegrids.org web site.


  This software is contributed to the DOEGrids PKI and is supported by
  the OSG RA.  Please send any questions, comments, problems to
  osg-ra@opensciencegrid.org and/or dlolson@lbl.gov.
</verbatim>

---+++ cert-lookup
<verbatim>
$ cert-lookup -h
usage: cert-lookup { -s|-p } { -n <name> | -e <email> } [-c] [-v] [-V]
   version: V2-6
  Queries the DOEGrids ldap directory of public certificates
  and prints some information from the certificates for each
  matching subject name.
   -p  searches in OU=People     (one of -p or -s is required)
   -s  searches in OU=Services
   -n  <name>  name is the subject name to look up, can include
               wildcards, i.e., "*Olson*" will match all subject
               names that include 'Olson' in them
   -e  <email>  part or all of the email address to look up, can include
               wildecards
         (one of -n or -e is required)
   -c  a debugging option, will cause temporary files & directories
       to be left and not deleted, means 'no clean'
   -d  <workingn directory>, defaults to .
   -v  verbose option, prints lots of debugging info
   -V  print version of cert-scripts package and exit

 Description of output:
  For each matching subject name entry in the ldap directory the following
  3 lines (sometimes 2) are written to stdout:
------------------------------------------------------------------------
     cn: <matching CN component of subject name>  email:  <address>
sponsor: <name of person given as sponsor to request for this certificate>
     RA:  registration authority affiliation

Note that service certificates and some person certificate directory
entries do not have the sponsor field, or email address.
If there are valid (not revoked) certificates for this subject name they
are listed as follows (there can be several certificates):
-----------------
subject= <full subject name from certificate from 'openssl -subject'>
serial= <serial number of certificate, from 'openssl -serial'>
<email address from 'openssl -email'>
notBefore= <starting validity date, from openssl -startdate'>
notAfter= <ending validity date, from 'openssl -enddate'>


  Side effects:
     Creates some temporary files with prefix 'tmp'
     and directories named 'cn-#' where # is a number.
     These temporary files & directories are removed unless -c is used.

 Questions & comments about this script should be directed to
 osg-ra@opensciencegrid.org, or dlolson@lbl.gov
</verbatim>

---+++ cert-request
<verbatim>
$ cert-request -help
usage is :  cert-request  <arguments>
       version V2-6
       -agree  flag to indicate acceptance of the DOEGrids policies
               described at
               and asserting that you are authorized to request and install
               this certificate on the specified host.
       -ou  [p | s]   for OU=People or OU=Services
       -name <user's full name>       required (quote "multiple words")
       -host <FQDN>  for OU=Services, required
       -service <service name>   for OU=Services, optional
       -email <user's email>
       -phone <user's phone>
       -reason <short description of why you qualify to receive a certificate>
         e.g.   the science project or collaboration you are a member of,
                the DOE facility where you are employee or guest
                the university and department where you are a student
                (quote "multiple words")
       -affiliation <user's affiliation>
          (name of your RA to process this request)
       -vo <user's virtual organization>
          (name of your Virtual Organization, only when OSG is selected as your RA)
       -list  display list of available RA affiliations and exit
       -label <request label> optional label for request used to identify local
                files used when certificate is later retrieved,
                necessary when making multiple requests before retrieving
                approved certificates.
                if files with this label exist already an error exit occurs

       Sponsor information required for OU=People
       -sponsor_name <sponsor's name>  (quote "multiple words")
       -sponsor_email <sponsor's email>
       -sponsor_phone <sponsor's phone>

       -ca <optional name of CA> to use, default is doegrids,
                            or testca for worthless certs for testing
       -password <optional file containing passphrase for private key>
       -request  <optional certificate request>
       -dir      <optional directory in which to store the private key>
                    default is ~/.globus for -ou p
                    default is . for -ou s
                    if the specified directory does not exist it is created
       -debug spews lots of output to the terminal
       -dryrun  executes script but does not actually post request to CA
       -noclean  do not delete temporary files
       -timeout <seconds> time limit for http requests
       -help  prints this message
       -V  print package version and exit
       any required omitted argruments will be prompted for
  This software is contributed to the DOEGrids PKI and is supported by
  the OSG RA.  Please send any questions, comments, problems to
  osg-ra@opensciencegrid.org and/or dlolson@lbl.gov.
  
Side effects:
      Generates some temporary files that are removed automatically
      under normal circumstances.
      Also generates files for the key pair, CSR, and a file called
      currentCertReq.  These files need to be left alone until the
      request/approval/retrieval process if complete as they are used
      by the cert-retrieve script to download the public certificate
      once it has been issued.  Therefore one should use a separate working
      directory for each request if there are multiple requests in process
      simultaneously.
</verbatim>

---+++ cert-retrieve
<verbatim>
$ cert-retrieve -help
usage: cert-retrieve  {-serialnum SN | -certnum SN | -url URL | -reqid RID}
            [-dir DIR] [-keyfile KEY] [-prefix PREFIX] [-label LABEL]
            [-ca CA] [-p12 PKCS12file] [-force] [-debug] [-help] [-V]
      version: V2-6
        SN certificate serial number
        URL the download url for the certificate sometimes sent in an
            email notificate that the certificate is approved
        RID is the request ID of the Request (not certificate) to download.
              NOTE - this uses the agent interface and needs to be
              authenticated with an agent certificate, which means
              it does notwork for most people
        DIR directory for the usercert and key, defaults to ~/.globus
        KEY name of keyfile for private key corresponding to this cert
        PREFIX  causes the key and cert files to be named PREFIXcert.pem
                and PREFIXkey.pem rather than usercert.pem and userkey.pem.
        LABEL  a label used to match the certificate request
             files (incl. private key) with the retrieved certificate.
        CA is the optional name of the CA to use, default is doegrids,
                 other allowed values are for testing
        PKCS12file is the filename to use for exporting your certificate
                   into a PKCS12 format file that can be used to import
                   your certificate into your web browser or email application.
                   This is useful for personal certificates but not very
                   useful for host or service certificates.
                   This file is not affected by the -dir argument.
       -force causes existing credential files to be overwritten with asking
       -debug prints what it is doing
       -help  prints this message
       -V  prints package version and exits
       any omitted argruments will be prompted for.

  Note that options -ca, -dir and -label, if used, must match the values
  used with cert-request. Also it is STRONGLY RECOMMENDED that -dir and
  -label are specified for host and service certificates, because the
  defaults will overwrite your personal certificate in ~/.globus.

  This software is contributed to the DOEGrids PKI and is supported by
  the OSG RA.  Please send any questions, comments, problems to
  osg-ra@opensciencegrid.org and/or dlolson@lbl.gov.

  Side effects:
    Generates some temporary files that get removed in normal operation.
    Relies on files produced by cert-request in order to retrieve the
    corresponding certificate.
</verbatim>

---+++ cert-renew
<verbatim>
$ cert-renew -help
usage: cert-renew <arguments>
  version: V2-6
  get a new replacement certificate with the same DN as your existing cert.
  Only for OU=People, not for host or service certificates.
       -agree  flag to indicate acceptance of the DOEGrids policies
               described at
       -cert <certificate to be replaced>
                 defaults to usercert.pem, only OU=People is allowed
       -key  <private key corresponding to certificate>
                 defaults to userkey.pem
       -prefix Causes the new credential to be written to
                 <prefix>cert.pem and <prefix>key.pem
                 instead of usercert.pem and userkey.pem
       -dir  <optional directory in which to find and store the
                 certificate and key>
                 defaults to ~/.globus
       -ca  <optional name of CA> to use, default is 'doegrids',
                                or testca for worthless certs for testing
       -p12  <PKCS12 file>   create a PKCS12 file with your credential which
             can be used for importing to your web browser or email,
             or for backup to offline storage.
             Note that you will be prompted for a passphrase to encrypt
             the credential exported to this file.
       -dryrun   execute script but do not post the request to the CA
       -noclean   do not remove temporary files
       -debug spews lots of output to the terminal
       -timeout <seconds>  timeout for http transactions
       -help  prints this message
       -V  print package version and exit
       any omitted and required arguments will be prompted for.

  Beginning V1-9 generating new keys is required and not optional.

  This software is contributed to the DOEGrids PKI and is supported by
  the OSG RA.  Please send any questions, comments, problems to
  osg-ra@opensciencegrid.org and/or dlolson@lbl.gov.


  Side effects:
    Generates some temporary files that get removed in normal operation.
</verbatim>

---+++ multi-cert-gridadmin

<verbatim>
$ multi-cert-gridadmin -h
checking CertLib version, V2-6,  This is the latest version.
multi-cert-gridadmin


    is used to generate CSRs (certificate signing requests)
    and to submit the CSRs to the CA for generating certificates.
    The submission is authenticated with the client certificate which
    has been pre-authorized to submit via the GridAdmin interface.
    It functions in four basic modes called csr-from-list, csr-from-cert,
    csr-submit and cn-submit, as described below, in addition to
    help and information.  Options and arguments are not order dependent
    except that the mode label listeed above should be the first non-option
    argument.

    multi-cert-gridadmin [-h | -l | -n | | -T seconds | -z ] [anything]

    multi-cert-gridadmin csr-from-list [-n] [-d wdir] [-i file-with-list]
                      [CN1 [CN2 [CN3 ...]]]

    multi-cert-gridadmin csr-from-cert [-d wdir] [-i file-with-list] [cert1
                     [cert2 [cert3 ...]]]

    multi-cert-gridadmin csr-submit -e email -a RA -v VO [-t] [-c creddir]
                [-s CA] [-d wdir] [-i file-with-list] [CSR1 [CSR2 [CSR3 ...]]]

    multi-cert-gridadmin cn-submit -e email -a RA -v VO [-t] [-c creddir]
                [-s CA] [-d wdir] [-i file-with-list] [CN1 [CN2 [CN3 ...]]]

      Options:
         -a RA is the RA affiliaiton
         -c creddir is the directory containing the users credentials,
                    usercert.pem and userkey.pem.  The default value
                    is ~/.globus. See also -p, -k.
         -d wdir is the working directory used for the request, key and
                 certificate files. It does not apply to -i.
         -e email is the email address submitted with the CSRs to be included
                  in the issued certificates
         -h print out usage (and exit)
         -i file-with-list is a path to the file (CSV format) containing
                           the list of items. See descriptions of modes
                           below for the content of this file.
         -k privkey-file is the name of the private key file of the users
                         credentials. The full path is creddir/privkey-file.
                         See also -c, -p.
         -l list valid choices for (-a RA), (-s CA), (-v VO), and exit
         -n more verbose output (Not quiet).
         -p public-cert-file is the filename of the users public certificate.
                             The full path is creddir/public-cert-file.
                             See also -c, -k.
         -s CA is the name of the Certification Authority to post the CSR to.
               Only doegrids is a production CA. The others are testing CAs
               or debugging web servers.
               See also -l.
         -t test only mode for cn-submit, csr-submit. Script is executed
            without posting to the CA.
         -T seconds - sets the timeout for http transactions
         -v VO is the Virtual Organization name associated with the OSG RA.
               See also -a, -l.
         -x ssl-debug-level sets the level of debug messages for the SSL
                            connection.
         -z print version info and exit

    Information only mode:
        See -h, -l, -z.

    csr-from-list mode:
        generates a set of PKCS10 format certificate signing requests
        for the list of CNs supplied, in the namespace
        OU=Services,DC=doegrids,DC-org.  The set of CSRs and private keys
        are located in wdir.  A CN has the form service/fqdn, and the
        corresponding CSRs and private key files are named as
        fdqn-service-req.pem and fqdn-service-key.pem, respectively.
        The contents of the (-i) file-with-list optional file is a
        list of CNs in CSV format. If the optional header line is used
        it should label the appropriate column with 'CN' (not case dependent).
        If not header line is used the values in the first column are used.
        Comment lines have a '#' as the first character.
        CN component names can also be provided as commandline arguments
        as indicated above.

    csr-from-cert mode:
         generates a set of PKCS10 format certificate signing requests
         matching the list of certificates supplied, in the namespace
         OU=Services,DC=doegrids,DC-org.  The set of generated CSRs and private
         keys are located in wdir.  A CN has the form service/fqdn,
         and the corresponding CSRs and private key files are named as
         fdqn-service-req.pem and fqdn-service-key.pem, respectively.
         The optional (-i) file-with-list contains a list of path names
         to certificate files to be used, in CSV format.  If the optional
         header line is used the column should be labelled with 'CERTFILE'
         (not case dependent). If no header line is used the values in column
         one are used.  Comment lines have a '#' as the first character.
         Paths to certificate files can also be provided as command line
         arguments as shown above.

    csr-submit mode:
         submits a set of CSRs to the GridAdmin interface of the
         CA and downloads the corresponding signed certificates.
         It is assumed that CSR files are named as fqdn-service-req.pem
         and the corresponding private key files are named
         fqdn-service-key.pem.  The downloaded certificates are stored
         in files named fqdn-service-cert.pem.
         Possibly, if no specific CSRs are given, it will submit all
         the *req.pem files it can find in wdir.
         The optional (-i) file-with-list contains, in CSV format, a list
         of path names to the CSR files to submit.  If the optional header
         line is used it should label the appropriate column with 'CSR'
         (case independent). If a header line is not used the first column
         is used.  Comment lines have a '#' as the first character.
         Path names to CSR files can also be given on the command line
         as shown above.

    cn-submit mode:
         generates CSRs based on the CNs listed and submits these CSRs
         to the GridAdmin interface of the DOEGrids CA and downloads
         the corresponding signed certificates.
         The CSR files are named as fqdn-service-req.pem
         and the corresponding private key files are named
         fqdn-service-key.pem.  The downloaded certificates are stored
         in files named fqdn-service-cert.pem.
         The optional (-i) file-with-list contains, in CSV format, a list
         of CNs to submit.  If the optional header line is used it should
         label the appropriate column with 'CN' (case independent).
         If a header line is not given the value in the first column is used.
         Comment lines have a '#' as the first character.
         CNs can also be given on the command line as shown above.
         In this mode the private key generation and submission
         to the CA happens within the same command, which can be
         time consuming.

    Note that file-with-list should be in CSV format (RFC4180), although
    this program does not contain a complete implementation of the RFC.
    A # in column one indicates a comment line, in variance with the RFC.
    If a header line is used, the labels CN, CSR and CertFile correspond
    to the values used for csr-from-list, csr-submit and csr-from-cert
    respectively.  Otherwise the interesting value is assumed to
    be in the left most column.
    Version V2-6
</verbatim>

---+++ !InstallationNotes.txt

<verbatim>
Installation Notes

24 August 2007, package version V2-5

This note describes the current status of installation of the
multi-cert-gridadmin script.  All other scripts can be installed
via tar as described in README.

multi-cert-gridadmin is written in python and uses the M2Crypto
python package, with a modification.  The stock M2Crypto package
does not include the SWIG interface to defining the domainComponent
element of an X509 SubjectName.  The modified package in
cert-scripts/dev/M2Crypto/m2crypto-0.17 contains the modification
to including domainComponent in the X509 subjectName.

M2Crypto has dependencies on SWIG and openssl, and possibly the
version of python.  It has been tested to work with an installation
of python 2.4 and openssl 0.98.e.  It appears that the minimum
SWIG version is 1.3.24.  Getting it worked out for
smooth installation with VDT is in progress.

To install the modified M2Crypto read the INSTALL file in
cert-scripts/dev/M2Crypto/m2crypto-0.17.


</verbatim>

Main.DougOlson - 30 Jun 2006