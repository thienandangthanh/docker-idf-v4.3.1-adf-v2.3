FROM python:alpine3.15

ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
ARG IDF_CLONE_BRANCH_OR_TAG=master
ARG IDF_CHECKOUT_REF=v4.3.1

ARG ADF_CLONE_URL=https://github.com/espressif/esp-adf.git
ARG ADF_CLONE_BRANCH_OR_TAG=master
ARG ADF_CHECKOUT_REF=v2.3

ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp
ENV ADF_PATH=/opt/esp/adf

RUN apk add \
    bash \
    udev \
    bison \
    ca-certificates \
    ccache \
    check \
    curl \
    flex \
    git \
    gperf \
    gcc \
    gcompat \
    libffi-dev \
    libusb \
    musl-dev \
    make \
    ninja \
    unzip \
    wget \
    xz \
    zip \
    && apk fix
    # xz-utils \
    # libpython2.7 \
    # python3 \
    # python3-pip \
    # ninja-build \
    # lcov \
    # libncurses-dev \
    # libusb-1.0-0-dev \
RUN python -m pip install --upgrade pip virtualenv

RUN git clone\
      ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
      $IDF_CLONE_URL $IDF_PATH

RUN if [ -n "$IDF_CHECKOUT_REF" ]; then \
      cd $IDF_PATH && \
      git checkout $IDF_CHECKOUT_REF;\
    fi
RUN cd $IDF_PATH && git submodule update --init --recursive

# Install all the required tools, plus CMake
RUN $IDF_PATH/tools/idf_tools.py --non-interactive install required \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install cmake \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install-python-env \
  && rm -rf $IDF_TOOLS_PATH/dist

RUN $IDF_PATH/install.sh

RUN git clone\
      ${ADF_CLONE_BRANCH_OR_TAG:+-b $ADF_CLONE_BRANCH_OR_TAG} \
      $ADF_CLONE_URL $ADF_PATH

RUN if [ -n "$ADF_CHECKOUT_REF" ]; then \
      cd $ADF_PATH && \
      git checkout $ADF_CHECKOUT_REF;\
    fi
RUN cd $ADF_PATH && git submodule update --init --recursive

# Ccache is installed, enable it by default
ENV IDF_CCACHE_ENABLE=1
ENV LC_ALL=C.UTF-8

COPY entrypoint.sh /opt/esp/entrypoint.sh

RUN chmod a+x /opt/esp/*.sh && \
    chmod a+x /opt/esp/idf/*.sh

# Apply ESP-ADF sdcard lib bug
COPY ./sdcard.c /opt/esp/adf/components/esp_peripherals/lib/sdcard/sdcard.c

RUN echo "source /opt/esp/idf/export.sh" >> /root/.bashrc
ENTRYPOINT [ "/opt/esp/entrypoint.sh" ]
CMD [ "/bin/bash" ]
