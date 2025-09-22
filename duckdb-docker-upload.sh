#!/bin/bash

# TODO is this required?
# docker buildx create --name duckdb_builder
# docker buildx use duckdb_builder

cat > Dockerfile <<- EOM
FROM gcr.io/distroless/cc-debian12
ARG TARGETPLATFORM
ARG TARGETARCH
COPY duckdb_\$TARGETARCH /duckdb
CMD ["/duckdb"]
ENV PATH="\$PATH:/"
EOM

PKG=duckdb/duckdb

# clean up existing images
for IMAGE in `docker image ls $PKG -q` 
do
	echo "Deleting cached image $IMAGE"
	docker image rm $IMAGE
done

# find all the to-be-deployed versions
VERSIONS=`duckdb -csv -noheader -c "FROM 'https://duckdb.org/data/duckdb-releases.csv' SELECT version_number WHERE version_number[1] <> '0' ORDER BY release_date"`

for VER in $VERSIONS
do
	echo $VER
	rm -f duckdb_*

	ARMARCH=arm64
	# special handling for older versions, we had a different file name for arm
	if echo $VER | grep -q -e '1.2.' -e '1.1.' -e '1.0.'; then
	   	ARMARCH=aarch64
	fi

	curl -s -L -o duckdb_cli-linux-amd64.zip "https://github.com/duckdb/duckdb/releases/download/v$VER/duckdb_cli-linux-amd64.zip"
	curl -s -L -o duckdb_cli-linux-arm64.zip "https://github.com/duckdb/duckdb/releases/download/v$VER/duckdb_cli-linux-$ARMARCH.zip"

	unzip -p duckdb_cli-linux-amd64.zip duckdb > duckdb_amd64
	unzip -p duckdb_cli-linux-arm64.zip duckdb > duckdb_arm64

	chmod +x duckdb_*

	docker buildx build --platform linux/amd64,linux/arm64 -t $PKG:$VER --push .

	# # check if version exists and works
	REPORTED_VER=`docker run --rm $PKG:$VER duckdb -csv -noheader -c "SELECT version()"`
	if [ $REPORTED_VER != "v$VER" ] 
	then
		echo "Failed version check for $VER"
		exit 1
	fi

	LATEST_VER=$(curl -s https://duckdb.org/data/latest_stable_version.txt)
	if [ $VER == $LATEST_VER ]
	then
		echo "Setting $VER as latest"
		docker buildx build --platform linux/amd64,linux/arm64 -t $PKG:latest --push . 
	fi
done
