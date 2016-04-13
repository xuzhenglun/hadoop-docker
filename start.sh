n=$1
((n--))

for i in $(seq 0 $n)
do
    docker run -d --name slave$i -h slave$i xuzhenglun/hadoop-docker-real  /etc/bootstrap.sh -slave $1
    linker="$linker"" --link slave$i:slave$i"
    sleep 1
done

sleep 5
docker run -p 8088:8088 -p 50070:50070 -itdP --name master $linker -h master xuzhenglun/hadoop-docker-real /etc/bootstrap.sh -master $1
