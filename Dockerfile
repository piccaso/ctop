FROM golang:1.23 AS builder
RUN apt-get update && apt-get install -y wget xz-utils make
RUN cd /usr/local/bin && wget -O- https://github.com/upx/upx/releases/download/v4.2.4/upx-4.2.4-amd64_linux.tar.xz | tar -Jxvf- --strip-components=1 upx-4.2.4-amd64_linux/upx

WORKDIR /app
COPY go.mod .
RUN go mod download

COPY . .
RUN make build && \
    mkdir -p /go/bin && \
    mv -v ctop /go/bin/

RUN upx --best --lzma /go/bin/ctop

FROM scratch
ENV TERM=linux
COPY --from=builder /go/bin/ctop /ctop
ENTRYPOINT ["/ctop"]
