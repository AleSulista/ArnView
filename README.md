# ArnView

**ArnView** é um visualizador e editor de imagens para macOS Intel desenvolvido por **Alessandro Henriques Teixeira — Studio Arn**.

O projeto combina visualização rápida e edição integrada no mesmo ambiente: a imagem pode ser aberta, inspecionada, ampliada e trabalhada diretamente no ArnView, sem depender de ferramentas externas para as operações oferecidas pelo aplicativo.

## Situação atual do projeto

A linha pública de código deste repositório corresponde ao **ArnView 0.4.0**. A partir da linha **0.6.x**, o ArnView passa a seguir um modelo **proprietário**: as informações de versão, melhorias, recursos, créditos e avisos continuam públicas, mas o código-fonte da nova linha não é publicado neste repositório.

O **ArnView 0.6.0 Proprietário** foi finalizado para **macOS Intel (x86_64)**. O DMG de distribuição foi preparado, verificado e está em fase de publicação na Release **v0.6.0**.

> **Importante:** a linha 0.6.x é distribuída como binário proprietário. O código-fonte público presente neste repositório continua representando a linha 0.4.0.

## Conceito do visualizador

O visualizador do ArnView foi inspirado na experiência simples, direta e rápida dos antigos visualizadores de imagens do Google, reinterpretada para um aplicativo moderno no macOS. Essa referência é apenas de experiência de uso; o ArnView é um projeto independente, sem afiliação, endosso ou vínculo com o Google.

Um dos destaques do visualizador é o **zoom de até 3200%**, permitindo inspeção extrema da imagem com alta nitidez visual durante a ampliação.

Mais do que visualizar, o ArnView permite **trabalhar diretamente com a imagem aberta**: ajustes, edição, camadas, recorte, texto e recursos de inteligência artificial podem ser acessados dentro do próprio aplicativo, sem precisar encaminhar a imagem para um editor externo.

## ArnView 0.6.0 — principais mudanças e melhorias

A versão 0.6.0 representa uma evolução importante do ArnView, com foco em edição por camadas, interface mais limpa, manipulação direta dos elementos e recursos de inteligência artificial executados localmente.

### Visualizador e fluxo integrado

- visualização rápida de imagens;
- navegação entre imagens da mesma pasta;
- faixa de miniaturas;
- **zoom de até 3200%**;
- zoom por scroll e trackpad;
- visualização 1:1;
- rotação e tela cheia;
- abertura pelo Finder, seletor e arrastar e soltar;
- acesso direto às ferramentas de edição a partir da imagem visualizada;
- trabalho com a imagem sem depender de ferramentas externas para os recursos integrados ao ArnView.

### Interface e edição

- nova interface visual **ArnGlass**;
- editor integrado ao fluxo do visualizador;
- painel de camadas redesenhado;
- seleção de camadas diretamente na área principal de edição;
- movimentação e redimensionamento de camadas na área de trabalho;
- reorganização da ordem das camadas;
- transparência e opacidade de camadas;
- controles inferiores mais compactos no painel de camadas;
- histórico de alterações com identificação das operações realizadas;
- fluxo de desfazer e refazer preservado;
- pincel de desfoque com resposta mais fluida;
- ajustes de imagem com controles contínuos;
- brilho, contraste, saturação, temperatura e matiz;
- preto e branco e sépia;
- texto sobre a imagem;
- recorte;
- aumento de resolução;
- OCR;
- recursos de busca e análise visual.

### Inteligência artificial local

- **remoção de objetos com LaMa**, executada localmente;
- remoção inteligente e automática de fundo;
- processamento de pessoas com **MODNet/Core ML**;
- segmentação de cenas e objetos com tecnologias nativas do macOS, incluindo **Apple Vision Foreground**;
- detectores e auxiliares nativos para pessoas, rostos e primeiro plano;
- melhoria automática de imagem;
- redução de ruído;
- recuperação de fotos escuras;
- restauração fotográfica;
- melhoria de rostos;
- processamento local/offline nas funções que utilizam os mecanismos integrados.

## Instalação da versão 0.6.0

A distribuição oficial para macOS Intel é feita por arquivo **DMG** na área de Releases.

1. abra o DMG;
2. arraste **ArnView.app** para **Applications / Aplicativos**;
3. abra o ArnView pela pasta Aplicativos.

### Aviso do Gatekeeper

A versão 0.6.0 atual não possui assinatura **Apple Developer ID** nem notarização pela Apple. Por isso, em alguns Macs o macOS poderá exibir um aviso de desenvolvedor não identificado na primeira execução. Isso é uma limitação da forma atual de assinatura e não significa, por si só, que o arquivo esteja corrompido.

Quando necessário, use o procedimento de abertura permitido pelo próprio macOS para aplicativos obtidos fora da App Store. Futuras distribuições poderão adotar Developer ID e notarização.

