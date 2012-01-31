%META:TOPICINFO{author="KyleGross" date="1328026263" format="1.1" version="1.17"}%
%META:TOPICPARENT{name="ReleaseDocumentation.CertScriptsPackage"}%
%DOC_STATUS_TABLE%

%TOC%

---++ Certificate Scripts Man Pages
---+++ README
   * [[%ATTACHURL%/README][README]]: V2-7 README file

---+++ cert-check-time
   * [[%ATTACHURL%/cert-check-time.txt][cert-check-time.txt]]: V2-7 cert-check-time help

---+++ cert-gridadmin
   * [[%ATTACHURL%/cert-gridadmin.txt][cert-gridadmin.txt]]: V2-7 cert-gridadmin help

---+++ cert-lookup
   * [[%ATTACHURL%/cert-lookup.txt][cert-lookup.txt]]: V2-7 cert-lookup help

---+++ cert-request
   * [[%ATTACHURL%/cert-request.txt][cert-request.txt]]: V2-7 cert-request help

---+++ cert-retrieve
   * [[%ATTACHURL%/cert-retrieve.txt][cert-retrieve.txt]]: V2-7 cert-retrieve help

---+++ cert-renew
   * [[%ATTACHURL%/cert-renew.txt][cert-renew.txt]]: V2-7 cert-renew help

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

Unchanged since 24 August 2007, package version V2-5

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

<!-- CONTENT MANAGEMENT PROJECT

   DEAR DOCUMENT OWNER
   ===================

   Thank you for claiming ownership for this document! Please fill in your FirstLast name here:
   * Local OWNER          = JamesBarlow

   Please define the document area, choose one of the defined areas from the next line
   DOC_AREA = (ComputeElement|Storage|VO|Security|User|Monitoring|General|Integration|Operations|Tier3)
   * Local DOC_AREA       = Security

   define the primary role the document serves, choose one of the defined roles from the next line
   DOC_ROLE = (Scientist|Student|Developer|SysAdmin|VOManager)
   * Local DOC_ROLE       = SysAdmin

   Please define the document type, choose one of the defined types from the next line
   DOC_TYPE = (Trash/Troubleshooting|Training|Installation|HowTo|Planning|Navigation|Knowledge)
   * Local DOC_TYPE       = Knowledge
   
   Please define if this document in general needs to be reviewed before release ( %YES% | %NO% )
   * Local INCLUDE_REVIEW = %YES%

   Please define if this document in general needs to be tested before release ( %YES% | %NO% )
   * Local INCLUDE_TEST   = %NO%

   change to %YES% once the document is ready to be reviewed and back to %NO% if that is not the case
   * Local REVIEW_READY   = %YES%

   change to %YES% once the document is ready to be tested and back to %NO% if that is not the case
   * Local TEST_READY     = %NO%

   change to %YES% only if the document has passed the review and the test (if applicable) and is ready for release
   * Local RELEASE_READY  = %NO%


   DEAR DOCUMENT REVIEWER
   ======================

   Thank for reviewing this document! Please fill in your FirstLast name here:
   * Local REVIEWER       = MineAltunay
  
   Please define the review status for this document to be in progress ( %IN_PROGRESS% ), failed ( %NO% ) or passed ( %YES% )
   * Local REVIEW_PASSED  = %NO%


   DEAR DOCUMENT TESTER
   ====================

   Thank for testing this document! Please fill in your FirstLast name here:
   * Local TESTER         = 
  
   Please define the test status for this document to be in progress ( %IN_PROGRESS% ), failed ( %NO% ) or passed ( %YES% )
   * Local TEST_PASSED    = %IN_PROGRESS%
 
-->








%META:FILEATTACHMENT{name="README" attachment="README" attr="" comment="V2-7 README file" date="1242684478" path="README" size="5897" stream="README" tmpFilename="/usr/tmp/CGItemp64431" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-check-time.txt" attachment="cert-check-time.txt" attr="" comment="V2-7 cert-check-time help" date="1242684601" path="cert-check-time.txt" size="1672" stream="cert-check-time.txt" tmpFilename="/usr/tmp/CGItemp64453" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-gridadmin.txt" attachment="cert-gridadmin.txt" attr="" comment="V2-7 cert-gridadmin help" date="1242684696" path="cert-gridadmin.txt" size="3068" stream="cert-gridadmin.txt" tmpFilename="/usr/tmp/CGItemp64565" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-lookup.txt" attachment="cert-lookup.txt" attr="" comment="V2-7 cert-lookup help" date="1242684772" path="cert-lookup.txt" size="2209" stream="cert-lookup.txt" tmpFilename="/usr/tmp/CGItemp64390" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-request.txt" attachment="cert-request.txt" attr="" comment="V2-7 cert-request help" date="1242684851" path="cert-request.txt" size="3923" stream="cert-request.txt" tmpFilename="/usr/tmp/CGItemp64523" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-retrieve.txt" attachment="cert-retrieve.txt" attr="" comment="V2-7 cert-retrieve help" date="1242684919" path="cert-retrieve.txt" size="2756" stream="cert-retrieve.txt" tmpFilename="/usr/tmp/CGItemp64511" user="DougOlson" version="1"}%
%META:FILEATTACHMENT{name="cert-renew.txt" attachment="cert-renew.txt" attr="" comment="V2-7 cert-renew help" date="1242684994" path="cert-renew.txt" size="1988" stream="cert-renew.txt" tmpFilename="/usr/tmp/CGItemp64461" user="DougOlson" version="1"}%
