$contexto = Read-Host "Qual contexto quer adicionar? (Ex: Empresa, CargaConfiguracao)"
$contextoPlural = Read-Host "Qual o plural desse contexto? (Ex: Empresas, CargasConfiguracoes)"
$usarMapeador = Read-Host "Deseja usar AutoMapper ou Mapster? (A/M)"

Write-Host "`nGerando estrutura para o contexto: $contextoPlural"

function New-ContextFile {
    param (
        [string]$caminho,
        [string]$conteudo = ""
    )
    if (-not (Test-Path $caminho)) {
        New-Item -Path $caminho -ItemType File -Force | Out-Null
        if ($conteudo -ne "") {
            Set-Content -Path $caminho -Value $conteudo
        }
    }
}

function CriarClasseComNamespace {
    param (
        [string]$nomeProjeto,
        [string]$camada,
        [string]$contextoPlural,
        [string]$tipo = "class",
        [string]$nome = "",
        [string]$heranca = "",
        [string]$usings = ""
    )

    $namespaceExtra = switch -Wildcard ($nome) {
        "$($contexto)Comando"                   { "Servicos.Comandos" }
        "I$($contextoPlural)Servico"            { "Servicos.Interfaces" }
        "$($contextoPlural)Servico"             { "Servicos" }
        "I$($contextoPlural)Repositorio"        { "Repositorios.Interfaces" }
        "$($contexto)ListarFiltro"              { "Repositorios.Filtros" }
        "$($contexto)"                          { "Entidades" }
        "$($contexto)Request"                   { "Requests" }
        "$($contexto)ListarRequest"             { "Requests" }
        "$($contexto)Response"                  { "Responses" }
        "$($contextoPlural)AppServico"          { "Servicos" }
        "I$($contextoPlural)AppServico"         { "Servicos.Interfaces" }
        "$($contexto)ServicoTestes"             { "Testes.Servicos" }
        "$($contexto)Testes"                    { "Testes.Entidades" }
        default                                 { "" }
    }

    $namespace = "$nomeProjeto.$camada"
    if ($contextoPlural) {
        $namespace += ".$contextoPlural"
    }
    if ($namespaceExtra -ne "") {
        $namespace += ".$namespaceExtra"
    }

    $declaracao = "public $tipo $nome"
    if ($heranca -ne "") {
        $declaracao += " : $heranca"
    }

    $conteudo = ""
    if ($usings -ne "") {
        $conteudo += "$usings`r`n`r`n"
    }

    $conteudo += "namespace $namespace;`r`n`r`n$declaracao`r`n{`r`n}"
    return $conteudo
}

function CriarController {
    param (
        [string]$nomeProjeto,
        [string]$contextoPlural
    )

    $namespace = "$nomeProjeto.API.Controllers.$contextoPlural"
    $classe = "public class ${contextoPlural}Controller : ControllerBase"
    return @"
using Microsoft.AspNetCore.Mvc;

namespace $namespace;

[Route("api/int-app/$($contextoPlural.ToLower())")]
[ApiController]
$classe
{
}
"@
}

$solucao = Get-ChildItem -Directory | Where-Object { $_.Name -like "*.Dominio" } | Select-Object -ExpandProperty Name | ForEach-Object { $_ -replace "\.Dominio$", "" }

foreach ($nomeProjeto in $solucao) {
    $baseDominio = ".\$nomeProjeto.Dominio\$contextoPlural"
    New-Item -ItemType Directory -Force -Path "$baseDominio\Entidades","$baseDominio\Repositorios\Filtros","$baseDominio\Repositorios\Interfaces","$baseDominio\Servicos\Comandos","$baseDominio\Servicos\Interfaces","$baseDominio\Consultas" | Out-Null

    $filtroDominio = @"
using $nomeProjeto.Dominio.Uteis;
using $nomeProjeto.Dominio.Uteis.Enumeradores;

namespace $nomeProjeto.Dominio.$contextoPlural.Repositorios.Filtros;

public class $($contexto)ListarFiltro : PaginacaoFiltro
{
    public $($contexto)ListarFiltro() : base(cpOrd: "", tpOrd: TipoOrdenacaoEnum.Asc) { }
}
"@
    New-ContextFile "$baseDominio\Entidades\$contexto.cs" (CriarClasseComNamespace $nomeProjeto "Dominio" $contextoPlural "class" $contexto)
    New-ContextFile "$baseDominio\Repositorios\Filtros\$contexto`ListarFiltro.cs" $filtroDominio
    New-ContextFile "$baseDominio\Repositorios\Interfaces\I$contextoPlural`Repositorio.cs" (CriarClasseComNamespace $nomeProjeto "Dominio" $contextoPlural "interface" "I$contextoPlural`Repositorio")
    New-ContextFile "$baseDominio\Servicos\Comandos\$contexto`Comando.cs" (CriarClasseComNamespace $nomeProjeto "Dominio" $contextoPlural "class" "$contexto`Comando")
    New-ContextFile "$baseDominio\Servicos\Interfaces\I$contextoPlural`Servico.cs" (CriarClasseComNamespace $nomeProjeto "Dominio" $contextoPlural "interface" "I$contextoPlural`Servico")
    $namespaceDominioInterface = "$nomeProjeto.Dominio.$contextoPlural.Servicos.Interfaces"

    $usingsDominioServico = "using $namespaceDominioInterface;"
    New-ContextFile "$baseDominio\Servicos\$contextoPlural`Servico.cs" (CriarClasseComNamespace $nomeProjeto "Dominio" $contextoPlural "class" "$contextoPlural`Servico" "I$contextoPlural`Servico" $usingsDominioServico)

    $baseInfra = ".\$nomeProjeto.Infra\$contextoPlural"
    New-Item -ItemType Directory -Force -Path "$baseInfra\Mapeamentos","$baseInfra\Repositorios" | Out-Null

    $mapConteudo = @"
using FluentNHibernate.Mapping;
using $nomeProjeto.Dominio.$contextoPlural.Entidades;

namespace $nomeProjeto.Infra.$contextoPlural.Mapeamentos;

public class $contexto`Map : ClassMap<$contexto>
{
    public $contexto`Map()
    {
    }
}
"@
    $repoConteudo = @"
