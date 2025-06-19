#!/bin/bash

. $(dirname "$0")/profile

export_ufo() {
  mkdir -p $BUILD_VF_DIR

  STYLE=$1
  FILENAME=$2
  for WEIGHT in "${WEIGHTS[@]}"
  do
    DIR=weight${WEIGHT}
    MASTER_FILENAME=${FILENAME}-_weight${WEIGHT}-Master
    if [[ $WEIGHT -eq $INT_WEIGHT ]]; then
      echo "[WEIGHT=${WEIGHT}] (Intermediate) Building instance..."

      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

      echo "[WEIGHT=${WEIGHT}] $CMD"
      $CMD
    else
      echo "[WEIGHT=${WEIGHT}] (Upstream) Building instance..."

      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -mf ./source/$STYLE/vf/FontMenuNameDB -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

      echo "[WEIGHT=${WEIGHT}] $CMD"
      $CMD
    fi

  done
}

export_ufo "regular" "ChironGoRoundTCVF"
