#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/4] Copying autocomplete function file...${NC}"
if cp .aws_s3_autocomplete_function.sh ~/.aws_s3_autocomplete_function.sh; then
    echo -e "${GREEN}✔ File copied successfully.${NC}"
else
    echo -e "${RED}✘ Failed to copy the function file. Make sure it exists.${NC}"
    exit 1
fi

echo -e "${GREEN}[2/4] Adding source to .bashrc if missing...${NC}"
if grep -qFx "source ~/.aws_s3_autocomplete_function.sh" ~/.bashrc; then
    echo -e "${GREEN}✔ Already added to .bashrc.${NC}"
else
    echo "source ~/.aws_s3_autocomplete_function.sh" >> ~/.bashrc
    echo -e "${GREEN}✔ Added to .bashrc.${NC}"
fi

echo -e "${GREEN}[3/4] Registering the autocomplete function...${NC}"
if grep -qFx "complete -F _aws_s3_autocomplete aws" ~/.bashrc; then
    echo -e "${GREEN}✔ Autocomplete already registered.${NC}"
else
    echo "complete -F _aws_s3_autocomplete aws" >> ~/.bashrc
    echo -e "${GREEN}✔ Autocomplete function registered.${NC}"
fi

echo -e "${GREEN}[4/4] Reloading shell config...${NC}"
source ~/.bashrc && echo -e "${GREEN}✔ Installation complete. Try typing: aws s3 cp s3://<TAB>${NC}" || \
echo -e "${RED}✘ Failed to reload shell config. Please restart terminal manually.${NC}"
