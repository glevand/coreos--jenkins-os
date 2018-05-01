#!/bin/bash -e

usage() {
	echo "Backup jenkins job configs to a directory."
	echo "Usage: CURL_OPTS='' job-backup jenkins_url [directory]"
	exit 1
}

if [ -z $1 ]; then
	echo "ERROR: Pass Jenkins URL"
	usage
fi

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	usage
fi

JENKINS_URL=$1
out=$2

: ${out:="jobs"}

path_to_obj() {
	echo "${1}" | sed -e "s|/|/job/|g"
}

process_jobs() {
	local parent="${1}"
	local jobs="${2}"
	local prefix

	if [ -z "${parent}" ]; then
		prefix="/"
	else
		prefix=${parent}
	fi

	if [ -z "${jobs}" ]; then
		echo -e "${prefix}:\t No jobs found."
		return
	fi

	local list=$(echo ${jobs} | sed -e "s|\n| |g")
	echo -e "${prefix}:\t Processing jobs [${list}]"

	local j
	for j in ${jobs}; do
		j="${parent}/${j}"
		echo -e "${prefix}:\t Saving job ${j} to ${out}${j}/config.xml"
		mkdir -p ${out}${j}
		local obj=$(path_to_obj ${j})
		curl ${CURL_OPTS} --silent ${JENKINS_URL}${obj}/config.xml > ${out}${j}/config.xml
	done
}

process_folders() {
	local parent="${1}"
	local folders="${2}"
	local prefix

	if [ -z "${parent}" ]; then
		prefix="/"
	else
		prefix=${parent}
	fi

	if [ -z "${folders}" ]; then
		echo -e "${prefix}:\t No folders found."
		return
	fi

	local list=$(echo ${folders} | sed -e "s|\n| |g")
	echo -e "${prefix}:\t Processing folders [${list}]"

	local f
	for f in ${folders}; do
		f="${parent}/${f}"
		echo -e "${prefix}:\t Saving folder ${f} to ${out}${f}/config.xml"
		mkdir -p ${out}${f}
		local obj=$(path_to_obj ${f})
		curl ${CURL_OPTS} --silent ${JENKINS_URL}/${obj}/config.xml > ${out}${f}/config.xml
		process_folder "${f}"
	done
}

process_folder() {
	local parent="${1}"
	local obj

	if [ -z "${parent}" ]; then
		obj=""
	else
		obj=$(path_to_obj ${parent})
	fi

	local xml="$(curl ${CURL_OPTS} --silent --header "Content-Type: application/xml" \
		-XPOST "${JENKINS_URL}${obj}/api/xml?tree=jobs\[name\]")"

	local jobs="$(echo ${xml} | grep --perl-regexp --only-matching '(?<=(?<!Folder'\''>)<name>).*?(?=</name>)' || true)"
	process_jobs "${parent}" "${jobs}"

	local folders="$(echo ${xml} | grep --perl-regexp --only-matching '(?<=Folder'\''><name>).*?(?=</name>)' || true)"
	process_folders "${parent}" "${folders}"
}

process_folder ""
