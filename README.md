# vscode-create-context

**Crie rapidamente a estrutura completa de um novo contexto em projetos .NET com arquitetura em camadas!**

[![Visual Studio Marketplace](https://img.shields.io/visual-studio-marketplace/v/jardel-machado.create-context?label=VS%20Code%20Marketplace)](https://marketplace.visualstudio.com/items?itemName=jardel-machado.create-context)

---

Esta extensão do VSCode foi desenvolvida para agilizar a geração de todos os arquivos e diretórios necessários para um novo contexto, com suporte a AutoMapper ou Mapster.

## ✨ Funcionalidades

- Criação automática de:
  - Entidade, Comando, Filtro, Repositório, Serviço de Domínio
  - Mapeamento (NHibernate)
  - DTOs (Request/Response)
  - App Service e Interfaces
  - Controller
  - Estrutura de testes
- Suporte a:
  - AutoMapper ou Mapster (escolhido pelo usuário)
- Estrutura pronta para projetos com camadas:
  - `Dominio`, `Infra`, `Aplicacao`, `DataTransfer`, `API`, `Dominio.Testes`

## 🚀 Como usar

### Pela paleta de comandos:
1. Pressione `Ctrl+Shift+P`
2. Digite `Criar Novo Contexto .NET` e selecione a opção

### Pelo botão direito no Explorer:
1. Clique com o botão direito em qualquer pasta
2. Selecione `Criar Novo Contexto .NET`

### Terminal:
O script irá:
- Perguntar o nome do contexto e seu plural
- Solicitar se deseja usar AutoMapper ou Mapster
- Gerar toda a estrutura automaticamente com namespaces corretos

## 🧠 Requisitos

- PowerShell instalado (Windows já possui)
- Projeto .NET com as camadas citadas

## 📁 Estrutura gerada (exemplo para `Empresa`)

📦Empresa ├─ 📁Aplicacao │ └─ EmpresaAppServico.cs ├─ 📁DataTransfer │ ├─ EmpresaRequest.cs │ └─ EmpresaResponse.cs ├─ 📁Dominio │ ├─ Empresa.cs │ ├─ EmpresaComando.cs │ ├─ EmpresaFiltro.cs │ ├─ IEmpresaRepositorio.cs │ └─ EmpresaServico.cs ├─ 📁Infra │ └─ Mapeamentos │ └─ EmpresaMap.cs ├─ 📁API │ └─ Controllers │ └─ EmpresaController.cs ├─ 📁Dominio.Testes │ └─ EmpresaServicoTestes.cs

## 🧑‍💻 Autor

**Jardel Machado**  
[GitHub](https://github.com/Jardel-Machado)

---

📢 Se você gostou, avalie a extensão no Marketplace!

## 🛡️ Licença

Distribuído sob a licença MIT.  
Veja o arquivo [LICENSE.md](./LICENSE.md) para mais detalhes.