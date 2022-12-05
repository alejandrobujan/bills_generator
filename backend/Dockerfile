FROM elixir:latest

# install pdflatex
RUN apt-get update &&\
	apt-get -y install texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra

ENV MIX_ENV prod

WORKDIR /app

COPY mix.exs .
COPY apps/bills_generator/mix.exs ./apps/bills_generator/mix.exs
COPY apps/bills_generator_web/mix.exs ./apps/bills_generator_web/mix.exs

RUN mix local.hex --force && \
	mix local.rebar --force && \
	mix deps.get --only prod && \
	mix deps.compile

COPY . .
RUN mix compile

CMD ["./entrypoint.sh"]