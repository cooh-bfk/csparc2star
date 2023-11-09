#!/bin/bash

# We load PyEM module to enable csparc2star.py
#  - https://github.com/asarnow/pyem/blob/master/csparc2star.py
# Please modify the line below to adapt to your environment
source ~/software/miniconda3/etc/profile.d/conda
conda activate pyem


### Script body. No need to change below ###

# class -1 by default
class=-1

# parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --o) outdir="${2%/}"; shift ;;
        --j) shift ;;
        --pipeline_control) shift ;;
        --d|--dir|--directory|--project|--project*) project="${2%/}"; shift ;;
        --n|--job|--job_number) job="${2#J}"; shift ;;
        --p|--particle|--particle*|--data|--image) particle="${2#J}"; shift ;;
        --c|--class) class="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; echo > $outdir/RELION_JOB_EXIT_FAILURE; exit 1 ;;
    esac
    shift
done

# warn if no job number given
if [ ! -d "$project/J$job" ]; then
  echo $project/J$job " does not exist."
  echo > $outdir/RELION_JOB_EXIT_FAILURE
  exit 1
fi

# find particle.cs from last iteration, and find passthrough
for i in $project/J$job/*particles*cs; do
  if [[ $i == *class_* ]]; then
    # use specific class if --class is given
    if [[ $i == *class_$(printf "%02d" "${class}")*_particles.cs ]]; then
      csfile_class=$i
    fi
  elif [[ $i == *passthrough* ]]; then
    passthrough=$i
  else
    csfile=$i
  fi
done

# use csfile_class if --class is given
if [ $class != -1 ]; then
  csfile=$csfile_class
fi

# print inputs
echo "CryoSPARC job directory:"
echo "  $project/J$job"

# warn and exit if .cs file does not exist
if [ ! -e "$csfile" ]; then
  echo $csfile " does not exist."
  echo > $outdir/RELION_JOB_EXIT_FAILURE
  exit 1
fi

# execute csparc2star.py and correct mrc to mrcs
outfile=$outdir/$(basename ${csfile/.cs/.star})
echo "Converting metadata file:"
echo "  $outfile"
csparc2star.py $csfile $passthrough $outfile
sed -i 's/particles.mrc /particles.mrc:mrcs /g' $outfile

# generate symlink to particle image directory
if [ ! -d "$project/J$particle" ]; then
  echo "Particle location not provided. RELION may not find particle images."
else
  echo "Generating particle symlink:"
  echo "  $outdir/J$particle -> $project/J$particle"
  sed -i "s|J$particle|$outdir/J$particle|g" "$outfile"
  ln -s $project/J$particle $outdir/J$particle
fi

# define nodes
cat > $outdir/RELION_OUTPUT_NODES.star <<EOL
data_output_nodes
loop_
_rlnPipeLineNodeName
_rlnPipeLineNodeType
${outfile} ParticlesData.star.relion
EOL

# exit
echo > $outdir/RELION_JOB_EXIT_SUCCESS
