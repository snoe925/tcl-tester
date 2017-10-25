FROM ubuntu

LABEL maintainer="Shannon Noe <snoe925@gmail.com>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="snoe925/tcl-tester" \
    org.label-schema.vcs-url="https://github.com/snoe925/tcl-tester.git" \
    org.label-schema.description="Ubuntu OS image with many public repository Tcl projects"

ENV DEBIAN_FRONTEND noninteractive

# Xenial does not have postgres 9.4 until 9.5 we have to add the Postgres site

COPY support/etc/apt/sources.list.d/pdgd.list /etc/apt/sources.list.d/pdgd.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils curl && \
    curl -o - 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' | apt-key add -

RUN apt-get install -y --allow-unauthenticated \
			apache2 \
			autoconf \
			automake \
			bmake \
			build-essential \
			clang \
			cmake \
			cronolog \			
			devscripts \
			emacs \
			fakeroot \
			g++ \
			gdal-bin \
			gdb \
			git \
			libapache2-mod-rivet \
			libboost-all-dev \
			libbsd-dev \
                        libcppunit-dev \
			libfribidi-dev \
			libgd-dev \
			libgdal-dev \
			libharfbuzz-dev \
			libproj-dev \
			libproj9 \
			libpq-dev \
			librdkafka-dev \
			libssl-dev \
			libuv1-dev \
			libyajl-dev \
			libzookeeper-mt-dev \
			libzookeeper-mt2 \
			llvm-4.0 \
			memcached \
			netcat \
			net-tools \
			openssl \
			pkgconf \
			postgresql-9.4 postgresql-client-9.4 \
			postgresql-contrib-9.4 \
			postgresql-server-dev-9.4 \
			postgresql-pltcl-9.4 \
			pgbouncer \
			proj-bin proj-data \
			psmisc \
			sqlite3 libsqlite3-mod-spatialite \
			swig \
			sysstat \
			telnet \
			vim \
			tcl8.6 \
			tcl8.6-dev \
			tk8.6-dev \
			tcl-thread \
			tcl-tclreadline \
			tcl-tls \
			tcl-trf \
			tcl-udp \
			tcl-vfs \
			tclcurl \
			tclgeoip \
			tclodbc \
			tclxml \
			tdom \
			tcl-tclex \
			tcl-memchan \
			tcl-combat \
			tcl-signal \
			tcl-sugar \
			libsqlite-tcl \
			mysqltcl \
			tcl8.6-tdbc \
			tcl8.6-tdbc-mysql \
			tcl8.6-tdbc-odbc \
			tcl8.6-tdbc-postgres \
			tcl8.6-tdbc-sqlite3 \
			itcl3 \
			critcl \
			xotcl \
			tclxapian \
			libtcl-chiark-1 \
			tclx8.4-dev

# Clone public repositories
RUN mkdir /root/git && \
	cd /root/git && git clone https://github.com/apache/zookeeper.git && \
	cd /root/git && git clone https://github.com/datastax/cpp-driver.git && \
	cd /root/git && git clone https://github.com/tcltk/tcllib.git && \
	cd /root/git && git clone https://github.com/sass/libsass.git && \
	cd /root/git && git clone https://github.com/dkfellows/llvmtcl

# Clone public FA repos
RUN mkdir -p /usr/local/flightaware/src && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/casstcl.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/kafkatcl.git && \
	cd /usr/local/flightaware/src && git clone -b fa-6-4 https://github.com/flightaware/mapserver.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/mdsplib.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/Pgtcl.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/scotty.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/speedbag.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/speedtables.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/tcl.gd.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/tclbsd.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/tcllauncher.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/yajl-tcl.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/nugget/zeitgit.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/zookeepertcl.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/socketservertcl.git && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/swift-tcl8.6 && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/swift-tcl && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/swift-tcl-demo && \
	cd /usr/local/flightaware/src && git clone https://github.com/flightaware/swift-tcl-extension-demo && \
	cd /usr/local/flightaware/src && git clone https://github.com/snoe925/tclsass.git

# The following repositories are downloaded, but not compiled or installed
# by this Dockerfile
#
# kafkatcl
# zookeeper
           
# Arrange for a decent tclreadline prompt in interactive mode
COPY support/tclshrc /root/.tclshrc
COPY support/inputrc /root/.inputrc
COPY support/bash_aliases /root/.bash_aliases
COPY support/vimrc /root/.vimrc

# Make sure code put into the special tcl volume can lazily be filled
# with packages 
ENV TCLLIBPATH /opt/tcl /opt/tcl/lib /usr/local/lib /usr/local/lib/x86_64-linux-gnu

