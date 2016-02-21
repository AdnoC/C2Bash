if [ ${BASH_VERSINFO[0]} -lt 4 ] || [ ${BASH_VERSINFO[1]} -lt 4 ]; then
  echo "This project requires at least bash version 4.4"
  exit 1
fi

C2BASH_HOME="$(cd "$(dirname $BASH_SOURCE[0])"; pwd -P)"

# For debug purposes:
export C2BASH_HOME
