FROM dawan/mc-cloudlet
WORKDIR /MEC-Container
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/debug/Run"]
