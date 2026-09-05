# ArnView 0.4.0

ArnView é um visualizador e editor de imagens para macOS desenvolvido por
Alessandro Henriques Teixeira — Studio Arn.

A versão 0.4.0 marca a separação entre o visualizador leve e o ArnView Editor,
com ferramentas de edição e inteligência artificial local.

## ArnView Viewer

- visualização rápida de imagens;
- interface limpa e transparente;
- navegação por imagens da mesma pasta;
- miniaturas;
- zoom por scroll/trackpad;
- ajuste automático à tela;
- tamanho real 1:1;
- rotação;
- modo tela cheia;
- abertura por Finder, seletor e arrastar e soltar;
- botão único Editar para acessar o ArnView Editor.

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
- escolha de fonte;
- tamanho;
- cores;
- negrito;
- itálico;
- contorno;
- sombra;
- distância e ângulo da sombra;
- opacidade;
- rotação;
- caixa móvel e redimensionável.

### Recorte inteligente

- 1:1;
- 4:5;
- 16:9;
- 9:16;
- enquadramento auxiliado por detecção facial.

## Inteligência Artificial Local

O ArnView 0.4.0 prioriza processamento local e offline.

Recursos integrados:

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

As ferramentas locais não necessitam de créditos de API para funcionar.

## Proteção do original

O ArnView trabalha sobre uma imagem de edição.

Salvar não deve substituir silenciosamente o arquivo original.

Quando necessário são criadas cópias como:

- imagem-editado.jpg
- imagem-editado-2.jpg
- imagem-editado-3.jpg

## Formatos

O ArnView reconhece, conforme suporte do sistema e dos plugins disponíveis:

- JPEG / JPG
- PNG
- WebP
- BMP
- GIF
- TIFF
- HEIC
- HEIF

## Atalhos do visualizador

- ⌘O — abrir imagem
- ⌘S — salvar
- ⌘Z — desfazer
- ⇧⌘Z — refazer
- ← / → — anterior / próxima
- 0 ou Espaço — ajustar à tela
- 1 — tamanho real
- + / − — zoom
- R — girar
- B — alternar fundo
- F — tela cheia
- Esc — fechar

## Desenvolvimento

Projeto criado e desenvolvido por:

**Alessandro Henriques Teixeira**  
**Studio Arn**

Versão: **0.4.0**  
Ano: **2026**

## Componentes de terceiros

ArnView utiliza projetos e bibliotecas de terceiros, que permanecem sujeitos
às suas respectivas licenças e direitos autorais, incluindo componentes como:

- Qt
- OpenCV
- NumPy
- Pillow
- Tesseract OCR / pytesseract
- rembg
- IOPaint / LaMa
- Real-ESRGAN

Consulte `CREDITS.md` para os créditos técnicos.

Copyright © 2026 Alessandro Henriques Teixeira — Studio Arn.
Todos os direitos reservados sobre o código original do ArnView,
observadas as licenças aplicáveis aos componentes de terceiros.
