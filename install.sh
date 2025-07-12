# 1. Prekopiraj fajl sa funkcijom
cp aws_s3_autocomplete_function.sh ~/.aws_s3_autocomplete_function.sh

# 2. Dodaj u .bashrc ako već nije
grep -qxF 'source ~/.aws_s3_autocomplete_function.sh' ~/.bashrc || \
echo 'source ~/.aws_s3_autocomplete_function.sh' >> ~/.bashrc

# 3. Aktiviraj autocomplete
echo 'complete -F _aws_s3_autocomplete aws' >> ~/.bashrc

# 4. Reload
source ~/.bashrc
