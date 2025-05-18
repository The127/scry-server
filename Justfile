build:
    nimble build --debugger:native --passc:-fsanitize=address --passl:-fsanitize=address --threads:off --gc:arc

run: build
    podman compose up -d
    ./main

release:
    nimble build -d:release --threads:off 

test:
    nimble test