using $nomeProjeto.Dominio.$contextoPlural.Repositorios.Interfaces;
using $nomeProjeto.Infra.Genericos;
using $nomeProjeto.Dominio.$contextoPlural.Entidades;
using NHibernate;

namespace $nomeProjeto.Infra.$contextoPlural.Repositorios;

public class $contextoPlural`Repositorio : GenericosRepositorio<$contexto>, I$contextoPlural`Repositorio
{
    public $contextoPlural`Repositorio(ISession session) : base(session) { }
}
"@
    New-ContextFile "$baseInfra\Mapeamentos\$contexto`Map.cs" $mapConteudo
    New-ContextFile "$baseInfra\Repositorios\$contextoPlural`Repositorio.cs" $repoConteudo

    $baseDTO = ".\$nomeProjeto.DataTransfer\$contextoPlural"
    New-Item -ItemType Directory -Force -Path "$baseDTO\Requests","$baseDTO\Responses" | Out-Null

    $filtroDTO = @"
using $nomeProjeto.Dominio.Uteis;
using $nomeProjeto.Dominio.Uteis.Enumeradores;

namespace $nomeProjeto.DataTransfer.$contextoPlural.Requests;

public class $contexto`ListarRequest : PaginacaoFiltro
{
    public $contexto`ListarRequest() : base(cpOrd: "", tpOrd: TipoOrdenacaoEnum.Asc) { }
}
"@
    New-ContextFile "$baseDTO\Requests\$contexto`Request.cs" (CriarClasseComNamespace $nomeProjeto "DataTransfer.$contextoPlural.Requests" "" "class" "$contexto`Request")
    New-ContextFile "$baseDTO\Requests\$contexto`ListarRequest.cs" $filtroDTO
    New-ContextFile "$baseDTO\Responses\$contexto`Response.cs" (CriarClasseComNamespace $nomeProjeto "DataTransfer.$contextoPlural.Responses" "" "class" "$contexto`Response")

    $baseApp = ".\$nomeProjeto.Aplicacao\$contextoPlural"

    if ($usarMapeador -eq "A") {
        New-Item -ItemType Directory -Force -Path "$baseApp\Profiles","$baseApp\Servicos\Interfaces" | Out-Null
        $conteudoProfile = @"
using AutoMapper;

namespace $nomeProjeto.Aplicacao.$contextoPlural.Profiles;

public class $contextoPlural`Profile : Profile
{
    public $contextoPlural`Profile()
    {
    }
}
"@
        New-ContextFile "$baseApp\Profiles\$contextoPlural`Profile.cs" $conteudoProfile
    } else {
        New-Item -ItemType Directory -Force -Path "$baseApp\Mappings","$baseApp\Servicos\Interfaces" | Out-Null
        $conteudoProfile = @"
using Mapster;

namespace $nomeProjeto.Aplicacao.$contextoPlural.Mappings;

public class $contextoPlural`Mapping : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
    }
}
"@
        New-ContextFile "$baseApp\Mappings\$contextoPlural`Profile.cs" $conteudoProfile
    }

    $herancaApp = "I$contextoPlural`AppServico"

    $namespaceInterface = "$nomeProjeto.Aplicacao.$contextoPlural.Servicos.Interfaces"
    $usings = "using $namespaceInterface;"

    $classeAppServico = @"
$usings

$(CriarClasseComNamespace $nomeProjeto "Aplicacao.$contextoPlural.Servicos" "" "class" "$contextoPlural`AppServico" $herancaApp)
"@

    New-ContextFile "$baseApp\Servicos\$contextoPlural`AppServico.cs" $classeAppServico
    New-ContextFile "$baseApp\Servicos\Interfaces\I$contextoPlural`AppServico.cs" (CriarClasseComNamespace $nomeProjeto "Aplicacao.$contextoPlural.Servicos.Interfaces" "" "interface" "I$contextoPlural`AppServico")

    $baseApi = ".\$nomeProjeto.API\Controllers\$contextoPlural"
    New-Item -ItemType Directory -Force -Path $baseApi | Out-Null
    New-ContextFile "$baseApi\$contextoPlural`Controller.cs" (CriarController $nomeProjeto $contextoPlural)

    $baseTestes = ".\$nomeProjeto.Dominio.Testes\$contextoPlural"
    New-Item -ItemType Directory -Force -Path "$baseTestes\Entidades","$baseTestes\Servicos" | Out-Null
    New-ContextFile "$baseTestes\Entidades\$contexto`Testes.cs" (CriarClasseComNamespace $nomeProjeto "Dominio.Testes" "" "class" "$contexto`Testes")
    New-ContextFile "$baseTestes\Servicos\$contexto`ServicoTestes.cs" (CriarClasseComNamespace $nomeProjeto "Dominio.Testes" "" "class" "$contexto`ServicoTestes")

    Write-Host "`nContexto '$contextoPlural' gerado com sucesso."
}