## Capturas de tela — ArnView 0.6.0 Proprietário

### Visualizador ArnGlass — ArnView 0.6.0 Proprietário

![ArnView 0.6.0 Proprietário - Visualizador ArnGlass](screenshots/0.6.0/01-arnview-viewer.png)

### Editor e sistema de camadas — ArnView 0.6.0 Proprietário

![ArnView 0.6.0 Proprietário - Editor e camadas](screenshots/0.6.0/02-editor-camadas.png)

### Inteligência artificial local — ArnView 0.6.0 Proprietário

![ArnView 0.6.0 Proprietário - Inteligência artificial local](screenshots/0.6.0/03-inteligencia-artificial.png)

### Remoção local de objetos com LaMa — ArnView 0.6.0 Proprietário

![ArnView 0.6.0 Proprietário - Remoção de objetos com LaMa](screenshots/0.6.0/04-remover-objeto-lama.png)

### Capturas históricas — ArnView 0.4.0

As capturas abaixo documentam a versão pública anterior **0.4.0** e permanecem disponíveis como registro histórico.

#### ArnView Viewer — 0.4.0

![ArnView Viewer](screenshots/01-viewer.png)

#### Visualização limpa — 0.4.0

![ArnView Viewer - visualização limpa](screenshots/02-viewer-clean.png)

#### Editor — Ajustes — 0.4.0

![ArnView Editor - Ajustes](screenshots/03-editor-ajustes.png)

#### Editor — Texto — 0.4.0

![ArnView Editor - Texto](screenshots/04-editor-texto.png)

#### Editor — Recorte — 0.4.0

![ArnView Editor - Recorte](screenshots/05-editor-recorte.png)

#### Editor — IA local — 0.4.0

![ArnView Editor - IA local](screenshots/06-editor-ia.png)

## IA local e tamanho do aplicativo

O ArnView foi projetado para que seus principais recursos de inteligência artificial funcionem **localmente e offline**. Por isso, a distribuição completa pode ser consideravelmente maior que a de um visualizador convencional: ela pode incluir modelos, frameworks, bibliotecas e mecanismos necessários para o processamento no próprio computador.

Entre as tecnologias utilizadas ao longo do projeto estão **LaMa, MODNet, Core ML, Apple Vision, OpenCV, Real-ESRGAN, Tesseract OCR, NumPy, Pillow, Python embarcado e Qt 6**. Componentes de terceiros permanecem sujeitos às licenças e aos direitos de seus respectivos autores.

## Privacidade

Quando uma função utiliza um mecanismo local integrado, o processamento ocorre no próprio computador. Isso permite realizar grande parte das operações de edição e IA sem enviar a imagem do usuário para um serviço externo.

## Compatibilidade

- **Plataforma principal da versão 0.6.0:** macOS Intel;
- **Arquitetura:** x86_64;
- builds para Apple Silicon e Windows poderão ser tratados separadamente no futuro;
- compatibilidade em outras arquiteturas não deve ser presumida como oficial até que exista uma versão específica testada.

## Integridade e distribuição

O pacote de distribuição deve ser obtido preferencialmente pela área oficial de Releases deste repositório. A integridade do DMG da versão 0.6.0 foi validada durante o processo de empacotamento antes da publicação.

Para cada release binária, recomenda-se preservar o nome da versão, os avisos de autoria e os arquivos de licenças e atribuições de terceiros que acompanham a distribuição.

## Licenciamento

- **ArnView 0.4.0 e conteúdo anteriormente publicado:** permanecem sujeitos aos termos e avisos existentes na versão em que foram disponibilizados;
- **ArnView 0.6.x e versões proprietárias posteriores:** o código-fonte não é disponibilizado publicamente; todos os direitos sobre os elementos originais permanecem reservados ao autor, sem prejuízo das licenças aplicáveis aos componentes de terceiros.

A mudança de modelo de distribuição não altera nem substitui as licenças dos projetos, frameworks, modelos ou bibliotecas de terceiros utilizados pelo ArnView.

## Autoria

- **Produto:** ArnView
- **Criador e desenvolvedor:** **Alessandro Henriques Teixeira**
- **Estúdio:** **Studio Arn**
- **Ano:** 2026

Copyright © 2026 **Alessandro Henriques Teixeira — Studio Arn**. Todos os direitos reservados sobre os elementos originais do ArnView, observadas as licenças aplicáveis aos componentes de terceiros.

Consulte também [`CHANGELOG.md`](CHANGELOG.md), [`CREDITS.md`](CREDITS.md), [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md), [`PROPRIETARY-NOTICE.md`](PROPRIETARY-NOTICE.md), [`RELEASE-NOTES-0.6.0.md`](RELEASE-NOTES-0.6.0.md) e `LICENSE`.
