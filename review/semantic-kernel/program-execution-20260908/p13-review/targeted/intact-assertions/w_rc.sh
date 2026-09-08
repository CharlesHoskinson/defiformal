declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=7
fail=0; blkd=0
. "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p13-review/targeted/intact-assertions/attrib/fns.sh"
want "died but printed the needle" 'pairs: 1830' pairs
