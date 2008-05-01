#!/bin/sh

SRM_ENDPOINT="srm://gwdca04.fnal.gov:8443/srm/managerv2?SFN=/pnfs/fnal.gov/data"
FILE_BASENAME=test1a
VONAME=cms

lcg-cp -v -b -D srmv2 file:/bin/sh ${SRM_ENDPOINT}/${FILE_BASENAME}1; echo

lcg-gt -b -v -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}1 gsiftp; echo

lcg-gt -b -v -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}1 dcap; echo

lcg-cp -v -b -D srmv2 file:/bin/sh ${SRM_ENDPOINT}/${FILE_BASENAME}2; echo

lcg-getturls -b -v -p gsiftp -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}1 ${SRM_ENDPOINT}/${FILE_BASENAME}2; echo

lcg-getturls -b -v -p dcap -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}1 ${SRM_ENDPOINT}/${FILE_BASENAME}2; echo

lcg-del -b -v -l --vo ${VONAME} -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}1; echo

lcg-del -b -v -l --vo ${VONAME} -D srmv2 ${SRM_ENDPOINT}/${FILE_BASENAME}2; echo
