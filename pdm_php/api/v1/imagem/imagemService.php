<?php
require_once('../../database/InstanciaBanco.php');


class ImagemService extends InstanciaBanco {
    public function getImagem() {
        $sql = "SELECT * from tb_Imagem_dn as A,tb_sequence_dn as B where B.id_sequence = A.id_sequence and B.id_sequence = ".$_GET['id_imagem'];

        $consulta = $this->conexao->query($sql);
        $resultados = $consulta->fetchAll(PDO::FETCH_ASSOC);
        $this->banco->setDados(count($resultados), $resultados);

        if (!$resultados) {
            $this->banco->setDados(0, []);
        }
        
        return $resultados;
    }

    public function createImagem($id_sequence, $vl_url) {

        $sql = "INSERT INTO tb_imagem_dn (vl_url, id_sequence) VALUES (:vl_url, :id_sequence)";

        $insertImagem = $this->conexao->prepare($sql);

        $insertImagem->bindValue(':id_sequence', $id_sequence, PDO::PARAM_INT);
        $insertImagem->bindValue(':vl_url', $vl_url, PDO::PARAM_INT);
        $resultados = $insertImagem->execute();

        if ($resultados) {
            $this->banco->setDados(1, [$resultados]);
        }else{
            throw new Exception("Não foi possível criar o Imagem");
        }
        return $resultados;
    }
    
    
    public function deleteImagem($id_Imagem) {
        $sql = "DELETE FROM tb_Imagem_dn WHERE id_Imagem = ".$_POST['id_Imagem'];

        $deleteuser = $this->conexao->query($sql);
        $responseuser = $deleteuser->fetchAll(PDO::FETCH_ASSOC);
        if (!$responseuser){throw new Exception("Não foi possível deletar o Imagem");}

        $this->banco->setMensagem(1, "Deletado com sucesso");
        return $responseuser;
    }

    // Exemplo de rotas na url:
    // http://Imagemhost/pdm/api/v1/refeicao/RefeicaoController.php/?operacao=getRefeicoes
    // http://Imagemhost/pdm/api/v1/refeicao/RefeicaoController.php/?operacao=getRefeicao&id_refeicao=2
    // http://Imagemhost/pdm/api/v1/refeicao/RefeicaoController.php/?operacao=createRefeicao
    // http://Imagemhost/pdm/api/v1/refeicao/RefeicaoController.php/?operacao=updateRefeicao
    // http://Imagemhost/pdm/api/v1/refeicao/RefeicaoController.php/?operacao=deleteRefeicao
}
