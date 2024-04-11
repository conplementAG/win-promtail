# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS servercore

SHELL ["powershell"]

ARG PROMTAIL_VERSION
ARG PROMTAIL_SHA256

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri "https://github.com/grafana/loki/releases/download/$($env:PROMTAIL_VERSION)/promtail-windows-amd64.exe.zip" -OutFile promtail.zip -UseBasicParsing; `
    if ((Get-FileHash promtail.zip -Algorithm sha256).Hash.ToLower() -ne $env:PROMTAIL_SHA256) {exit 1}; `
    Expand-Archive promtail.zip -DestinationPath C:\promtail; `
    Remove-Item promtail.zip


FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

COPY --from=servercore /promtail /promtail


WORKDIR C:\promtail
CMD ["promtail-windows-amd64.exe"]