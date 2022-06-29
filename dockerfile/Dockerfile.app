ARG APP_NAME=myorders
ARG APP_PATH=/app

#
# initial
#
FROM python:3.10.5-slim-bullseye as initial
ARG APP_NAME
ARG APP_PATH
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.1.13 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=true
# install poetry and update PATH
RUN apt update \
    && apt install --no-install-recommends -y \
    curl \
    git \
    # for mysqlclient
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    # for django-extensions graph_models
    libgraphviz-dev \
    graphviz \
    pkg-config
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="${POETRY_HOME}/bin:$PATH"
# import project files
WORKDIR ${APP_PATH}

#
# development
#
FROM initial as development
ARG APP_NAME
ARG APP_PATH
# install dependencies
WORKDIR ${APP_PATH}/${APP_NAME}
COPY ./myorders/poetry.lock ./myorders/pyproject.toml ./
RUN poetry install --no-interaction
ENTRYPOINT [ "poetry", "run" ]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
