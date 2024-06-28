ARG BASEIMAGE=python:3.10-slim
FROM ${BASEIMAGE}

# install gcc and make
RUN apt update  \
    && apt install --no-install-recommends -y -q \
        build-essential \
    && apt autoremove -y -q \
    && apt clean -y -q

# pip install cmake
ENV PYTHONDONTWRITEBYTECODE=1
RUN pip install cmake

WORKDIR /lingua-franca

# python requirements
COPY src/requirements.txt /lingua-franca/
RUN pip install --no-warn-script-location \
    --no-warn-script-location \
    --no-cache-dir \
    -r requirements.txt

STOPSIGNAL SIGINT
ENTRYPOINT ["python", "-u"]
