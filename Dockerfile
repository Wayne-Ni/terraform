# Multi-stage build using pre-built Go binary
FROM alpine:3.20

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy the pre-built Go binary from the build job
COPY app .

# Make the binary executable
RUN chmod +x app

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./app"] 