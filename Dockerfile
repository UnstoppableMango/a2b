# syntax=docker/dockerfile:1
FROM --platform=${BUILDPLATFORM} golang:1.25 AS build
ARG TARGETOS
ARG TARGETARCH

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd
COPY ./pkg ./pkg

FROM build AS openapi2ts
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -C cmd/openapi2ts -o /out/openapi2ts

FROM scratch AS final
COPY --from=openapi2ts /out/openapi2ts /usr/bin/openapi2ts
