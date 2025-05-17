build:
    nimble build --debugger:native

run: build
    podman compose up -d
    ./main

release:
    nimble build -d:release 

test:
    nimble test
