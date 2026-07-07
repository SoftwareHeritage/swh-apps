# -------------Stage 1 : Build -------------------

FROM python:3.11-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    make \
    gcc \
    g++ \
    build-essential \
    graphviz \
    plantuml \
    inkscape \
    crudini \
    myrepos \
    libapr1-dev \
    libaprutil1-dev \
    libsvn-dev \
    postgresql-client \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    tox \
    pre-commit \
    pifpaf

WORKDIR /workspace

# ------------- Clone docs-swh-repo -----------------------

RUN git clone --depth 1 https://gitlab.softwareheritage.org/swh/devel/swh-environment.git .

RUN crudini --del .mrconfig snippets || true && \
    crudini --del .mrconfig swh-py-template || true && \
    sed -i '/swh-docs/!s/git clone/git clone --single-branch/g' .mrconfig

# ------------- Cloning all necessarie module -------------------
RUN mr -j4 update

WORKDIR /workspace/swh-docs

RUN SKIP=mypy pre-commit run --all-files --show-diff-on-failure

# ----------- Doc generation ---------------------
RUN SPHINXOPTS="-W -T --jobs auto --keep-going -w errors.log" \
    SPHINXOPTCOLOR="--no-color" \
    tox -vv run -e sphinx-dev -x testenv:sphinx-dev.basepython=py311

# --------------- Stage 2 : Runtime ------------------

FROM nginx:alpine

COPY --from=builder /workspace/swh-docs/docs/_build/html/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]