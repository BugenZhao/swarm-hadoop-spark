%.deploy:
	docker stack deploy -c ./docker-compose-$*.yml $*

%.ps:
	watch -n 1 docker stack ps $*

%.rm:
	docker stack rm $*

INPUT := ./data/London2013.csv

HADOOP_NAMENODE := $(shell docker ps -a --format "{{.Names}}" | grep namenode)
HADOOP_APP := ss_hadoop.jar

hadoop.bash:
	docker exec -it $(HADOOP_NAMENODE) bash

hadoop.run:
	docker cp $(HADOOP_APP) $(HADOOP_NAMENODE):/tmp/$(HADOOP_APP)
	docker cp $(INPUT) $(HADOOP_NAMENODE):/tmp/input.txt
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		hdfs dfs -copyFromLocal -f /tmp/input.txt /input.txt;\
		hdfs dfs -rm -f -r /output;\
	'
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		ls /tmp/$(HADOOP_APP) -al;\
		$$HADOOP_HOME/bin/hadoop jar /tmp/$(HADOOP_APP) /input.txt /output;\
	'
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		rm -rf /tmp/output/;\
		hdfs dfs -copyToLocal /output/ /tmp/output;\
		head -n 10 /tmp/output/*;\
	'


SPARK_MASTER := $(shell docker ps -a --format "{{.Names}}" | grep master)
SPARK_APP := ss_spark.jar
HDFS := hdfs://namenode:9000

spark.bash:
	docker exec -it $(SPARK_MASTER) bash

spark.run:
	docker cp $(SPARK_APP) $(SPARK_MASTER):/tmp/$(SPARK_APP)
	docker cp $(INPUT) $(HADOOP_NAMENODE):/tmp/input.txt
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		hdfs dfs -copyFromLocal -f /tmp/input.txt /input.txt;\
		hdfs dfs -rm -f -r /output;\
	'
	docker exec -it $(SPARK_MASTER) bash -c '\
		ls /tmp/$(SPARK_APP) -al;\
		/spark/bin/spark-submit /tmp/$(SPARK_APP) $(HDFS)/input.txt $(HDFS)/output;\
	'
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		rm -rf /tmp/output/;\
		hdfs dfs -copyToLocal /output/ /tmp/output;\
		head -n 10 /tmp/output/*;\
	'
