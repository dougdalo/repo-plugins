flowchart LR
  SQL[(SQL Server / Source DB)]
  CONNECT[Kafka Connect<br/>Sources and Sinks]
  KAFKA[(Kafka Cluster)]
  SNOW[(Snowflake / Sink DB)]
  WATCHER[Watcher Script<br/>(Python or Go)]
  YAML[[replication-map.yaml]]

  SQL -->|Source Connector (Debezium/JDBC)| CONNECT
  CONNECT -->|Publica tópicos| KAFKA
  KAFKA -->|Consume tópicos| CONNECT
  CONNECT -->|Sink Connector (Snowflake/JDBC)| SNOW

  CONNECT -->|REST API / Configs| WATCHER
  WATCHER -->|gera| YAML
  YAML -.->|usado pelo script de validação| WATCHER
