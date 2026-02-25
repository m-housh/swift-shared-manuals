docker_image := "swift-shared-manuals"
docker_tag := "latest"

[private]
default:
	@just --list

clean:
	rm -rf .build

run-dev:
	@swift run --package-path dev-server dev-server serve --port 8088 --log debug

build-docker file="docker/Dockerfile":
	@docker build -f {{file}} -t {{docker_image}}:{{docker_tag}} .

run-docker:
	@docker run -it --rm -v $PWD:/app -p 8080:8080 {{docker_image}}:{{docker_tag}}

test-docker: (build-docker "docker/Dockerfile.test")
	@docker run --rm {{docker_image}}:{{docker_tag}} swift test

code-coverage:
	@llvm-cov report \
		"$(find $(swift build --show-bin-path) -name '*.xctest')" \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" \
		-use-color

test *ARGS:
	@swift test --enable-code-coverage {{ARGS}}
