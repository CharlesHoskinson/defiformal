audit_file="$RUNNER_TEMP/DefiKernelCIAudit.lean"
trap 'rm -f "$audit_file"' EXIT
printf '%s\n' 'import DefiKernel' '#audit_axioms DefiKernel' > "$audit_file"
lake env lean "$audit_file"

