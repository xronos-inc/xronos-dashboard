ARG BASEIMAGE=xronosinc/lf-trace-plugin-api:py
FROM ${BASEIMAGE}

WORKDIR /lingua-franca

# python requirements
COPY src/requirements.txt /lingua-franca/
RUN pip install --no-warn-script-location \
    --no-warn-script-location \
    --no-cache-dir \
    -r requirements.txt

STOPSIGNAL SIGINT
ENTRYPOINT ["python", "-u"]
