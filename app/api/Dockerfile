# Build
FROM golang:1.23 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /api ./cmd/api

# Run
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /api /app/api
EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["/app/api"]
