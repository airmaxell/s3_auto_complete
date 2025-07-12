#!/bin/bash

_aws_s3_autocomplete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # echo "DEBUG cur=$cur prev=$prev" > /tmp/aws_autocomplete_debug.log

    if [[ "$cur" == s3://* ]]; then
        local bucket_and_path="${cur#s3://}"
        local bucket="${bucket_and_path%%/*}"
        local prefix="${bucket_and_path#*/}"

        # echo "bucket=$bucket" >> /tmp/aws_autocomplete_debug.log
        # echo "prefix=$prefix" >> /tmp/aws_autocomplete_debug.log

        if [[ "$bucket_and_path" != */* ]]; then
            local buckets=$(aws s3 ls 2>>/tmp/aws_autocomplete_debug.log | awk '{print $3}')

            suggestions=$(printf "%s\n" $buckets | sed 's|^|s3://|;s|$|/|')

            COMPREPLY=( $(compgen -W "$suggestions" -- "$cur") )

            # OVO SPREČAVA automatski razmak posle popune
            compopt -o nospace
        else
            local path=""
            if [[ "$prefix" == */* ]]; then
                path="${prefix%/*}/"
            fi

            # echo "normalized path=$path" >> /tmp/aws_autocomplete_debug.log

            local folders=$(aws s3api list-objects-v2 \
                --bucket "$bucket" \
                --prefix "$path" \
                --delimiter '/' \
                --query 'CommonPrefixes[].Prefix' \
                --output text 2>>/tmp/aws_autocomplete_debug.log)

            local files=$(aws s3api list-objects-v2 \
                --bucket "$bucket" \
                --prefix "$path" \
                --delimiter '/' \
                --query 'Contents[].Key' \
                --output text 2>>/tmp/aws_autocomplete_debug.log)

            # echo "folders=$folders" >> /tmp/aws_autocomplete_debug.log
            # echo "files=$files" >> /tmp/aws_autocomplete_debug.log

            local all=$(echo -e "$folders\n$files" | sed '/^$/d' | sort -u)
            # echo "all=$all" >> /tmp/aws_autocomplete_debug.log

            # Poslednji segment koji korisnik kuca
            local cur_prefix="$prefix"
            # echo "cur_prefix=$cur_prefix" >> /tmp/aws_autocomplete_debug.log

            # Fetch all suggestions
            local suggestions=$(echo -e "$folders\n$files" | sed '/^$/d' | sort -u)
            # echo "suggestions=$suggestions" >> /tmp/aws_autocomplete_debug.log

            COMPREPLY=()
            for s in $suggestions; do
                [[ "$s" == "$cur_prefix"* ]] && COMPREPLY+=("${s}")
            done

            # echo "COMPREPLY=$COMPREPLY" >> /tmp/aws_autocomplete_debug.log

            local base="${cur%$cur_prefix}"
            # echo "base=$base" >> /tmp/aws_autocomplete_debug.log

            # Prefix results with the base
            for i in "${!COMPREPLY[@]}"; do
                COMPREPLY[$i]="${base}${COMPREPLY[$i]}"
            done

            # OVO SPREČAVA automatski razmak posle popune foldera sa /
            if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
                # Ako se završava sa '/', to je folder → NE dodaj razmak
                if [[ "${COMPREPLY[0]}" == */ ]]; then
                    compopt -o nospace
                fi
            fi
        fi

    else
        _filedir
    fi
}
