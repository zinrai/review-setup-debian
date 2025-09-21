# Dockerfile for Re:VIEW Japanese technical writing environment
FROM debian:trixie

# Install sudo required by setup script
RUN apt-get update && apt-get install -y sudo

# Create application directory
RUN mkdir -p /opt/review

# Copy setup script and Ruby dependencies
COPY review-setup-debian.sh /opt/review/
COPY Gemfile /opt/review/
COPY Gemfile.lock /opt/review/

# Setup Re:VIEW environment
WORKDIR /opt/review
RUN ./review-setup-debian.sh system-setup

# Set working directory for user projects
WORKDIR /work

# Set entrypoint to use Re:VIEW
ENTRYPOINT ["bundle", "exec", "--gemfile=/opt/review/Gemfile"]
CMD ["rake", "--help"]
