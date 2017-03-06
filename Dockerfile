FROM charliev5/alpineedge


ADD apk /tmp/apk
RUN cp /tmp/apk/-57cfc5fa.rsa.pub /etc/apk/keys

RUN apk --update --no-cache add xrdp xvfb alpine-desktop xfce4 thunar-volman \
faenza-icon-theme slim xf86-input-synaptics xf86-input-mouse xf86-input-keyboard \
setxkbmap sudo util-linux dbus wireshark ttf-freefont xauth supervisor busybox-suid openssl nano \ 
oracle-java7-installer software-properties-common bzip2 net-tools socat curl \
&& apk add /tmp/apk/ossp-uuid-1.6.2-r0.apk \
&& apk add /tmp/apk/ossp-uuid-dev-1.6.2-r0.apk \
&& apk add /tmp/apk/x11vnc-0.9.13-r0.apk \
&& rm -rf /tmp/* /var/cache/apk/*

# Install android sdk
RUN wget -qO- http://dl.google.com/android/android-sdk_r23-linux.tgz | \
    tar xvz -C /usr/local/ && \
    mv /usr/local/android-sdk-linux /usr/local/android-sdk && \
    chown -R root:root /usr/local/android-sdk/
    
# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# Install latest android tools and system images
RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
    platform-tool,android-19,android-21,android-22,build-tools-22.0.1,sys-img-x86-android-19,sys-img-x86-android-21,sys-img-x86-android-22,sys-img-armeabi-v7a-android-19,sys-img-armeabi-v7a-android-21,sys-img-armeabi-v7a-android-22 && \
    echo "y" | android update adb
    
# Create fake keymap file
RUN mkdir /usr/local/android-sdk/tools/keymaps && \
    touch /usr/local/android-sdk/tools/keymaps/en-us


ADD etc /etc

RUN xrdp-keygen xrdp auto
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini \
&& sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini

EXPOSE 3389 22 5037 5554 5555
#WORKDIR /home/alpine
#USER alpine xrdp
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
