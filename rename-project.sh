baseName="kicad-project-template"

sed -i -s -e "s/$baseName/${1}/" $baseName.kicad_pcb $baseName.kicad_sch $baseName.kicad_pro README.md .github/workflows/generate-artifacts.yml
mv $baseName.kicad_pro ${1}.kicad_pro
mv $baseName.kicad_pcb ${1}.kicad_pcb
mv $baseName.kicad_sch ${1}.kicad_sch
