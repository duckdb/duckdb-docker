<!-- markdownlint-disable MD001 MD033 MD034 MD041 -->
# DuckDB CLI for Docker

Docker image of DuckDB

```shellsession
$ docker pull duckdb/duckdb:latest
```

  - [View Available Tags (DuckDB versions)](https://hub.docker.com/r/duckdb/duckdb/tags) @ DockerHub
- Supported Architecture:
  - Arm64 and AMD64

## Usage

### Pull the latest image

```shellsession
$ docker pull duckdb/duckdb:latest
```

### Specify the version to pull

```shellsession
$ docker pull duckdb/duckdb:1.4.0
```

- [Available versions](https://hub.docker.com/r/duckdb/duckdb/tags) @ hub.docker.com


### Interactive

Running `duckdb` command inside the container interactively.

```shellsession
$ docker run --rm -it -v "$(pwd):/workspace" -w /workspace duckdb/duckdb
DuckDB v1.4.0 (Andium) b8a06e4a22
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
D .open ./sample.db
D CREATE TABLE table_sample(timestamp TIMESTAMP, description TEXT);
D INSERT INTO table_sample VALUES(NOW(),'First sample data. Foo');
D INSERT INTO table_sample VALUES(NOW(),'Second sample data. Bar');
D FROM table_sample;
┌─────────────────────────┬─────────────────────────┐
│        timestamp        │       description       │
│        timestamp        │         varchar         │
├─────────────────────────┼─────────────────────────┤
│ 2025-09-15 12:17:00.387 │ First sample data. Foo  │
│ 2025-09-15 12:17:11.407 │ Second sample data. Bar │
└─────────────────────────┴─────────────────────────┘
D .quit
$ ls
sample.db
```

- Note that you need to mount the working directory as a volume to the container.

> [!TIP]
> For Windows users, use `%cd%` or `${PWD}` instead of `$(pwd)`.
>
> - `cmd.exe`: `docker run --rm -it -v "%cd%:/workspace" -w /workspace duckdb/duckdb`
> - `PowerShell`: `docker run --rm -it -v "${PWD}:/workspace" -w /workspace duckdb/duckdb `

### Command

- Running `duckdb --version` command:

```shellsession
$ docker run --rm duckdb/duckdb duckdb --version
v1.4.0 (Andium) b8a06e4a22
```

- Executing SQL query to the mounted database:

```shellsession
$ ls
sample.db
$ docker run --rm -it -v "$(pwd):/workspace" duckdb/duckdb duckdb /workspace/sample.db -header -column 'SELECT rowid, * FROM table_sample;'
rowid  timestamp                description            
-----  -----------------------  -----------------------
0      2025-09-15 12:17:00.387  First sample data. Foo 
1      2025-09-15 12:17:11.407  Second sample data. Bar
```

- Note that you need to mount the working directory as a volume to the container.

Note: This overview was adapted from the sqlite docker file: https://github.com/KEINOS/Dockerfile_of_SQLite3