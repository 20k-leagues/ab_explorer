#!/usr/bin/env bash
#
# https://github.com/20k-leagues/ab_explorer

####################################################
####################################################
#
#  variables
#

export TS=`date +%Y_%m%d_%H%M%S`
export API_PLATFORM=https://api.artblocks.io/platform 
export API_PROJECT=https://api.artblocks.io/project/ 
export API_TOKEN_DATA=https://api.artblocks.io/token/ 
export API_TOKEN_IMAGE=https://api.artblocks.io/image/ 
export API_TOKEN_LIVE=https://api.artblocks.io/generator/ 
export API_TOKEN_VOX=https://api.artblocks.io/vox/ 


####################################################
####################################################
#
#  define yer functions
#


####################################################
#  greetings message

greetings_msg () {
 clear
 echo ""
 echo -e "\t greetings earthling!"
 echo ""
 echo -e "\t               .--.   |V| "
 echo -e "\t              /    \ _| / "
 echo -e "\t              q .. p \ /  "
 echo -e "\t               \--/  //   "
 echo -e "\t         jgs  __||__//    "
 echo -e "\t             /.    _/     "
 echo -e "\t            // \  /       "
 echo -e "\t           //   ||        "
 echo -e "\t           \\  /  \       "
 echo -e "\t            )\|    |      "
 echo -e "\t           / || || |      "
 echo -e "\t           |/\| || |      "
 echo -e "\t              | || |      "
 echo -e "\t              \ || /      "
 echo -e "\t            __/ || \__    "
 echo -e "\t           \____/\____/   "
 echo ""
 echo ""
 echo -e "\t let's get this block party started..."
 echo ""
 sleep 3 
 }

####################################################
#  get updated project level metadata

get_project_list () {
 echo ""
 curl -s $API_PLATFORM |xmllint --format - |grep List |awk '{print $3}' |awk -F\< '{print $1}' |sed 's/,/ /g' > project_list.tmp
 export PROJECT_IDS=`cat ./project_list.tmp`
 for x in $PROJECT_IDS
  do
   echo '  grabbing the latestet metadata from '$API_PROJECT$x 
   curl -s $API_PROJECT$x > project_$x.xml
   sleep 2
  done
 }

####################################################
#  parse project states & print out a summary 
#
#   a = project id
#   b = project name (replace special characters)
#   c = artist name (replace special characters)
#   d = hash per token
#   e = dynamic
#   f = mint price
#   g = currency
#   h = qty minted
#   i = mint max
#   j = paused?
#   k = active?
#   l = ab URL
#   m = % minted
#   n = tkn id start
#   o = tkn id end
 
parse_project_states () {
 echo ""
 echo -e ",----,--------------------------,---------------------,--------,-----,----------,--------,--------,--------,----------,----------,-------------------------------------, ," > ./parse_project_states.tmp
 echo -e ", id , project name , artist , price , cur , mint max , minted , % sold , active , 1st tkn , last tkn , art blocks project url , ," >> ./parse_project_states.tmp
 echo -e ",----,--------------------------,---------------------,--------,-----,----------,--------,--------,--------,----------,----------,-------------------------------------, ," >> ./parse_project_states.tmp
  for x in `ls project_*.xml |sort -V`
   do 
    echo "  parsing $x..."
    export xml=`xmllint --format $x ` 
    export a=`echo $x |sed 's/project_//g' |sed 's/.xml//g'`
    export b=`xmllint --format $x |grep h1.*Name |awk -F\: '{print $2}' |awk -F\< '{print $1}' |awk '{$1=$1};1' |sed 's/&#x14D;/o/g'|sed 's/&#x266B;//g' |awk '{$1=$1};1' `
    export c=`xmllint --format $x |grep h3.*Artist |awk -F\: '{print $2}' |awk -F\< '{print $1}' |awk '{$1=$1};1' |sed 's/&#xEF;/i/g' |sed 's/&#xF6;/o/g' |sed 's/&#xE9;/e/g' `
#   export d=`xmllint --format $x |grep Hashes.*Generated |awk '{print $5}' |sed 's/<\/p>//g' `
#   export e=`xmllint --format $x |grep Dynamic.*Asset |awk '{print $3}' |sed 's/<\/p>//g' `
    export f=`xmllint --format $x |grep Price |awk '{print $2}' |sed 's/<\/p>//g' `
    export g=`xmllint --format $x |grep Currency: |awk '{print $2}' |sed 's/<\/p>//g' `
    export h=`xmllint --format $x |grep '>Invocations:' |awk '{print $2}' |sed 's/<\/p>//g' `
    export i=`xmllint --format $x |grep ' Invocations:' |awk '{print $3}' |sed 's/<\/p>//g' `
#   export j=`xmllint --format $x |grep 'Paused?' |awk '{print $2}' |sed 's/<\/p>//g' `
    export k=`xmllint --format $x |grep 'Active?' |awk '{print $2}' |sed 's/<\/p>//g' `
    export l=`echo "https://www.artblocks.io/project/$a" `
    for mm in `seq 0 1000`; do mint_done=$((200*$h/$i % 2 + 100*$h/$i)); done; export m=`echo $mint_done"%"`
    export n=`xmllint --format $x |grep ' Ids:' |awk '{print $3}' |sed 's/<\/p>//g' |awk -F\, '{print $1}' `
    export o=$(($n+$h-1)) 
    echo -e ", $a , $b , $c , $f , $g , $i , $h , $m , $k , $n , $o , $l , $p , ," >> ./parse_project_states.tmp
   done
 echo -e ",----,--------------------------,---------------------,--------,-----,----------,--------,--------,--------,----------,----------,-------------------------------------, ," >> ./parse_project_states.tmp
 clear
 echo ""
 column -t -s "," parse_project_states.tmp |sed 's/^/   / ' > parse_project_states_$TS.log
#column -t -s "," -o "|" parse_project_states.tmp |sed 's/^/   / ' > parse_project_states_$TS.log
 cat parse_project_states_$TS.log
 sleep 3
 echo ""
 }


####################################################
# closing message 

goodbye_msg () {
 echo ""
 echo -e "\t i love you,"
 echo ""
 echo -e "\t\t 0x75fda6bfac282634323be70bb27a2c0839082ac5"
 echo ""
 }


####################################################
####################################################
#
#  here we go... 
#

greetings_msg
get_project_list
parse_project_states
goodbye_msg


