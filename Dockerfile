FROM espressif/idf:v4.3.1

RUN apt-get update && apt-get upgrade -y
RUN apt-get install udev -y

ARG ADF_CLONE_URL=https://github.com/espressif/esp-adf.git
ARG ADF_CLONE_BRANCH_OR_TAG=master
ARG ADF_CHECKOUT_REF=v2.3

ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp
ENV ADF_PATH=/opt/esp/adf

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

COPY ./sdcard.c /opt/esp/adf/components/esp_peripherals/lib/sdcard/sdcard.c

# QEMU for ESP32
# RUN apt-get update && apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libgcrypt20-dev -y

# ARG QEMU_CLONE_URL=https://github.com/espressif/qemu
# ENV QEMU_PATH=/opt/qemu

# RUN git clone $QEMU_CLONE_URL $QEMU_PATH
# Configure & Build
# RUN cd $QEMU_PATH &&\
    # ./configure --target-list=xtensa-softmmu \
    # --enable-gcrypt \
    # --enable-debug --enable-sanitizers \
    # --disable-strip --disable-user \
    # --disable-capstone --disable-vnc \
    # --disable-sdl --disable-gtk &&\
    # ninja -C build

# Copy bin files to PATH
# RUN cp $QEMU_PATH/build/qemu-system-xtensa /usr/local/bin/
# RUN cp $QEMU_PATH/build/qemu-img /usr/local/bin/
# RUN cp $QEMU_PATH/build/qemu-edid /usr/local/bin/

RUN apt-get clean -y && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "source /opt/esp/idf/export.sh" >> /root/.bashrc
