<?php
$senha = '123456';
$metodo_criptografia = 'aes-256-cbc';
$chave = 'sua_chave_secreta_de_32_bytes';
$iv = '1234567891234567';

echo "=================================\n";
echo "Teste de Criptografia PHP\n";
echo "=================================\n";
echo "Senha original: $senha\n";
echo "Chave: $chave\n";
echo "Chave length: " . strlen($chave) . "\n";
echo "IV: $iv\n";
echo "IV length: " . strlen($iv) . "\n";
echo "\n";

$criptografia = openssl_encrypt($senha, $metodo_criptografia, $chave, 0, $iv);
echo "Senha criptografada: $criptografia\n";
echo "\n";

// Senha do banco
$senhaDoBanco = 'laAHE/WEvJhr5v55nl4sPA==';
echo "Senha do banco: $senhaDoBanco\n";
echo "\n";

echo "São iguais? " . ($criptografia === $senhaDoBanco ? 'SIM' : 'NÃO') . "\n";
echo "=================================\n";
?>
