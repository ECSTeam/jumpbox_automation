#!/bin/bash

set -e

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ "$4" = "" ]; then
  echo $0: usage: $0 concourse-target pipeline.yml config.yml pipeline-name
  exit
fi

concourse_target=$1
pipeline=$2
config=$3
pipeline_name=$4

if [ ! -e  $pipeline ]; then
  echo $0: Pipeline file does not exist: $pipeline
  exit
fi

if [ ! -e  $config ]; then
  echo $0: Config file does not exist: $config
  exit
fi

fly -t $concourse_target set-pipeline -c $pipeline -l $config -p $pipeline_name -n

fly -t $concourse_target unpause-pipeline -p $pipeline_name
