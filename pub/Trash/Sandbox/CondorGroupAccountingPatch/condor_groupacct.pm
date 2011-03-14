package Globus::GRAM::JobManager::condor_groupacct;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(obtain_condor_group, test);
our $VERSION = 1.00;

sub obtain_condor_group {
    $defaultgroup = "DefaultGroup";
    $uid_filename = $ENV{'VDT_LOCATION'} . '/vdt-app-data/uid_table.txt';
    $ea_filename  = $ENV{'VDT_LOCATION'} . '/vdt-app-data/ea_table.txt';

    @environment = @{shift(@_)};
    $jmref = shift(@_);

    populate_uid_table();
    $group = match_uid_to_condor_group();
    return $group if $group;

    populate_extended_attribute_table();

    $group = match_extended_attribute_to_condor_group();
#    $group = $defaultgroup if (!$group);  #
    return $group; 
}

sub match_uid_to_condor_group {
    # check numeric UID first, then username
    $name = getpwuid($>);
    $group = $uid_hash{$>}; return $group if $group;
    $group = $uid_hash{$name}; return $group if $group;
} 

sub populate_uid_table {
    if (open UIDFILE, "<$uid_filename") {
	while (<UIDFILE>) {
	    next if ($_ =~ m/^\#/);  # remove comments
	    next if !($_ =~ m/\w+/); # remove blank lines
	    $_ =~ s/\#.*$//;         # remove comments
	    ($uid, my $group) = split(/\s+/, $_);

	    $uid_hash{$uid} = $group;
	}
	close UIDFILE;
    } else {
	$$jmref->log("unable to open $uid_filename.");
    }
}

sub match_extended_attribute_to_condor_group() {
    map {
        if ($_->[0] eq 'X509_USER_PROXY') {$proxy_filename = $_->[1];}
    } @environment;


    if (not $proxy_filename) {
	$proxy_filename = $ENV{X509_USER_PROXY};
    }

    if ($proxy_filename) {
	@attributes = split "\n",
	`voms-proxy-info -all -file $proxy_filename | grep -E "attribute|subject"`;
    }

    foreach $regexp (@ea) {
	foreach $attribute (@attributes) {
	    eval {if ($attribute =~ m/$regexp/) {
		$group = $ea_hash{$regexp};
		$$jmref->log("match found: regexp: $regexp,\tgroup: $group\n");
		goto match_found;
	    } };
	    $$jmref->("regexp match error in condor_groupacct: @_") if @_;
	}
    }

  match_found:
    return $group;
}

sub populate_extended_attribute_table {
    if (open EAFILE, "<$ea_filename") {
	while (<EAFILE>) {
	    next if ($_ =~ m/^\#/);  # remove comments
	    next if !($_ =~ m/\w+/); # remove blank lines
	    $_ =~ s/\#.*$//;         # remove comments

	    @fields = split(/\s+/, $_);
	    $groupname = pop(@fields);
	    $ea_name = join " ", @fields;

	    push @ea, $ea_name;
	    $ea_hash{$ea_name} = $groupname;
	}
	close EAFILE;
    } else {
	$$jmref->log("unable to open $ea_filename.");
    }
}

