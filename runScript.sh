source "$(cd "$(dirname $BASH_SOURCE[0])"; pwd -P)"/main.sh
cd "$C2BASH_HOME"
source "$C2BASH_HOME"/helperlibs/include.sh
source "$C2BASH_HOME"/helperlibs/return.sh
# include "$C2BASH_HOME"/helperlibs/assert.sh
include "$C2BASH_HOME"/helperlibs/io.sh
export __DEBUG=0
source "$@"
