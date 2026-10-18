# ---------- Build ----------
FROM python:3.14-bookworm AS builder

RUN apt-get update && apt-get install -y \
    git \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Node.js 22 installation
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y nodejs

WORKDIR /opt

RUN git clone https://gitlab.softwareheritage.org/swh/devel/swh-dataportal.git

WORKDIR /opt/swh-dataportal

RUN python -m venv dataportal

ENV PATH="/opt/swh-dataportal/dataportal/bin:$PATH"

RUN pip install --upgrade pip

# Requirement installation
RUN pip install -r requirements.txt

# Project installation
RUN pip install .

RUN npm install

# Makes purgecss available for the swh dataportal build
ENV PATH="/opt/swh-dataportal/node_modules/.bin:$PATH"

RUN swh dataportal build

# ---------- Runtime ----------
FROM nginx:alpine

COPY --from=builder /opt/swh-dataportal/output/html/ \
                    /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]