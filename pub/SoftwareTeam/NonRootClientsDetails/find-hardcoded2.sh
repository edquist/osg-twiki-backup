# Run through each package mentioned in stdin and tally up the number of ELF
# files that have FHS locations in them
while read pkg; do
    let num_hardcoded_bins=0
    for f in `rpm -ql $pkg`; do
        file $f | grep -q ELF && {
            if grep -Eq '/usr|/lib(64)?|/etc|/var|/bin|/sbin' $f; then
                let num_hardcoded_bins++
            fi
        }
    done
    if [[ $num_hardcoded_bins -gt 0 ]]; then
        printf "%s\t%d\n" $pkg $num_hardcoded_bins
    fi
done


