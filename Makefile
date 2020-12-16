hadoop:
	docker stack deploy -c ./docker-compose.yml hadoop

ps:
	watch -n 1 docker stack ps hadoop

rm:
	docker stack rm hadoop

bash:
	docker exec -it $(NAMENODE) bash

NAMENODE := $(shell docker ps -a --format "{{.Names}}" | grep namenode)
APP := wc.jar
wc:
	docker cp $(APP) $(NAMENODE):/tmp/$(APP)
	docker exec -it $(NAMENODE) bash -c '\
		hdfs dfs -mkdir -p /input/;\
		hdfs dfs -copyFromLocal -f /opt/hadoop-3.2.1/README.txt /input/;\
		hdfs dfs -rm -f -r /output/; \
		$$HADOOP_HOME/bin/hadoop jar /tmp/$(APP) WordCount /input /output;\
	'
