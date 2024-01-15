FROM savonet/liquidsoap:v1.4.4
COPY scripts scripts
COPY sampleMusic music
EXPOSE 8001
EXPOSE 8002
CMD  ["scripts/main.liq"]
