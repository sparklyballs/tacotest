ARG UBUNTU_VER="focal"
FROM ubuntu:${UBUNTU_VER} as packages

# build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE

# environment variables
ENV \
	keys="generate" \
	harvester="false" \
	farmer="false" \
	plots_dir="/plots" \
	farmer_address="null" \
	farmer_port="null" \
	testnet="false" \
	full_node_port="null" \
	TZ="UTC"

# set workdir 
WORKDIR /taco-blockchain

# install dependencies
RUN \
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		bc \
		ca-certificates \
		curl \
		git \
		jq \
		lsb-release \
		sudo \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# build package
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/Taco-Network/taco-blockchain/commits/main" \
	| jq -r ".sha"); \
	RELEASE="${RELEASE:0:7}"; \
	fi \
	&& git clone https://github.com/Taco-Network/taco-blockchain.git \
		/taco-blockchain \		
	&& git checkout "${RELEASE}" \
	&& git submodule update --init \
	&& sh install.sh \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# add local files
COPY ./entrypoint.sh entrypoint.sh
ENTRYPOINT ["bash", "./entrypoint.sh"]