# ArnView 0.4.0

**ArnView** é um visualizador e editor de imagens para macOS Intel desenvolvido por **Alessandro Henriques Teixeira — Studio Arn**.

A versão **0.4.0** reúne um visualizador leve, o **ArnView Editor** e recursos de inteligência artificial executados **localmente no próprio Mac**.

## IA local — por que o ArnView ocupa mais espaço

O ArnView foi projetado para que seus principais recursos de inteligência artificial funcionem **localmente e offline**, sem depender de processamento em servidores externos e sem exigir créditos de API para essas funções.

Por isso, a distribuição completa do aplicativo é consideravelmente maior que a de um visualizador de imagens comum. O tamanho se deve principalmente aos motores de IA, bibliotecas Python, modelos, frameworks e demais dependências necessárias para executar o processamento diretamente no computador do usuário.

**Em resumo: o ArnView é maior porque leva a IA dentro do aplicativo, em vez de enviar as imagens para uma IA online.**

### Tecnologias e IAs utilizadas

- **LaMa / IOPaint** — preenchimento inteligente e remoção local de objetos;
- **rembg** — remoção automática de fundo;
- **Real-ESRGAN** — super-resolução e aumento de resolução;
- **OpenCV** — visão computacional, detecção e processamento de imagens;
- **Tesseract OCR / pytesseract** — reconhecimento óptico de caracteres, incluindo português;
- **NumPy** e **Pillow** — processamento e manipulação de imagens;
- **Python 3.12** embarcado — execução dos módulos locais de IA;
- **Qt 6** — interface gráfica e infraestrutura do aplicativo.

Os projetos e bibliotecas de terceiros permanecem sujeitos às licenças e aos direitos de seus respectivos autores.

## ArnView Viewer

- visualização rápida de imagens;
- interface limpa e transparente;
- navegação por imagens da mesma pasta;
- miniaturas;
- zoom por scroll e trackpad;
- ajuste automático à tela;
- tamanho real 1:1;
- rotação;
- modo tela cheia;
- abertura por Finder, seletor e arrastar e soltar;
- acesso ao ArnView Editor pelo botão **Editar**.

## ArnView Editor

### Ajustes

- brilho;
- contraste;
- saturação;
- temperatura;
- matiz;
- preto e branco;
- sépia;
- melhoria automática;
- rotação;
- espelhamento;
- desfazer e refazer.

### Texto

- edição diretamente sobre a imagem;
- escolha de fonte e tamanho;
- cores;
- negrito e itálico;
- contorno;
- sombra, distância e ângulo;
- opacidade;
- rotação;
- caixa móvel e redimensionável.

### Recorte inteligente

- 1:1;
- 4:5;
- 16:9;
- 9:16;
- enquadramento auxiliado por detecção facial.

### Recursos de IA local

- remoção de objetos com LaMa;
- remoção automática de fundo;
- melhoria inteligente;
- redução de ruído;
- recuperação de fotos escuras;
- restauração fotográfica;
- melhoria de rostos;
- desfoque automático de rostos;
- aumento de resolução 2× e 4× com Real-ESRGAN;
- OCR em português;
- busca por imagens visualmente semelhantes.

## Privacidade

Os recursos locais descritos acima são processados no próprio computador. A arquitetura foi escolhida para permitir edição e IA sem exigir o envio das imagens do usuário para um serviço de IA online para essas operações.

## Versão e autoria

- **Produto:** ArnView
- **Versão:** 0.4.0
- **Ano:** 2026
- **Criador e desenvolvedor:** **Alessandro Henriques Teixeira**
- **Estúdio:** **Studio Arn**
- **Criação, interface, integração macOS e desenvolvimento original:** **Alessandro Henriques Teixeira — Studio Arn**

## Crédito obrigatório

Nos usos do código original do ArnView que sejam autorizados pelo titular dos direitos, incluindo redistribuições, modificações e trabalhos derivados permitidos, os avisos de autoria e copyright devem ser preservados de forma visível.

O crédito exigido para os elementos originais do projeto é:

> **ArnView — criado e desenvolvido por Alessandro Henriques Teixeira — Studio Arn.**

Não é autorizada a remoção dos avisos de autoria e copyright dos elementos originais do ArnView. Esta exigência não altera as licenças dos componentes de terceiros, que continuam regidos por seus próprios termos.

Consulte `LICENSE` e `CREDITS.md`.

Copyright © 2026 **Alessandro Henriques Teixeira — Studio Arn**. Todos os direitos reservados sobre os elementos originais do ArnView, observadas as licenças aplicáveis aos componentes de terceiros.
