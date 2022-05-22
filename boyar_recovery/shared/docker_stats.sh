echo "stage 0"
OUTPUT="NOT_SET"
set -u # trigger errors for unset vars
#---------------------------------------------------------------------------
echo "stage docker-stats"
OUTPUT=""
if command -v docker &> /dev/null; then
    OUTPUT=$(docker stats 2>&1 || true)
    OUTPUT=${OUTPUT:0:4096}
else
    echo "docker could not be found"
fi
echo $OUTPUT
if command -v curl &> /dev/null; then
    curl -XPOST -H "Content-Type: application/json" "http://logs.orbs.network:3001/putes/boyar-recovery" -d '{ "node": "'"$NODE_NAME"'", "script":"docker_stats.sh", "stage":"docker-stats","output": "'"$OUTPUT"'" }'
fi
