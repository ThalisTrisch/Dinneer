<?php
    
    class Banco 
    {
        private $Driver;      
        private $Host; 
        private $Porta;
        private $User;
        private $Password;
        private $Database;
        private $conexao;
        private $Mensagem;
        private $NumMensagem;
        private $Dados;
        private $NumRegistros;
       
/*
   $this->Host     = is_null($p_Host)     ? "200.19.1.18" :$p_Host;
   Use este ip (200.19.1.18) caso sua aplicação esteja na sua máquina (XAMPP)
   Caso sua aplicação tenha sido colocado dentro do seridor de aplicação do IF Gravatai, use
   o IP 192.168.20.18
    
*/
        function __construct($p_Driver  , $p_Host, 
                             $p_Porta   , $p_User, 
                             $p_Password, $p_Database)                          
        
        {      
            $this->Abre_Banco($p_Driver,$p_Host,$p_Porta,$p_User,$p_Password,$p_Database);
        }

       
        function Abre_Banco(
                            $p_Driver  , $p_Host, 
                            $p_Porta   , $p_User, 
                            $p_Password, $p_Database) 
        
        {   
            
            $this->User     = is_null($p_User)     ? "thalistrisch"    :$p_User;
            $this->Password = is_null($p_Password) ? "123456"      :$p_Password;
            $this->Database = is_null($p_Database) ? "thalistrisch"    :$p_Database;
            
            $this->Host     = $this->setHost($p_Host);

            $this->Driver   = is_null($p_Driver)   ? "pgsql" :$p_Driver;
            $this->Porta    = is_null($p_Porta)    ? "5432"  :$p_Porta;

            

            $this->conexao  = null;
            try
            {
                $this->criaConexao(); 
            }
            catch(Exception $e)
            {
                throw new Exception($e->getMessage());
            }
        }

        private function setHost($p_Host)
        {
            if (is_null($p_Host))   
            {
                $p_Host = "200.19.1.18";
            }
            return $p_Host;

        }

        // Função para criar a conexão com o banco de dados

        private function criaConexao()
        {  
            try 
            {
                $this->conexao = new PDO(
                                           $this->Driver . 
                                           ":host="      . $this->Host  . 
                                           ";port="      . $this->Porta . 
                                           ";dbname="    . $this->Database,
                                           $this->User,
                                           $this->Password,
                                           array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
                                       );
            }
            catch (PDOException $e)
            {
                throw new Exception($e->getMessage());   
            }
            catch (Exception $e) 
            {   
                throw new Exception("Usuario/Senha Inexistentes");   
            }
        }

        public function getConexao()
        {
            return $this->conexao;
        }

        public function setMensagem($p_num,$p_mensagem)
        {
            $this->NumMensagem = $p_num;
            $this->Mensagem    = $p_mensagem;
        }

        public function setDados($p_numRegistros,$p_dados)
        {
            $this->Dados = $p_dados;
            $this->NumRegistros = $p_numRegistros;
        }

        public function getRetorno()
        {
            $json = "";
            if (!empty($this->Dados))
            {
                $json = json_encode($this->Dados);
                if (json_last_error ( ))
                {
                    throw new Exception("Falha Geracao Json no retorno"); 
                }
            }
           
            return json_encode(array("operacao"  =>$GLOBALS["operacao"],
                                     "NumMens"   =>$this->NumMensagem,
                                     "Mensagem"  =>$this->Mensagem,
                                     "registros" =>$this->NumRegistros,
                                     "dados"     =>$this->Dados));
        }

        public function ErroConexao()
        {
            Echo array("Erro"=>"Falha com a Conexão do Banco de Dados");
        }

        public function Consiste_Param()
        {
            $GLOBALS["Dados"] =  isset($_REQUEST['dados'])?$_REQUEST['dados']:"";
            $GLOBALS["Oper"]  =  isset($_REQUEST['oper']) ?$_REQUEST['oper'] :"";
            if (empty($GLOBALS["Dados"]))
            {
                throw new Exception("Dados nao fornecidos");
            }
            if (empty($GLOBALS["Oper"]))
            {
                throw new Exception("Operacao nao fornecida");
            }
            $GLOBALS["Dados"] = json_decode($GLOBALS["Dados"]);
        }
    }
?>