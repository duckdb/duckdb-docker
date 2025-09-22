FROM gcr.io/distroless/cc-debian12
ARG TARGETPLATFORM
ARG TARGETARCH
COPY duckdb_$TARGETARCH /duckdb
CMD ["/duckdb"]
ENV PATH="$PATH:/"
