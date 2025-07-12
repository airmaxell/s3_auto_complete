#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/5] Copying autocomplete function file...${NC}"
if cp aws_s3_autocomplete_function.sh ~/.aws_s3_autocomplete_function.sh; then
    echo -e "${GREEN}✔ File copied successfully.${NC}"
else
    echo -e "${RED}✘ Failed to copy the function file. Make sure it exists.${NC}"
    exit 1
fi

echo -e "${GREEN}[2/5] Adding source to .bashrc if missing...${NC}"
if ! grep -Fxq "source ~/.aws_s3_autocomplete_function.sh" ~/.bashrc; then
    echo "source ~/.aws_s3_autocomplete_function.sh" >> ~/.bashrc
    echo -e "${GREEN}✔ Added source command to .bashrc.${NC}"
else
    echo -e "${GREEN}✔ Source already present in .bashrc.${NC}"
fi

echo -e "${GREEN}[3/5] Registering the autocomplete function...${NC}"
if ! grep -Fxq "complete -F _aws_s3_autocomplete aws" ~/.bashrc; then
    echo "complete -F _aws_s3_autocomplete aws" >> ~/.bashrc
    echo -e "${GREEN}✔ Autocomplete function registered.${NC}"
else
    echo -e "${GREEN}✔ Autocomplete already registered in .bashrc.${NC}"
fi

echo -e "${GREEN}[4/5] Updating COMP_WORDBREAKS...${NC}"
if ! grep -q "COMP_WORDBREAKS=" ~/.bashrc; then
    echo 'COMP_WORDBREAKS=${COMP_WORDBREAKS//:}' >> ~/.bashrc
    echo 'COMP_WORDBREAKS=${COMP_WORDBREAKS//\/}' >> ~/.bashrc
    echo 'export COMP_WORDBREAKS' >> ~/.bashrc
    echo -e "${GREEN}✔ COMP_WORDBREAKS updated in .bashrc.${NC}"
else
    echo -e "${GREEN}✔ COMP_WORDBREAKS already handled in .bashrc.${NC}"
fi

echo -e "${GREEN}[5/5] Reloading .bashrc...${NC}"
source ~/.bashrc && \
echo -e "${GREEN}✔ Installation complete. You can now try: aws s3 cp s3://<TAB>${NC}" || \
echo -e "${RED}✘ Reload failed. Please restart your terminal manually.${NC}"