RUN echo "**** tcllib" && cd /root/git/tcllib && \
	./configure --prefix=/usr/share/tcltk && \
	make install && \
	sed --in-place -e 's/tclsh8.5/tclsh/' /usr/bin/critcl && \
	make critcl && \
	rsync -a modules/tcllibc /usr/share/tcltk && \
	echo "**** cassandra cpp-driver (C driver)" && cd /root/git/cpp-driver && \
	mkdir build && cd build && cmake .. && make && make install && \
	ldconfig /usr/local/lib/x86_64-linux-gnu && \
	cd /root/git/llvmtcl && \
	mkdir -p config && autoreconf -iv && \
	./configure --with-llvm-config=/usr/lib/llvm-4.0/bin/llvm-config && \
	make && make install && \
	echo "**** Pgtcl" && cd /usr/local/flightaware/src/Pgtcl && \
	./configure && make && make install && \
	echo "**** casstcl" && cd /usr/local/flightaware/src/casstcl && \
	autoreconf && ./configure --libdir=/usr/local/lib/x86_64-linux-gnu && make && make install && \
	ldconfig /usr/local/lib/x86_64-linux-gnu && \
	echo "**** tclbsd" && cd /usr/local/flightaware/src/tclbsd && \
	autoreconf && ./configure && make && make install && \
	echo "**** yajl-tcl" && cd /usr/local/flightaware/src/yajl-tcl && \
	autoreconf && ./configure && make && make install && \
	echo "**** tcl.gd" && cd /usr/local/flightaware/src/tcl.gd && \
	autoreconf && ./configure && make && make install && \
	echo "zookeepertcl" && cd /usr/local/flightaware/src/zookeepertcl && \
	autoreconf && ./configure && make && make install && \
	echo "socketserver" && cd /usr/local/flightaware/src/socketservertcl && \
	autoreconf && ./configure && make && make install && \
	echo "**** tcllauncher & speedbag & speedtables" && cd /usr/local/flightaware/src/tcllauncher && \
	autoreconf && ./configure && make && make install && \
	cp /usr/bin/tcllauncher /usr/local/bin/ && \
	cd /usr/local/flightaware/src/speedbag && \
	autoreconf && ./configure && make && make install && \
	cd /usr/local/flightaware/src/speedtables && \
	autoreconf && ./configure && \
	cd ctables && \
	./configure --prefix=/usr --with-pgsql-include --with-pgtcl-lib --with-boost && \
	cd .. && make && make install

RUN echo "mdsplib" && cd /usr/local/flightaware/src/mdsplib && \
	make install && \
	ldconfig /usr/local/lib/x86_64-linux-gnu

RUN echo "**** scotty tnm" && cd /usr/local/flightaware/src/scotty/tnm && \
	autoreconf && ./configure && \
	make && make install && make sinstall

RUN echo "**** scotty tkined" && cd /usr/local/flightaware/src/scotty/tkined && \
	autoreconf && ./configure && \
	make && make install

RUN echo "**** mapserver" && cd /usr/local/flightaware/src/mapserver && \
	mkdir build && cd build && \
	cmake -DWITH_GD=1 -DUSE_THREAD=1 -DWITH_ICONV=0 -DWITH_FCGI=0 -DWITH_CAIRO=0 -DWITH_CURL=1 -DCMAKE_BUILD_TYPE=Release .. && \
	make && make install

ADD support/mapscript-tcl.patch /root/mapscript-tcl.patch

RUN echo "**** mapserver/mapscript/tcl" && cd /usr/local/flightaware/src/mapserver/mapscript/tcl && \
	patch CMakeLists.txt </root/mapscript-tcl.patch && \
	mkdir build && cd build && cmake .. && make && make install

ADD support/mapscript-tclplug.patch /root/mapscript-tclplug.patch

RUN echo "**** mapserver/mapscript/tclplug" && cd /usr/local/flightaware/src/mapserver/mapscript/tclplug && \
	patch CMakeLists.txt </root/mapscript-tclplug.patch && \
	mkdir build && cd build && cmake .. && make && make install

RUN echo "**** libsass" && \
	cd /root/git/libsass && \
	git checkout -b 3.4.4 && \
	autoreconf --force --install && \
	./configure --disable-tests && \
	make && make install && \
	ldconfig /usr/local/lib/libsass.so && \
	cd /usr/local/flightaware/src/tclsass && \
	autoreconf && ./configure && \
	make && make install

RUN mkdir -p /root/Downloads && cd /root/Downloads && \
    curl -o fossil-src-2.3.tar.gz -L 'https://www.fossil-scm.org/index.html/uv/fossil-src-2.3.tar.gz' && \
    mkdir -p /root/src && cd /root/src && tar -xvzf /root/Downloads/fossil-src-2.3.tar.gz && \
    cd fossil* && ./configure && make && make install

CMD ["/bin/bash"]
