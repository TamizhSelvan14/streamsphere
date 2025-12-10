# Build
FROM golang:1.22 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /worker ./cmd/worker

# Run
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /worker /app/worker
ENTRYPOINT ["/app/worker"]
