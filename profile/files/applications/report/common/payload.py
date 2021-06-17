payload = {'ip': get_ipaddress(),
           'name': socket.gethostname(),
           'uptime': get_uptime(),
           'kernel': ' '.join(os.uname()),
           'md5sum': checksum_file(__file__) }

