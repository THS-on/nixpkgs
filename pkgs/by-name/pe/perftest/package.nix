{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cudaPackages,
  pkg-config,
  rdma-core,
  pciutils,
  autoAddDriverRunpath
}:

let
  version = "26.01.5";
in
stdenv.mkDerivation {
  pname = "perftest";
  inherit version;

  src = fetchFromGitHub {
    owner = "linux-rdma";
    repo = "perftest";
    rev = "perftest-${version}";
    hash = "sha256-WcFOaG5Lzn87EZCZ8w6UTI6qtfX1wOtvF/lxSDwjEq4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    autoAddDriverRunpath
  ];

  buildInputs = [
    rdma-core
    pciutils
    # They derive various cuda paths from the relative to the header include dir. 
    # Instead of patching the project to make this work, just use the legacy package for now
    cudaPackages.cudatoolkit
  ];

  configureFlags = [
    "--enable-cudart"
  ];

  env.CUDA_H_PATH = "${lib.getDev cudaPackages.cudatoolkit}/include/cuda.h";

  meta = {
    description = "InfiniBand verbs performance tests";
    homepage = "https://github.com/linux-rdma/perftest";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ths-on ];
    platforms = lib.platforms.linux;
  };
}
