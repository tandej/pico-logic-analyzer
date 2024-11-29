#! /bin/sh

echo "pre-commit hook: generating artifacts"

commitHashReplaceText="GITHASH"
gitHash=$(git rev-parse --short HEAD)
projectName="pico-logic-analyzer"

rm -rf export-duplicate/*
rm -rf generated/*

mkdir -p export-duplicate
mkdir -p generated/reports
mkdir -p generated/schematic
mkdir -p generated/gerbers

cp -r board/* export-duplicate/

cd export-duplicate

echo "generating schematic SVG(s)..."
kicad-cli sch export svg --output=../generated/schematic "$projectName".kicad_sch >> /dev/null

echo "generating ERC report..."
kicad-cli sch erc --output=../generated/reports/erc-report.txt "$projectName".kicad_sch >> /dev/null

echo "replacing git hash placeholder..."
sed -i -e "s/$commitHashReplaceText/$gitHash/" *.kicad_pcb

echo "generating step file..."
kicad-cli pcb export step --subst-models --output=../generated/"$projectName".step "$projectName".kicad_pcb >> /dev/null

echo "skipping generating board renders (pcbdraw does not work with kicad 8 as of writing)..."

echo "generating gerber files..."
kicad-cli pcb export gerbers --no-protel-ext --output=../generated/gerbers "$projectName".kicad_pcb >> /dev/null

echo "generating drill files..."
kicad-cli pcb export drill --output=../generated/gerbers "$projectName".kicad_pcb >> /dev/null

echo "zipping gerber and drill files..."
zip -rj ../generated/"$projectName"-gerbers.zip ../generated/gerbers >> /dev/null

echo "generating pos file..."
kicad-cli pcb export pos --exclude-dnp --output=../generated/"$projectName".pos "$projectName".kicad_pcb >> /dev/null

echo "generating bom file..."
kicad-cli sch export bom --exclude-dnp --output=../generated/"$projectName"-bom.csv "$projectName".kicad_sch >> /dev/null

echo "generating DRC report..."
kicad-cli pcb drc --output=../generated/reports/drc-report.txt "$projectName".kicad_pcb >> /dev/null

cd ..
git add .

echo "finished :D"