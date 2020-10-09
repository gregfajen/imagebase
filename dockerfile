# ================================
# Build image
# ================================
FROM swift:5.3-bionic as build
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./


RUN apt-get update && \
    apt-get install -y apt-utils dialog && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-add-repository -y ppa:strukturag/libheif
RUN apt-add-repository -y ppa:strukturag/libde265

RUN apt-get update && \
    apt-get install -y libde265-0=1.0.7-1~ppa1~ubuntu18.04.1 libheif1 libheif-dev libpng-dev libjpeg-dev libgif-dev libwebp-dev && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev libc6-dev \
  && rm -r /var/lib/apt/lists/*

RUN swift package resolve

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build --enable-test-discovery -c release

# ================================
# Run image
# ================================
FROM swift:5.3-bionic-slim

RUN apt-get update && \
    apt-get install -y apt-utils dialog && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-add-repository -y ppa:strukturag/libheif
RUN apt-add-repository -y ppa:strukturag/libde265

RUN apt-get update && \
    apt-get install -y libde265-0=1.0.7-1~ppa1~ubuntu18.04.1 libheif1 libheif-dev libpng-dev libjpeg-dev libgif-dev libwebp-dev && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev libc6-dev \
  && rm -r /var/lib/apt/lists/*


# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy build artifacts
COPY --from=build --chown=vapor:vapor /build/.build/release /app
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build --chown=vapor:vapor /build/Public /app/Public

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Start the Vapor service when the image is run, default to listening on 8080 in production environment 
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
