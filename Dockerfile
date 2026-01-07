# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install git for fetching dependencies
RUN apk add --no-cache git ca-certificates

# Copy source code and go mod files
COPY . .

# Download and tidy dependencies
RUN go mod tidy && go mod download

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o mcp-nutanix .

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Install ca-certificates for HTTPS connections to Nutanix
RUN apk add --no-cache ca-certificates

# Copy the binary from builder
COPY --from=builder /app/mcp-nutanix /app/mcp-nutanix

# Default environment variables
ENV MCP_TRANSPORT=http
ENV MCP_PORT=8080
ENV MCP_ENDPOINT=/mcp

# Expose the HTTP port
EXPOSE 8080

# Run the server
CMD ["/app/mcp-nutanix"]
