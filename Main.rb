require 'json'
require 'fileutils'

# Função para contar ocorrências de palavras em um arquivo SRT
def contar_ocorrencias_palavra(caminho_arquivo)
  File.open(caminho_arquivo, 'r', encoding: 'ISO-8859-1') do |arquivo|
    conteudo = arquivo.read.downcase
    palavras = extrair_e_limpar_palavras(conteudo)
    filtrar_palavras(palavras)
  end
end

# Função para extrair e limpar palavras usando expressões regulares
def extrair_e_limpar_palavras(conteudo)
  conteudo.scan(/\b\w+\b/).map { |palavra| limpar_palavra(palavra) }
end

# Função para filtrar palavras, remover números e contar frequências
def filtrar_palavras(palavras)
  palavras.each_with_object(Hash.new(0)) do |palavra, contagem_palavras|
    contagem_palavras[palavra] += 1 unless palavra.empty? || palavra =~ /\d+/
  end
end

# Função para limpar uma palavra, removendo símbolos e convertendo para minúsculas
def limpar_palavra(palavra)
  palavra.gsub(/[?.,!@♪\-:()\[\]{}<>]/, '').downcase
end

# Função para criar um array JSON de objetos a partir de uma contagem de palavras
def criar_array_json(contagem_palavras)
  contagem_palavras.map { |palavra, frequencia| { 'palavra' => palavra, 'frequencia' => frequencia } }
                 .sort_by { |item| -item['frequencia'] }
end

# Função para processar todos os arquivos SRT em um diretório e subdiretórios de forma recursiva
def processar_subdiretorios(diretorio)
  resultados_dir = File.join(diretorio, 'resultados')
  FileUtils.mkdir_p(resultados_dir)

  Dir.glob(File.join(diretorio, '**/*.srt')).each do |caminho_arquivo|
    contagem_palavras_arquivo = contar_ocorrencias_palavra(caminho_arquivo)
    nome_arquivo = File.basename(caminho_arquivo)

    # Cria um arquivo JSON para cada arquivo SRT com o formato desejado
    caminho_json = File.join(resultados_dir, "frequencias_palavras_#{nome_arquivo}.json")
    File.write(caminho_json, JSON.pretty_generate(criar_array_json(contagem_palavras_arquivo)))

    puts "Processado '#{nome_arquivo}'"
  end
end

# Função para solicitar o diretório ao usuário e armazená-lo na variável global
def solicitar_diretorio
  puts "Por favor, insira o caminho do diretório que deseja escanear:"
  diretorio_escaneado = gets.chomp
  return diretorio_escaneado
end

# Função para iniciar o processamento no diretório definido pelo usuário
def processar_diretorio_usuario
  processar_subdiretorios(solicitar_diretorio)
end

# Programa principal
processar_diretorio_usuario
