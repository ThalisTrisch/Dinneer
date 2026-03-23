<?php

abstract Class InstanciaBanco
{
    protected $banco;
    protected $conexao;

  	function __construct($p_banco)
  	{ 
  		$this->banco      = $p_banco;
  	 	$this->conexao    = $this->banco->getConexao();
  	}
  }
