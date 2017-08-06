# This dockerfile is used for configuring the Swift server side program to serve the requests from Mobile Edge Cloud applications

FROM dawan/mc-cloudlet

MAINTAINER Dawand Sulaiman version:0.1

# This is where the Swift code is kept
WORKDIR /MEC-Container

# build the swift project
RUN swift build --configuration release

# Expose this port
EXPOSE 8080

# Run the application
ENTRYPOINT [".build/debug/Run"]
