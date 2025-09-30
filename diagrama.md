```mermaid
flowchart LR
    SQL[(SQL Server / Source DB)]
    CONNECT[Kafka Connect\n(Sources & Sinks)]
    KAFKA[(Kafka Cluster)]
    SNOW[(Snowflake / Sink DB)]
    WATCHER[Watcher Script\n(Python/Go)]
    YAML[[replication-map.yaml]]

    SQL -->|Source Connector\n(Debezium/JDBC)| CONNECT
    CONNECT -->|Publica tópicos| KAFKA
    KAFKA -->|Consume tópicos| CONNECT
    CONNECT -->|Sink Connector\n(Snowflake/JDBC)| SNOW

    CONNECT -->|REST API / Configs| WATCHER
    WATCHER -->|gera| YAML
    YAML -->|usado por script\nvalidação| WATCHER
