FROM ubuntu

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes \
	vim \
	curl \
	git \
	ctags \
	wget \
	openssh-server \
	libc6-dev \
	autoconf \
	bison \
	cpp \
	gawk \
	gettext \
	libncurses5-dev \
	libbz2-dev \
	libreadline-dev \
	gcc \
	g++ \
	build-essential \
	make \
	automake \
	man-db \
	lxc \
	tmux
    
RUN curl -s http://go.googlecode.com/files/go1.2.linux-amd64.tar.gz | tar -v -C /usr/local -xz

RUN wget http://fishshell.com/files/2.1.0/fish-2.1.0.tar.gz && tar -zxf fish-2.1.0.tar.gz &&\
	cd fish-2.1.0/ && ./configure --prefix=/usr/local && make && make install &&\
	echo '/usr/local/bin/fish' | tee -a /etc/shells && chsh -s /usr/local/bin/fish &&\
	cd && rm -rf fish-2.1.0 && rm fish-2.1.0.tar.gz

RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && chmod +x /usr/local/bin/docker
VOLUME ["/var/lib/docker"]

# The point of no return, don't add shit below
ADD . /root/.dotfiles
RUN ln -s /root/.dotfiles/vim /root/.vim && ln -s /root/.dotfiles/vimrc /root/.vimrc
RUN mkdir -p /root/.config/fish && ln -s /root/.dotfiles/config.fish /root/.config/fish/config.fish
RUN ln -s /root/.dotfiles/tmux.conf /root/.tmux.conf

CMD \
	ssh-keygen -f /root/.ssh/id_rsa -N "" >/dev/null &&\
	cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys &&\
	mkdir /var/run/sshd &&\
	/usr/sbin/sshd &&\
	sleep 1 &&\
	ssh-keyscan localhost > /root/.ssh/known_hosts 2>/dev/null &&\
	ssh -t localhost tmux
