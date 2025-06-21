WEIGHTS=(0 390 1000)
INT_WEIGHT=390

export INSTANCE_WEIGHTS=(0 160 320 390 475 560 670 780 890 1000)
export INSTANCE_BOLD_WEIGHT=780

declare -a INSTANCE_NAMES
INSTANCE_FILENAMES["0"]=EL
INSTANCE_FILENAMES["160"]=L
INSTANCE_FILENAMES["320"]=N
INSTANCE_FILENAMES["390"]=R
INSTANCE_FILENAMES["475"]=BK
INSTANCE_FILENAMES["560"]=M
INSTANCE_FILENAMES["670"]=SB
INSTANCE_FILENAMES["780"]=B
INSTANCE_FILENAMES["890"]=EB
INSTANCE_FILENAMES["1000"]=H

build_vf_ufo() {
  STYLE=$1
  FILENAME=$2
  WEIGHT=$3
  MASTER_FILENAME=${FILENAME}-weight${WEIGHT}-Master
  DIR=$4
  DEST="$DIR/${MASTER_FILENAME}.ufo"

  if [ -d "$DEST" ]; then
    echo "[WEIGHT=${WEIGHT}] UFOs for TTF build already exist: $DEST"
    return
  fi

  SRC="$DIR/${MASTER_FILENAME}.otf"
  if [ ! -f "$SRC" ]; then
    echo "[WEIGHT=${WEIGHT}] Error: $SRC does not exist."
    exit 255
  fi

  CMD="tx -ufo $SRC $DEST"
  echo "[WEIGHT=${WEIGHT}] Generating UFOs for TTF build: $CMD"
  $CMD
}

build_vf_otf() {
  STYLE=$1
  FILENAME=$2

  for WEIGHT in "${WEIGHTS[@]}"
  do
    DIR=weight${WEIGHT}
    MASTER_FILENAME=${FILENAME}-weight${WEIGHT}-Master
    if [[ $WEIGHT -eq $INT_WEIGHT ]]; then
      echo "[;WEIGHT=${WEIGHT}] (Intermediate) Building instance..."

      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

      echo "[WEIGHT=${WEIGHT}] $CMD"
      $CMD
    else
      echo "[WEIGHT=${WEIGHT}] (Upstream) Building instance..."

      CMD="makeotf -nshw -f ./source/$STYLE/vf/masters/$DIR/cidfont.ps -ff ./source/$STYLE/vf/masters/$DIR/features.fea -fi ./source/$STYLE/vf/masters/$DIR/cidfontinfo -mf ./source/$STYLE/vf/FontMenuNameDB -r -nS -cs 2 -ch ./source/$STYLE/common/cmap -ci ./source/$STYLE/common/sequences.txt -o /tmp/${MASTER_FILENAME}.otf"

      echo "[WEIGHT=${WEIGHT}] $CMD"
      $CMD
    fi

    build_vf_ufo "$STYLE" "$FILENAME" "$WEIGHT" /tmp
  done
}

build_vf_gf() {
  mkdir -p $BUILD_GF_DIR
  FILENAME=$1
  REBUILD=$2

  OUTPUT="${FILENAME/VF/}"

  if [ -z "$REBUILD" ]; then
    cp ./designspaces/$FILENAME.designspace /tmp/$FILENAME.designspace
    echo "Building OTF variable font..."
    buildcff2vf --omit-mac-names -d /tmp/$FILENAME.designspace -o /tmp/$FILENAME.otf
  fi

  CURRENT_DIR=$PWD
  cd /tmp || { echo "Failure"; exit 1; }

  sfntedit -x cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB /tmp/$FILENAME.otf
  sfntedit -a cmap=_tb_cmap,GDEF=_tb_GDEF,GPOS=_tb_GPOS,GSUB=_tb_GSUB /tmp/variable/$OUTPUT[wght].ttf

  python3 /tmp/gf_post.py $OUTPUT[wght].ttf

  ttx -m /tmp/$OUTPUT[wght].ttf /tmp/BASE.ttx -o /tmp/$OUTPUT[wght].ttf -f

  echo "Moving files to the target directory..."
  mv /tmp/$OUTPUT[wght].ttf $CURRENT_DIR/build/VAR_GF/
  
  cd $CURRENT_DIR || { echo "Failure"; exit 1; }
}


# Use the default BUILD_ROOT if not already defined
if [ -z "$BUILD_ROOT" ]; then
  BUILD_ROOT=./build
fi

BUILD_GF_DIR=$BUILD_ROOT/VAR_GF

cp ./scripts/build_var_ttf.py /tmp
cp ./scripts/gf_post.py /tmp
cp ./scripts/gf_notdef.py /tmp
cp ./scripts/config.yaml /tmp
cp ./scripts/BASE.ttx /tmp
cp ./designspaces/ChironGoRoundTC.designspace /tmp/

build_vf_otf "regular" "ChironGoRoundTCVF" 
python3 /tmp/gf_notdef.py 
echo "Building TTF variable fonts..."
gftools builder /tmp/config.yaml

build_vf_gf "ChironGoRoundTCVF"