build:
    nimble build

run: build
    podman compose up -d
    ./main

test:
    nimble test
