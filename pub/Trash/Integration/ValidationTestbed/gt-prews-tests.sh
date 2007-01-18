#!/bin/sh

time_left=0
time_left=`grid-proxy-info -timeleft | sed "s/\n//"`;
if [ ${time_left} -le 0 ]; then
    echo "ERROR: User proxy has expired. Renew and then rerun $0";
fi

condor_arch=INTEL
condor_os=LINUX

function run_job_manager_test
{
    scheduler=$1

    echo "globus_gram_job_manager_test ($scheduler)"
    globus-personal-gatekeeper -killall
    globus-personal-gatekeeper -start -jmtype ${scheduler}
    set CONTACT_STRING `globus-personal-gatekeeper -list`
    export CONTACT_STRING

    if [ $scheduler == "condor" ]; then
        config_dir=`/bin/ls -d ~/.globus/personal-gatekeeper*`
        echo "Found condor jobmanager directory: $config_dir"

        echo "-condor-arch=${condor_arch}" >> ${config_dir}/jobmanager.conf
        echo "-condor-os=${condor_os}" >> ${config_dir}/jobmanager.conf
        echo "New jobmanager.conf:"
        cat ${config_dir}/jobmanager.conf
    fi

    cd $GLOBUS_LOCATION/test/globus_gram_job_manager_test/
    ./TESTS.pl 2>&1 | tee tests-${scheduler}.log
}

unset CONTACT_STRING

echo "globus_gram_client_test"
cd $GLOBUS_LOCATION/test/globus_gram_client_test/
./TESTS.pl 2>&1 | tee tests.log
echo

echo "globus_gram_protocol_test"
cd $GLOBUS_LOCATION/test/globus_gram_protocol_test/
./TESTS.pl 2>&1 | tee tests.log
echo

run_job_manager_test fork
echo
run_job_manager_test pbs
#echo
#run_job_manager_test condor
