FROM golang:latest AS builder

WORKDIR /app

RUN go mod init fullcycle/go-2mb

COPY main.go .

# CGO_ENABLED=0 => não linka libraries do C
# GOOS e GOARCH => OS e arquitetura alvo, não compila coisas desnecessárias (específicas de windows ou macos)
# -ldflags="-s -w" => remove informações de debug, reduz a imagem mas teoricamente dificultaria o debug da aplicação se fosse complexa
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o ./fc .

FROM gruebel/upx:latest AS upx

WORKDIR /app

COPY --from=builder /app .

# comando copiado da doc do upx usando a opção mais potente, demora pra buildar mas reduz firme
RUN upx --ultra-brute ./fc

# imagem completamente vazia
FROM scratch

WORKDIR /app

COPY --from=upx /app .

CMD [ "./fc" ]