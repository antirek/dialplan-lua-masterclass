FROM antirek/asterisk13-lua

## g729

# RUN cp /usr/codecs/codec_g729-ast130-gcc4-glibc-x86_64-opteron-sse3.so /usr/lib/asterisk/modules/codec_g729.so


ADD after_start.sh /after_start.sh

RUN chmod +x /after_start.sh

CMD ["/after_start.sh"]