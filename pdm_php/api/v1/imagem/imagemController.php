<?php
      
    require_once('./ImagemService.php');
    require_once('../../database/Banco.php');

    try {  
        $jsonPostData = json_decode(file_get_contents("php://input"), true);

        $operacao = isset($_REQUEST['operacao']) ? $_REQUEST['operacao'] : "Não informado [Erro]";
    
        $banco = new Banco(null,null,null,null,null,null);
        
        $ImagemService = new ImagemService($banco);
        
        switch ($operacao) {
            case 'getImagem':
                $ImagemService->getImagem();
                break;   
            case 'createImagem':
                $id_sequence = isset($_POST['id_sequence']) ? $_POST['id_sequence'] : throw new Exception("campo id_sequence não fornecido");
                $vl_url = isset($_POST['vl_url']) ? $_POST['vl_url'] : throw new Exception("campo vl_url não fornecido");
                $ImagemService->createImagem($id_sequence, $vl_url);
                break;    
            case 'deleteImagem':
                $id_Imagem = isset($_POST['id_Imagem']) ? $_POST['id_Imagem'] : throw new Exception("campo id_Imagem não fornecido");
                $ImagemService->deleteImagem($id_Imagem);
                break; 
            default:
                $banco->setMensagem(1, 'Operação informada não tratada. Operação=' . $operacao);
                break;
        }

        echo $banco->getRetorno();
        unset($banco);
    }
    catch(Exception $e) {   
        if (isset($banco)) {   
            $banco->setMensagem(1, $e->getMessage());
            echo $banco->getRetorno();
            unset($banco);
        } else {
            header("Content-Type: application/json; charset=UTF-8");
            echo json_encode([
                "operacao" => isset($operacao) ? $operacao : 'desconhecida',
                "NumMens" => 1,
                "Mensagem" => $e->getMessage(),
                "registros" => 0,
                "dados" => null
            ]);
        }
    }
            
?>
